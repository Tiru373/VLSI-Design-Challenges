//=====================================================
// 1x4 Router Design
// Routes input data to one of 4 outputs based on addr
// With valid/ready handshake
//=====================================================
module router #(
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,

    // Input interface
    input  wire [DATA_WIDTH-1:0] din,
    input  wire [1:0]            addr,
    input  wire                  valid_in,
    output wire                  ready_out,

    // Output interfaces
    output reg  [DATA_WIDTH-1:0] dout0, dout1, dout2, dout3,
    output reg                   valid_out0, valid_out1, valid_out2, valid_out3,
    input  wire                  ready_in0, ready_in1, ready_in2, ready_in3
);

    // Ready logic: only ready if target output is ready
    assign ready_out = (addr == 2'b00) ? ready_in0 :
                       (addr == 2'b01) ? ready_in1 :
                       (addr == 2'b10) ? ready_in2 :
                                         ready_in3;

    // Sequential transfer logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dout0 <= 0; dout1 <= 0; dout2 <= 0; dout3 <= 0;
            valid_out0 <= 0; valid_out1 <= 0; valid_out2 <= 0; valid_out3 <= 0;
        end else begin
            // Clear all valid signals
            valid_out0 <= 0;
            valid_out1 <= 0;
            valid_out2 <= 0;
            valid_out3 <= 0;

            if (valid_in && ready_out) begin
                case (addr)
                    2'b00: begin dout0 <= din; valid_out0 <= 1; end
                    2'b01: begin dout1 <= din; valid_out1 <= 1; end
                    2'b10: begin dout2 <= din; valid_out2 <= 1; end
                    2'b11: begin dout3 <= din; valid_out3 <= 1; end
                endcase
            end
        end
    end

endmodule
