`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2026 10:40:00 PM
// Design Name: 
// Module Name: swap
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
module swap(
input wire [7:0] in0, in1,
output wire [7:0] S, L // Small - Large
    );
wire temp = (in0 > in1);
assign S = (temp)? in1: in0;
assign L = (temp)? in0: in1;
endmodule
