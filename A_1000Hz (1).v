`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 09:51:25 PM
// Design Name: 
// Module Name: A_1000Hz
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


module A_1000Hz(input clk_100MHz, output o_1000Hz);

    // 100 MHz / 1000 Hz / 2 = 50,000
    reg r_1000Hz;
    reg [16:0] r_counter = 0;

    always @(posedge clk_100MHz)
        if(r_counter == 17'd50_000) begin
            r_counter <= 0;
            r_1000Hz <= ~r_1000Hz;  // Toggle to generate the 1 kHz square wave
        end else
            r_counter <= r_counter + 1;

    assign o_1000Hz = r_1000Hz;

endmodule
