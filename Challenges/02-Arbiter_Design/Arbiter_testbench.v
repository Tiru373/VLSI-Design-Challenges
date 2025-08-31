`timescale 1ns/1ps
// Simple testbench for arbiter.v
// Exercises priority/round-robin selection, starvation promotion, and locked transfers.

module arbiter_tb;
    localparam N = 4;
    localparam CLK_PERIOD = 10;

    reg clk, rst_n;
    reg [N-1:0] req;
    reg [N-1:0] lock_req;
    reg [N-1:0] last;
    wire [N-1:0] gnt;

    // Instantiate DUT
    arbiter #(
        .N(N),
        .STARVE_LIMIT(8),
        .LOCK_MAX(6)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .req(req),
        .lock_req(lock_req),
        .last(last),
        .gnt(gnt)
    );

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Waveform
    initial begin
        $dumpfile("arbiter_tb.vcd");
        $dumpvars(0, arbiter_tb);
    end

    // Test Sequence
    initial begin
        // Initialize
        rst_n = 0;
        req = 0;
        lock_req = 0;
        last = 0;
        #(CLK_PERIOD*3);
        rst_n = 1;
        #(CLK_PERIOD*2);

        $display("=== Test 1: simple simultaneous requests (0..3) ===");
        // All request at once -> should pick RR starting at 0 -> grant 0
        req = 4'b1111;
        #(CLK_PERIOD*2);
        // master 0 finishes
        last = 4'b0001; #(CLK_PERIOD);
        last = 0; req[0] = 0; #(CLK_PERIOD*2);

        $display("=== Test 2: priority + rr fallback ===");
        // keep master0 and master1 high priority repeatedly, master3 low priority persistently
        req = 4'b1001; // m3 and m0 requesting; m0 should be served
        #(CLK_PERIOD*4);
        // keep m0 requesting multiple times, but m3 should eventually get promoted due to starvation
        req = 4'b1001;
        #(CLK_PERIOD*20); // give enough cycles for starvation promotion (STARVE_LIMIT=8)
        req[0] = 0; // let m3 be served
        #(CLK_PERIOD*6);
        req = 0;

        $display("=== Test 3: locked transfer ===");
        // Master 2 requests locked transfer of multiple beats
        req = 4'b0100; lock_req = 4'b0100;
        #(CLK_PERIOD*3);
        // simulate beats, last asserted on final beat
        repeat (4) begin
            last = 0; #(CLK_PERIOD);
        end
        last = 4'b0100; // indicate last beat
        #(CLK_PERIOD);
        last = 0; req = 0; lock_req = 0;
        #(CLK_PERIOD*4);

        $display("=== Test 4: concurrent write/read style (multiple request waves) ===");
        // Burst requests rotating
        req = 4'b0010; #(CLK_PERIOD*2);
        req = 4'b0100; #(CLK_PERIOD*2);
        req = 4'b1000; #(CLK_PERIOD*2);
        req = 4'b0001; #(CLK_PERIOD*6);
        req = 0; #(CLK_PERIOD*5);

        $display("=== TEST DONE ===");
        $finish;
    end

    // Monitor
    always @(posedge clk) begin
        $display("%0t | req=%b lock=%b gnt=%b last=%b", $time, req, lock_req, gnt, last);
    end

endmodule
