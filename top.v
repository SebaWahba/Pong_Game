`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2024 12:16:35 PM
// Design Name: 
// Module Name: top
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
module top(
    input clk,       
    input reset,            
    input[1:0] up,               
    input[1:0] down,             
    output hsync,           
    output vsync,           
    output [11:0] rgb       
    );
    
    wire w_reset,w_vid_on, w_p_tick;
    wire [1:0] w_up, w_down;
    wire [9:0] w_x, w_y;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    
    vga_controller vga(.clk(clk), .reset(w_reset), .video_on(w_vid_on),
                       .hsync(hsync), .vsync(vsync), .p_tick(w_p_tick), .x(w_x), .y(w_y));
    pixels pg(.clk(clk), .reset(w_reset), .up(w_up), .down(w_down), 
                 .video_on(w_vid_on), .xpos(w_x), .ypos(w_y), .rgb(rgb_next));
    debouncer R(.clk(clk), .in(reset), .out(w_reset));
    debouncer U1(.clk(clk), .in(up[0]), .out(w_up[0]));
    debouncer D1(.clk(clk), .in(down[0]), .out(w_down[0]));
    
    debouncer U2(.clk(clk), .in(up[1]), .out(w_up[1]));
    debouncer D2(.clk(clk), .in(down[1]), .out(w_down[1]));
    

    always @(posedge clk)
        if(w_p_tick)
            rgb_reg <= rgb_next;
            
    assign rgb = rgb_reg;
    
endmodule
