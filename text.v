`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 09:16:10 PM
// Design Name: 
// Module Name: text
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

module text(input clk, [4:0] ball, [3:0] dig0, dig1, dig2, dig3, [9:0] x, y, output [3:0] text_on, reg [11:0] text_rgb);
   
    // signal declaration
    wire [10:0] rom_addr;
    reg [6:0] char_addr, char_addr_s, char_addr_l, char_addr_o;
    reg [3:0] row_addr;
    wire [3:0] row_addr_s, row_addr_l, row_addr_o;
    reg [2:0] bit_addr;
    wire [2:0] bit_addr_s, bit_addr_l, bit_addr_o;
    wire [7:0] ascii_word;
    wire ascii_bit, score_on, logo_on, over_on;
   
   // instantiate ascii rom
   ascii_rom ascii(.clk(clk), .addr(rom_addr), .data(ascii_word));
   
   //display score1, score2, remaining balls
   assign score_on = (y >= 32) && (y < 64) && (x[9:4] < 43);
   assign row_addr_s = y[4:1];
   assign bit_addr_s = x[3:1];
   always @*
    case(x[9:4])
        6'h0 : char_addr_s = 7'h53;
        6'h1 : char_addr_s = 7'h43;
        6'h2 : char_addr_s = 7'h6F;
        6'h3 : char_addr_s = 7'h52;
        6'h4 : char_addr_s = 7'h45;
        6'h5 : char_addr_s = 7'h00;
        6'h6 : char_addr_s = 7'h31;
        6'h8 : char_addr_s = 7'h00;
        6'h7 : char_addr_s = 7'h3A;
        6'h9 : char_addr_s = {3'b011, dig3};
        6'hA : char_addr_s = {3'b011, dig2};
        
        6'hB : char_addr_s = 7'h00;
        6'hC : char_addr_s = 7'h00;
        6'hD : char_addr_s = 7'h00;
        6'hE : char_addr_s = 7'h00;
        6'hF : char_addr_s = 7'h00;
        6'h10 : char_addr_s = 7'h00;
        6'h11 : char_addr_s = 7'h42;
        6'h12 : char_addr_s = 7'h41;
        6'h13 : char_addr_s = 7'h4c;        
        6'h14 : char_addr_s = 7'h4c;
        6'h15 : char_addr_s = 7'h3A;
        6'h16 : char_addr_s = 7'h00;
        6'h17 : char_addr_s = {3'b011, ball[3:0]};
        
        6'h18 : char_addr_s = 7'h00;
        6'h19 : char_addr_s = 7'h00;
        6'h1A : char_addr_s = 7'h00;
        6'h1B : char_addr_s = 7'h00;
        6'h1D : char_addr_s = 7'h00;
        6'h1C : char_addr_s = 7'h00;
        6'h1E : char_addr_s = 7'h53;
        6'h1F : char_addr_s = 7'h43;
        6'h20 : char_addr_s = 7'h6F;
        6'h21 : char_addr_s = 7'h52;
        6'h22 : char_addr_s = 7'h45;
        6'h23 : char_addr_s = 7'h00;
        6'h24 : char_addr_s = 7'h32;
        6'h25 : char_addr_s = 7'h3A;
        6'h26 : char_addr_s = {3'b011, dig1};
        6'h27 : char_addr_s = {3'b011, dig0};
        6'h28 : char_addr_s = 7'h00;
        default: char_addr_s = 7'h00; 
    endcase
   
    //display "pong"
    assign logo_on = (y[9:7] == 2) && (3 <= x[9:6]) && (x[9:6] <= 6);
    assign row_addr_l = y[6:3];
    assign bit_addr_l = x[5:3];
    always @*
        case(x[8:6])
            3'o3 :    char_addr_l = 7'h50;
            3'o4 :    char_addr_l = 7'h4F;
            3'o5 :    char_addr_l = 7'h4E;
            default : char_addr_l = 7'h47;
        endcase
        
    //display "game over"
    assign over_on = (y[9:6] == 3) && (5 <= x[9:5]) && (x[9:5] <= 13);
    assign row_addr_o = y[5:2];
    assign bit_addr_o = x[4:2];
    always @*
        case(x[8:5])
            4'h5 : char_addr_o = 7'h47;
            4'h6 : char_addr_o = 7'h41;
            4'h7 : char_addr_o = 7'h4D;
            4'h8 : char_addr_o = 7'h45;
            4'h9 : char_addr_o = 7'h00;
            4'hA : char_addr_o = 7'h4F;
            4'hB : char_addr_o = 7'h56;
            4'hC : char_addr_o = 7'h45;
            default : char_addr_o = 7'h52;
        endcase
   
    // mux for ascii ROM addresses and rgb
    always @* begin
        text_rgb = 12'h000;     // black background
       
        if(score_on) begin
            char_addr = char_addr_s;
            row_addr = row_addr_s;
            bit_addr = bit_addr_s;
            if(ascii_bit)
                text_rgb = 12'hFFF; // white
        end
       
        else if(logo_on) begin
            char_addr = char_addr_l;
            row_addr = row_addr_l;
            bit_addr = bit_addr_l;
            if(ascii_bit)
                text_rgb = 12'hFFF; // white
        end
       
        else begin // game over
            char_addr = char_addr_o;
            row_addr = row_addr_o;
            bit_addr = bit_addr_o;
            if(ascii_bit)
                text_rgb = 12'hFFF; // white
        end        
    end
   
    assign text_on = {score_on, logo_on, over_on};
   
    // ascii ROM interface
    assign rom_addr = {char_addr, row_addr};
    assign ascii_bit = ascii_word[~bit_addr];
     
endmodule