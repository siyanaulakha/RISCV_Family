`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.06.2025 04:08:52
// Design Name: 
// Module Name: mux2
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



// mux2.v - logic for 2-to-1 multiplexer

module mux2 #(parameter WIDTH = 8) (
    input       [WIDTH-1:0] d0, d1,
    input       sel,
    output      [WIDTH-1:0] y
);

assign y = sel ? d1 : d0;

endmodule


