`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2024 12:06:11 PM
// Design Name: 
// Module Name: vga_controller
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
module vga_controller(
    input clk,   
    input reset,        
    output video_on,    
    output hsync,       
    output vsync,       
    output p_tick,      
    output [9:0] x,     
    output [9:0] y      
    );
    
    parameter HD = 640;             
    parameter HF = 24;             
    parameter HB = 16;              
    parameter HR = 96;             
    parameter HMAX = HD+HF+HB+HR-1; 
    parameter VD = 480;             
    parameter VF = 10;                
    parameter VB = 33;                 
    parameter VR = 2;                
    parameter VMAX = VD+VF+VB+VR-1;  
    
	reg  [1:0] counter;
	wire clkOut;
	
	always @(posedge clk or posedge reset)
		if(reset)
		  counter <= 0;
		else
		  counter <= counter + 1;
	
	assign clkOut = (counter == 0) ? 1 : 0; 
    
    reg [9:0] h_count_reg, h_count_next;
    reg [9:0] v_count_reg, v_count_next;
    
    reg v_sync_reg, h_sync_reg;
    wire v_sync_next, h_sync_next;
    
    always @(posedge clk or posedge reset)
        if(reset) begin
            v_count_reg <= 0;
            h_count_reg <= 0;
            v_sync_reg  <= 1'b0;
            h_sync_reg  <= 1'b0;
        end
        else begin
            v_count_reg <= v_count_next;
            h_count_reg <= h_count_next;
            v_sync_reg  <= v_sync_next;
            h_sync_reg  <= h_sync_next;
        end
         
    always @(posedge clkOut or posedge reset)      
        if(reset)
            h_count_next = 0;
        else
            if(h_count_reg == HMAX)                
                h_count_next = 0;
            else
                h_count_next = h_count_reg + 1;         
  
    always @(posedge clkOut or posedge reset)
        if(reset)
            v_count_next = 0;
        else
            if(h_count_reg == HMAX)                 
                if((v_count_reg == VMAX))         
                    v_count_next = 0;
                else
                    v_count_next = v_count_reg + 1;
        
    assign h_sync_next = (h_count_reg >= (HD+HB) && h_count_reg <= (HD+HB+HR-1));
    
    assign v_sync_next = (v_count_reg >= (VD+VB) && v_count_reg <= (VD+VB+VR-1));
    

    assign video_on = (h_count_reg < HD) && (v_count_reg < VD); 
            
 
    assign hsync  = h_sync_reg;
    assign vsync  = v_sync_reg;
    assign x      = h_count_reg;
    assign y      = v_count_reg;
    assign p_tick = clkOut;
            
endmodule