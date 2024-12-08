`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 10:46:39 PM
// Design Name: 
// Module Name: A_2000Hz
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


module A_2000Hz(input clk_100MHz, output o_2000Hz);
    // 100 MHz / 2000 Hz / 2 = 50,000
    reg r_2000Hz;
    reg [16:0] r_counter = 0;

    always @(posedge clk_100MHz)
        if(r_counter == 17'd25_000) begin
            r_counter <= 0;
            r_2000Hz <= ~r_2000Hz;  // Toggle to generate the 2 kHz square wave
        end else
            r_counter <= r_counter + 1;

    assign o_2000Hz = r_2000Hz;
endmodule
