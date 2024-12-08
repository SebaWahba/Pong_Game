`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 09:51:25 PM
// Design Name: 
// Module Name: A_440Hz
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


module A_440Hz(input clk_100MHz, output o_440Hz    );
   
    // 100MHz / 113,636 / 2 = 440.0014Hz
    reg r_440Hz;
    reg [16:0] r_counter = 0;
   
    always @(posedge clk_100MHz)
        if(r_counter == 17'd113_636) begin
            r_counter <= 0;
            r_440Hz <= ~r_440Hz;
            end
        else
            r_counter <= r_counter + 1;

    assign o_440Hz = r_440Hz;
   
endmodule