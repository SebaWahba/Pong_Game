`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 09:48:13 PM
// Design Name: 
// Module Name: counter
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


module counter #(parameter x = 2, n = 4)
(input clk, reset,enable, output [x-1:0] count);
reg [x-1:0] count;
always @(posedge clk, posedge reset) begin
 if (reset == 1)
 count <= 0; // non-blocking assignment
 // initialize flip flop here
 else if(enable==1) begin
    if (count == n-1)
    count <= 0; // non-blocking assignment
 // reach count end and get back to zero
    else
    count <= count + 1;
  end
  // non-blocking assignment
 // normal operation
 end
 endmodule
