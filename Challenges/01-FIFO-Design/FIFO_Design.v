//=======================================================
// FIFO Without Counter, With Almost Full/Empty
// Author : YourName
//=======================================================
module fifo #(
    parameter DATA_WIDTH = 8,     // Word width
    parameter DEPTH      = 16,    // FIFO depth (must be power of 2)
    parameter ALMST_FULL = 2,     // Programmable Almost Full threshold
    parameter ALMST_EMPTY= 2      // Programmable Almost Empty threshold
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  wr_en,
    input  wire                  rd_en,
    input  wire [DATA_WIDTH-1:0] din,
    output reg  [DATA_WIDTH-1:0] dout,
    output wire                  full,
    output wire                  empty,
    output wire                  almost_full,
    output wire                  almost_empty
);

    //---------------------------------------------------
    // Memory + Pointers
    //---------------------------------------------------
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;

    //---------------------------------------------------
    // Write
    //---------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr] <= din;
            wr_ptr <= wr_ptr + 1'b1;
        end
    end

    //---------------------------------------------------
    // Read
    //---------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
            dout   <= 0;
        end else if (rd_en && !empty) begin
            dout   <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1'b1;
        end
    end

    //---------------------------------------------------
    // Pointer Difference = Occupancy (modulo DEPTH)
    //---------------------------------------------------
    wire [$clog2(DEPTH):0] ptr_diff; // Extra bit to avoid wrap-around
    assign ptr_diff = (wr_ptr >= rd_ptr) ? 
                      (wr_ptr - rd_ptr) : 
                      (DEPTH - (rd_ptr - wr_ptr));

    //---------------------------------------------------
    // Flags
    //---------------------------------------------------
    assign empty        = (wr_ptr == rd_ptr);
    assign full         = (ptr_diff == DEPTH-1);

    assign almost_empty = (ptr_diff <= ALMST_EMPTY);
    assign almost_full  = (ptr_diff >= (DEPTH - ALMST_FULL));

endmodule
