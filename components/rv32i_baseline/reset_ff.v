`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.06.2025 04:10:24
// Design Name: 
// Module Name: reset_ff
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



// reset_ff.v - 8-bit resettable D flip-flop

module reset_ff #(parameter WIDTH = 8) (
    input       clk, rst,
    input       [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q
);

always @(posedge clk or posedge rst) begin
    if (rst) q <= 0;
    else     q <= d;
end

endmodule


