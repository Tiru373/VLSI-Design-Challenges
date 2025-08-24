module fifo_sync #
(
    parameter DEPTH = 16,       // must be power of 2
    parameter WIDTH = 8
)
(
    input  wire                  clk,
    input  wire                  rst,       // synchronous reset (active high)
    input  wire                  write_en,
    input  wire                  read_en,
    input  wire [WIDTH-1:0]      din,
    output reg  [WIDTH-1:0]      dout,
    output wire                  full,
    output wire                  almost_full,
    output wire                  empty,
    output wire                  almost_empty
);

    // Derived params
    localparam PTR_W = $clog2(DEPTH);

    // memory
    reg [WIDTH-1:0] mem [0:DEPTH-1];

    // pointers
    reg [PTR_W-1:0] write_ptr, read_ptr;
    wire [PTR_W-1:0] write_ptr_next = write_ptr + (write_en & ~full);
    wire [PTR_W-1:0] read_ptr_next  = read_ptr  + (read_en  & ~empty);

    // Occupancy (computed from pointer difference, modulo DEPTH)
    // For power-of-two depth: (write_ptr - read_ptr) & (DEPTH-1)
    wire [PTR_W-1:0] occupancy;
    assign occupancy = (write_ptr - read_ptr) & (DEPTH - 1);

    // Status flags (using the usual "one-slot empty" full convention)
    // Max usable occupancy = DEPTH-1
    assign empty        = (occupancy == {PTR_W{1'b0}});
    assign full         = (occupancy == (DEPTH - 1));
    assign almost_full  = (occupancy >= (DEPTH - 2)); // occupancy >= 14 for DEPTH=16
    assign almost_empty = (occupancy <= 2);           // only 2 or fewer entries present

    // Write logic (synchronous)
    always @(posedge clk) begin
        if (rst) begin
            write_ptr <= {PTR_W{1'b0}};
        end else begin
            if (write_en && ~full) begin
                mem[write_ptr] <= din;
                write_ptr <= write_ptr + 1'b1;
            end
        end
    end

    // Read logic (synchronous)
    always @(posedge clk) begin
        if (rst) begin
            read_ptr <= {PTR_W{1'b0}};
            dout <= {WIDTH{1'b0}};
        end else begin
            if (read_en && ~empty) begin
                dout <= mem[read_ptr];
                read_ptr <= read_ptr + 1'b1;
            end
        end
    end

endmodule
