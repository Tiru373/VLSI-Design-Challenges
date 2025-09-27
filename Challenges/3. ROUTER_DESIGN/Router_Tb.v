`timescale 1ns/1ps
module router_tb();

    parameter DATA_WIDTH = 8;

    reg clk, rst_n;
    reg [DATA_WIDTH-1:0] din;
    reg [1:0] addr;
    reg valid_in;
    wire ready_out;

    wire [DATA_WIDTH-1:0] dout0, dout1, dout2, dout3;
    wire valid_out0, valid_out1, valid_out2, valid_out3;
    reg ready_in0, ready_in1, ready_in2, ready_in3;

    // DUT
    router #(DATA_WIDTH) dut (
        .clk(clk), .rst_n(rst_n),
        .din(din), .addr(addr), .valid_in(valid_in), .ready_out(ready_out),
        .dout0(dout0), .dout1(dout1), .dout2(dout2), .dout3(dout3),
        .valid_out0(valid_out0), .valid_out1(valid_out1),
        .valid_out2(valid_out2), .valid_out3(valid_out3),
        .ready_in0(ready_in0), .ready_in1(ready_in1),
        .ready_in2(ready_in2), .ready_in3(ready_in3)
    );

    // Clock
    always #5 clk = ~clk;

    initial begin
        clk = 0; rst_n = 0; din = 0; addr = 0; valid_in = 0;
        ready_in0 = 1; ready_in1 = 1; ready_in2 = 1; ready_in3 = 1;
        #12 rst_n = 1;

        // Test 1: Send data to dout0
        @(posedge clk);
        din = 8'hA1; addr = 2'b00; valid_in = 1;
        @(posedge clk); valid_in = 0;

        // Test 2: Send data to dout2
        @(posedge clk);
        din = 8'hB2; addr = 2'b10; valid_in = 1;
        @(posedge clk); valid_in = 0;

        // Test 3: Backpressure on dout3
        @(posedge clk);
        ready_in3 = 0; // Block output 3
        din = 8'hC3; addr = 2'b11; valid_in = 1;
        @(posedge clk);
        $display("Expect stall: ready_out=%b", ready_out);
        valid_in = 0; ready_in3 = 1;

        #20 $finish;
    end

endmodule
