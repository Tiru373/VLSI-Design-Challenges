//=============================================================
// Smart Arbiter
// - Priority-aware with Round-Robin fallback
// - Starvation prevention (aging/promote after STARVE_LIMIT cycles)
// - Locked transfers support (master can request exclusive K-beat transfer)
// - Single-clock, synchronous design
// - Parameterizable number of masters
//
// Ports:
//  clk, rst_n         : clock & async active-low reset
//  req[N-1:0]         : request from each master (level signal, hold until granted)
//  lock_req[N-1:0]    : when asserted with request, indicates master needs locked transfer
//  last[N-1:0]        : asserted by master to indicate last beat of transfer (when granted)
//  gnt[N-1:0]         : grant outputs (one-hot — only one master granted at a time)
//
// Notes:
//  - Design prefers fairness (round-robin) but honors higher priority when present.
//  - Starvation: a master holding req will be promoted (served) if its starve counter
//    reaches STARVE_LIMIT cycles.
//  - When a master is granted with lock_req asserted, arbiter keeps grant until master
//    deasserts lock (indicated by last) or reaches LOCK_MAX beats (safety).
//=============================================================
module arbiter #(
    parameter integer N = 4,                     // Number of masters
    parameter integer STARVE_LIMIT = 16,         // cycles before a starving master is promoted
    parameter integer LOCK_MAX = 8               // maximum beats allowed for a locked transfer
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire [N-1:0]          req,
    input  wire [N-1:0]          lock_req,
    input  wire [N-1:0]          last,      // master asserts last to indicate end of transaction
    output reg  [N-1:0]          gnt
);

    // Local params
    localparam IDX_W = $clog2(N);

    // Internal state
    reg [IDX_W-1:0] rr_ptr;                // round-robin pointer (next search start)
    reg [IDX_W-1:0] current;               // current granted master index
    reg              grant_valid;          // 1 => current grant is valid
    reg [7:0]        lock_count;           // beats granted to current lock (bounded by LOCK_MAX)

    // starvation counters (small saturating counters)
    reg [15:0] starve_cnt [0:N-1];

    integer i;

    // ----------------------------
    // Utility: find first set request starting from rr_ptr (wrap-around)
    // returns index or N if none
    // ----------------------------
    function automatic [IDX_W:0] find_req_from;
        input [N-1:0] mask;
        input [IDX_W-1:0] start;
        integer j, idx;
        begin
            find_req_from = N; // default none
            for (j = 0; j < N; j = j + 1) begin
                idx = (start + j) % N;
                if (mask[idx]) begin
                    find_req_from = idx;
                    disable find_req_from;
                end
            end
        end
    endfunction

    // ----------------------------
    // Promote mask: masters reaching starvation limit
    // ----------------------------
    wire [N-1:0] promote_mask;
    genvar gi;
    generate
        for (gi = 0; gi < N; gi = gi + 1) begin : PROM_MASK
            assign promote_mask[gi] = (starve_cnt[gi] >= STARVE_LIMIT) ? req[gi] : 1'b0;
        end
    endgenerate

    // ----------------------------
    // Arbitration selection (combinational)
    // - If some promoted masters exist, select first promoted starting from rr_ptr
    // - Else, pick first requester starting from rr_ptr (round-robin)
    // ----------------------------
    reg [IDX_W-1:0] next_select;
    reg select_valid;

    always @(*) begin
        select_valid = 1'b0;
        next_select = {IDX_W{1'b0}};
        if (|promote_mask) begin
            // select first promoted starting from rr_ptr
            if (find_req_from(promote_mask, rr_ptr) != N) begin
                next_select = find_req_from(promote_mask, rr_ptr)[IDX_W-1:0];
                select_valid = 1'b1;
            end
        end else begin
            // normal round-robin selection among req
            if (find_req_from(req, rr_ptr) != N) begin
                next_select = find_req_from(req, rr_ptr)[IDX_W-1:0];
                select_valid = 1'b1;
            end
        end
    end

    // ----------------------------
    // Granting logic (sequential)
    // - Keep grant if locked and not yet last & lock_count < LOCK_MAX
    // - Else select new grant based on selection logic
    // ----------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gnt <= {N{1'b0}};
            current <= {IDX_W{1'b0}};
            grant_valid <= 1'b0;
            rr_ptr <= {IDX_W{1'b0}};
            lock_count <= 0;
            for (i = 0; i < N; i = i + 1)
                starve_cnt[i] <= 0;
        end else begin
            // Default: clear grant vector; we'll set it below based on grant_valid/current
            if (grant_valid) begin
                // If current master still requests and is locked, and hasn't asserted last, keep grant
                if (lock_req[current] && req[current] && !last[current] && (lock_count < LOCK_MAX)) begin
                    // maintain grant
                    gnt <= (1 << current);
                    lock_count <= lock_count + 1;
                end else begin
                    // Release grant (either not locked, or last asserted, or lock exceeded)
                    gnt <= {N{1'b0}};
                    grant_valid <= 1'b0;
                    // advance rr_ptr to next of current (fairness)
                    rr_ptr <= (current + 1) % N;
                    lock_count <= 0;
                    current <= current; // keep value (not needed)
                end
            end else begin
                // No one currently granted => try to select
                if (select_valid) begin
                    current <= next_select;
                    grant_valid <= 1'b1;
                    gnt <= (1 << next_select);
                    // If selected had a promote/starve status, reset its starve counter below
                    lock_count <= 1; // first beat counted if it uses lock; safe default
                    // advance rr_ptr for next arbitration to (selected+1)
                    rr_ptr <= (next_select + 1) % N;
                end else begin
                    // no requests => idle
                    gnt <= {N{1'b0}};
                    grant_valid <= 1'b0;
                    lock_count <= 0;
                end
            end

            // ----------------------------
            // Starvation counters update
            // - If a master is requesting but not granted -> increment
            // - If granted or not requesting -> clear counter
            // - Saturate at STARVE_LIMIT (no overflow)
            // ----------------------------
            for (i = 0; i < N; i = i + 1) begin
                if (gnt[i]) begin
                    starve_cnt[i] <= 0;
                end else begin
                    if (req[i]) begin
                        if (starve_cnt[i] < STARVE_LIMIT)
                            starve_cnt[i] <= starve_cnt[i] + 1;
                        else
                            starve_cnt[i] <= starve_cnt[i]; // saturate
                    end else begin
                        starve_cnt[i] <= 0;
                    end
                end
            end
        end
    end

endmodule
