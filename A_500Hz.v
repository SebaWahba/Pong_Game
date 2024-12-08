`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 10:46:39 PM
// Design Name: 
// Module Name: A_500Hz
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


module A_500Hz(input clk_100MHz, output o_500Hz);
    // 100 MHz / 500 Hz / 2 = 100,000
    reg r_500Hz;
    reg [16:0] r_counter = 0;

    always @(posedge clk_100MHz)
        if(r_counter == 17'd100_000) begin
            r_counter <= 0;
            r_500Hz <= ~r_500Hz;  // Toggle to generate the 500 Hz square wave
        end else
            r_counter <= r_counter + 1;

    assign o_500Hz = r_500Hz;
endmodule
