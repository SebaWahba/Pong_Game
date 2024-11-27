`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2024 12:10:19 PM
// Design Name: 
// Module Name: pixels
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
module pixels(
    input clk,  
    input reset,    
    input[1:0] up,
    input[1:0] down,
    input video_on,
    input [9:0] xpos,
    input [9:0] ypos,
    output reg [11:0] rgb
    );
    
    parameter X_MAX = 639;
    parameter Y_MAX = 479;
    
    wire refresh_tick;
    assign refresh_tick = ((ypos == 481) && (xpos == 0)) ? 1 : 0; 
    
    parameter X_PAD_L = 600;
    parameter X_PAD_R = 603;   
    
    parameter X_PAD2_L = 32;    
    parameter X_PAD2_R = 35;    
    
    wire [9:0] y_pad_t, y_pad_b, y_pad2_t, y_pad2_b;
    parameter PAD_HEIGHT = 72;  
    reg [9:0] y_pad_reg, y_pad_next, y_pad2_reg, y_pad2_next;
    parameter PAD_VELOCITY = 3;     
    
    parameter BALL_SIZE = 8;
    wire [9:0] x_ball_l, x_ball_r;
    wire [9:0] y_ball_t, y_ball_b;
    reg [9:0] y_ball_reg, x_ball_reg;
    wire [9:0] y_ball_next, x_ball_next;
    reg [9:0] x_delta_reg, x_delta_next;
    reg [9:0] y_delta_reg, y_delta_next;
    parameter BALL_VELOCITY_POS = 1;
    parameter BALL_VELOCITY_NEG = -1;
    wire [2:0] rom_addr, rom_col;   
    reg [7:0] rom_data;             
    wire rom_bit;                   
    
    always @(posedge clk or posedge reset)
        if(reset) begin
            y_pad_reg <= 0;
            y_pad2_reg <= 0;
            x_ball_reg <= 0;
            y_ball_reg <= 0;
            x_delta_reg <= 10'h002;
            y_delta_reg <= 10'h002;
        end
        else begin
            y_pad_reg <= y_pad_next;
            y_pad2_reg <= y_pad2_next;
            x_ball_reg <= x_ball_next;
            y_ball_reg <= y_ball_next;
            x_delta_reg <= x_delta_next;
            y_delta_reg <= y_delta_next;
        end
    
    always @*
        case(rom_addr)
            3'b000 :    rom_data = 8'b00111100;   
            3'b001 :    rom_data = 8'b01111110; 
            3'b010 :    rom_data = 8'b11111111; 
            3'b011 :    rom_data = 8'b11111111; 
            3'b100 :    rom_data = 8'b11111111; 
            3'b101 :    rom_data = 8'b11111111; 
            3'b110 :    rom_data = 8'b01111110; 
            3'b111 :    rom_data = 8'b00111100; 
        endcase
    
    wire pad2_on, pad_on, sq_ball_on, ball_on;
    wire [11:0] pad2_rgb, pad_rgb, ball_rgb, bg_rgb;
    
    assign pad_rgb = 12'hAAA;      
    assign pad2_rgb = 12'hAAA;      
    assign ball_rgb = 12'hFFF;      
    assign bg_rgb = 12'hBAF;       
    
    assign y_pad_t = y_pad_reg;                             
    assign y_pad_b = y_pad_t + PAD_HEIGHT - 1;              
    assign pad_on = (X_PAD_L <= xpos) && (xpos <= X_PAD_R) &&     
                    (y_pad_t <= ypos) && (ypos <= y_pad_b);
                    
    assign y_pad2_t = y_pad2_reg;                             
    assign y_pad2_b = y_pad2_t + PAD_HEIGHT - 1;              
    assign pad2_on = (X_PAD2_L <= xpos) && (xpos <= X_PAD2_R) &&     
                    (y_pad2_t <= ypos) && (ypos <= y_pad2_b);
                    
    always @* begin
        y_pad_next = y_pad_reg;     
        y_pad2_next = y_pad2_reg;    
        if(refresh_tick)
        begin
            if(up[0] & (y_pad_t > PAD_VELOCITY))
                y_pad_next = y_pad_reg - PAD_VELOCITY;  
            else if(down[0] & (y_pad_b < (Y_MAX - PAD_VELOCITY)))
                y_pad_next = y_pad_reg + PAD_VELOCITY; 
                
            if(up[1] & (y_pad2_t > PAD_VELOCITY))
                y_pad2_next = y_pad2_reg - PAD_VELOCITY;  
            else if(down[1] & (y_pad2_b < (Y_MAX - PAD_VELOCITY)))
                y_pad2_next = y_pad2_reg + PAD_VELOCITY;  
         end
    end
    
    assign x_ball_l = x_ball_reg;
    assign y_ball_t = y_ball_reg;
    assign x_ball_r = x_ball_l + BALL_SIZE - 1;
    assign y_ball_b = y_ball_t + BALL_SIZE - 1;
    assign sq_ball_on = (x_ball_l <= xpos) && (xpos <= x_ball_r) &&
                        (y_ball_t <= ypos) && (ypos <= y_ball_b);
                        
    assign rom_addr = ypos[2:0] - y_ball_t[2:0];  
    assign rom_col = xpos[2:0] - x_ball_l[2:0];   
    assign rom_bit = rom_data[rom_col];         
    assign ball_on = sq_ball_on & rom_bit;     
    assign x_ball_next = (refresh_tick) ? x_ball_reg + x_delta_reg : x_ball_reg;
    assign y_ball_next = (refresh_tick) ? y_ball_reg + y_delta_reg : y_ball_reg;
    
    always @* begin
        x_delta_next = x_delta_reg;
        y_delta_next = y_delta_reg;
        if(y_ball_t < 1)                                            
            y_delta_next = BALL_VELOCITY_POS;                       
        else if(y_ball_b > Y_MAX)                                   
            y_delta_next = BALL_VELOCITY_NEG;                       
        else if((X_PAD_L <= x_ball_r) && (x_ball_r <= X_PAD_R) &&
                (y_pad_t <= y_ball_b) && (y_ball_t <= y_pad_b))     
            x_delta_next = BALL_VELOCITY_NEG;                       
        else if((X_PAD2_L <= x_ball_r) && (x_ball_r <= X_PAD2_R) &&
                (y_pad2_t <= y_ball_b) && (y_ball_t <= y_pad2_b))   
            x_delta_next = BALL_VELOCITY_POS;                       
    end                    
    
    always @*
        if(~video_on)
            rgb = 12'h000;      
        else
            if(pad2_on)
                rgb = pad2_rgb;     
            else if(pad_on)
                rgb = pad_rgb;      
            else if(ball_on)
                rgb = ball_rgb;     
            else
                rgb = bg_rgb;       
       
endmodule
