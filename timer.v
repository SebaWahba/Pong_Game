`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 09:44:50 PM
// Design Name: 
// Module Name: timer
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


module timer(input clk, reset, timer_start, timer_tick, output timer_up);
   
    reg [6:0] timer_reg, timer_next;
   
    always @(posedge clk or posedge reset)
        if(reset)
            timer_reg <= 7'b1111111;
        else
            timer_reg <= timer_next;
   
    // next state logic
    always @*
        if(timer_start)
            timer_next = 7'b1111111;
        else if((timer_tick) && (timer_reg != 0))
            timer_next = timer_reg - 1;
        else
            timer_next = timer_reg;
           
    // output
    assign timer_up = (timer_reg == 0);
   
endmodule
