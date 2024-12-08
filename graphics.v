`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 09:16:10 PM
// Design Name: 
// Module Name: graphics
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


module graphics(input clk, reset, [1:0] up, down, input gra_still, video_on, [9:0] x, [9:0] y, output graph_on, reg hit, hit2, miss, output reg [11:0] graph_rgb);
   
    // maximum x, y values in display area
    parameter X_MAX = 639;
    parameter Y_MAX = 479;
   
    // create 60Hz refresh tick
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0; // start of vsync(vertical retrace)
   
   
    parameter X_PAD_L = 600;
    parameter X_PAD_R = 603;    // 4 pixels wide
   
    parameter X_PAD2_L = 32;    
    parameter X_PAD2_R = 35;  
   
   
    wire [9:0] y_pad_t, y_pad_b, y_pad2_t, y_pad2_b;
    parameter PAD_HEIGHT = 72;  // 72 pixels high
    // register to track top boundary and buffer
    reg [9:0] y_pad_reg = 204,y_pad2_reg=204;      // Paddle starting position
    reg [9:0] y_pad_next, y_pad2_next;
    // paddle moving velocity when a button is pressed
    parameter PAD_VELOCITY = 3;     // change to speed up or slow down paddle movement
   
   
    // BALL
    // square rom boundaries
    parameter BALL_SIZE = 8;
    // ball horizontal boundary signals
    wire [9:0] x_ball_l, x_ball_r;
    // ball vertical boundary signals
    wire [9:0] y_ball_t, y_ball_b;
    // register to track top left position
    reg [9:0] y_ball_reg, x_ball_reg;
    // signals for register buffer
    wire [9:0] y_ball_next, x_ball_next;
    // registers to track ball speed and buffers
    reg [9:0] x_delta_reg, x_delta_next;
    reg [9:0] y_delta_reg, y_delta_next;
    // positive or negative ball velocity
    parameter BALL_VELOCITY_POS = 1;    // ball speed positive pixel direction(down, right)
    parameter BALL_VELOCITY_NEG = -1;   // ball speed negative pixel direction(up, left)
    // round ball from square image
    wire [2:0] rom_addr, rom_col;   // 3-bit rom address and rom column
    reg [7:0] rom_data;             // data at current rom address
    wire rom_bit;                   // signify when rom data is 1 or 0 for ball rgb control
   
   
    // Register Control
    always @(posedge clk or posedge reset)
        if(reset) begin
            y_pad2_reg <= 204;
            y_pad_reg <= 204;
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
   
   
    // ball rom
    always @*
        case(rom_addr)
            3'b000 :    rom_data = 8'b00111100; //   ****  
            3'b001 :    rom_data = 8'b01111110; //  ******
            3'b010 :    rom_data = 8'b11111111; // ********
            3'b011 :    rom_data = 8'b11111111; // ********
            3'b100 :    rom_data = 8'b11111111; // ********
            3'b101 :    rom_data = 8'b11111111; // ********
            3'b110 :    rom_data = 8'b01111110; //  ******
            3'b111 :    rom_data = 8'b00111100; //   ****
        endcase
   
   
    // OBJECT STATUS SIGNALS
    wire pad2_on,pad_on, sq_ball_on, ball_on;
    wire [11:0] pad2_rgb, pad_rgb, ball_rgb, bg_rgb;
   
   
   
    assign pad_rgb    = 12'hFFF;
    assign pad2_rgb = 12'hFFF;
    assign ball_rgb   = 12'hFFF;
    assign bg_rgb     = 12'h000;  
   
   
    // paddle
    assign y_pad_t = y_pad_reg;                             // paddle top position
    assign y_pad_b = y_pad_t + PAD_HEIGHT - 1;              // paddle bottom position
    assign pad_on = (X_PAD_L <= x) && (x <= X_PAD_R) &&     // pixel within paddle boundaries
                    (y_pad_t <= y) && (y <= y_pad_b);
                   
                   
    assign y_pad2_t = y_pad2_reg;                            
    assign y_pad2_b = y_pad2_t + PAD_HEIGHT - 1;              
    assign pad2_on = (X_PAD2_L <= x) && (x <= X_PAD2_R) &&    
                    (y_pad2_t <= y) && (y <= y_pad2_b);              
       
    // Paddle Control
    always @* begin
        y_pad_next = y_pad_reg;     // no move
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
   
   
    // rom data square boundaries
    assign x_ball_l = x_ball_reg;
    assign y_ball_t = y_ball_reg;
    assign x_ball_r = x_ball_l + BALL_SIZE - 1;
    assign y_ball_b = y_ball_t + BALL_SIZE - 1;
    // pixel within rom square boundaries
    assign sq_ball_on = (x_ball_l <= x) && (x <= x_ball_r) &&
                        (y_ball_t <= y) && (y <= y_ball_b);
                       
    // map current pixel location to rom addr/col
    assign rom_addr = y[2:0] - y_ball_t[2:0];   // 3-bit address
    assign rom_col = x[2:0] - x_ball_l[2:0];    // 3-bit column index
    assign rom_bit = rom_data[rom_col];         // 1-bit signal rom data by column
    // pixel within round ball
    assign ball_on = sq_ball_on & rom_bit;      // within square boundaries AND rom data bit == 1
 
 
    // new ball position
    assign x_ball_next = (gra_still) ? X_MAX / 2 :
                         (refresh_tick) ? x_ball_reg + x_delta_reg : x_ball_reg;
    assign y_ball_next = (gra_still) ? Y_MAX / 2 :
                         (refresh_tick) ? y_ball_reg + y_delta_reg : y_ball_reg;
   
    // change ball direction after collision
    always @* begin
        hit = 1'b0;
        hit2 = 1'b0;
        miss = 1'b0;
        x_delta_next = x_delta_reg;
        y_delta_next = y_delta_reg;
       
        if(gra_still) begin
            x_delta_next = BALL_VELOCITY_NEG;
            y_delta_next = BALL_VELOCITY_POS;
        end
        else if(y_ball_t < 1)                                            
            y_delta_next = BALL_VELOCITY_POS;                      
        else if(y_ball_b > Y_MAX)                                  
            y_delta_next = BALL_VELOCITY_NEG;
                     
        else if((X_PAD_L <= x_ball_r) && (x_ball_r <= X_PAD_R) &&
                (y_pad_t <= y_ball_b) && (y_ball_t <= y_pad_b)) begin
                    x_delta_next = BALL_VELOCITY_NEG;
                    hit = 1'b1;
                    end
        else if((X_PAD2_L <= x_ball_r) && (x_ball_r <= X_PAD2_R) &&
                (y_pad2_t <= y_ball_b) && (y_ball_t <= y_pad2_b)) begin  
                x_delta_next = BALL_VELOCITY_POS;  
                hit2 = 1'b1;  
        end
       
        else if(x_ball_r > X_MAX | x_ball_l <10)
            miss = 1'b1;
    end                    
   
    // output status signal for graphics
    assign graph_on = pad2_on | pad_on | ball_on;
   
   
    // rgb multiplexing circuit
    always @*
        if(~video_on)
            graph_rgb = 12'h000;      // no value, blank
        else
            if(pad_on)
                graph_rgb = pad_rgb;      // paddle color
            else if(pad2_on)
                graph_rgb = pad2_rgb;      // paddle color
            else if(ball_on)
                graph_rgb = ball_rgb;     // ball color
            else
                graph_rgb = bg_rgb;       // background
       
endmodule
