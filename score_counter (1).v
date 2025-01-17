`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 09:16:10 PM
// Design Name: 
// Module Name: score_counter
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


module score_counter(input clk, reset, increment, clear, output reg [3:0] tens, ones);
   
    reg [7:0] score;
    reg increment_d;
    reg increment_edge;
   

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            increment_d <= 1'b0;
            increment_edge <= 1'b0;
        end else begin
            increment_d <= increment;
            increment_edge <= increment & ~increment_d;
        end
    end
   

    always @(posedge clk or posedge reset) begin
        if (reset || clear) begin
            score <= 8'b0;
        end else if (increment_edge) begin
            if (score < 99)
                score <= score + 1;
            else
                score <= 99;
        end
    end
   

    always @(score) begin
        tens = score / 10;
        ones = score % 10;
    end
endmodule