`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 09:16:10 PM
// Design Name: 
// Module Name: Top
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
module Top(input clk, reset, [1:0] up,down, output hsync, vsync, [11:0] rgb, reg [6:0] segments, reg [3:0] anode_active, output reg sounds);
   
   //game states
    parameter newgame = 2'b00, play = 2'b01, newball = 2'b10, gameOver = 2'b11;
   

    // signal declaration
    reg [1:0] state_reg, state_next;
    wire [9:0] w_x, w_y;
    wire w_vid_on, w_p_tick, graph_on, hit, hit2, miss;
    wire [3:0] text_on;
    wire [11:0] graph_rgb, text_rgb;
    reg [11:0] rgb_reg, rgb_next;
    wire [3:0] dig0, dig1,dig2,dig3;
    reg gra_still, d_inc, d_inc2, d_clr, d_clr2, timer_start;
    wire timer_tick, timer_up;
    reg [4:0] ball_reg, ball_next;
    wire [1:0] chosendigit;
    wire segclock;
   
    // Module Instantiations
    vga_controller vga_unit(.clk_100MHz(clk), .reset(reset), .video_on(w_vid_on), .hsync(hsync), .vsync(vsync), .p_tick(w_p_tick), .x(w_x), .y(w_y));
   
    text t(.clk(clk), .x(w_x), .y(w_y), .dig0(dig0), .dig1(dig1), .dig2(dig2), .dig3(dig3), .ball(ball_reg), .text_on(text_on), .text_rgb(text_rgb));
       
    graphics g(.clk(clk), .reset(reset), .up(up), .down(down), .gra_still(gra_still), .video_on(w_vid_on), .x(w_x), .y(w_y), .hit(hit), .hit2(hit2), .miss(miss), .graph_on(graph_on), .graph_rgb(graph_rgb));
   
    score_counter sc1(.clk(clk), .reset(reset), .clear(d_clr) , .increment(d_inc), .tens(dig1), .ones(dig0));
   
    score_counter sc2(.clk(clk), .reset(reset), .clear(d_clr) , .increment(d_inc2), .tens(dig3), .ones(dig2));
    
    clock_divider c1 (.clk(clk),.rst(reset),.clk_out(segclock));
    
    counter segmentscounter (.clk(segclock),.reset(reset),.enable(1'b1),.count(chosendigit));
    
    // 60 Hz tick when screen is refreshed
    assign timer_tick = (w_x == 0) && (w_y == 0);
    timer ti(.clk(clk), .reset(reset), .timer_tick(timer_tick), .timer_start(timer_start), .timer_up(timer_up));

//SCORE DISPLAY ON 7-SEGMENT
always @* begin
    if(chosendigit == 2'b00)
        begin
        anode_active = 4'b1110;
        case (dig0)
            0: segments = 7'b0000001;
            1: segments = 7'b1001111;
            2: segments = 7'b0010010;
            3: segments = 7'b0000110;
            4: segments = 7'b1001100;
            5: segments = 7'b0100100;
            6: segments = 7'b0100000;
            7: segments = 7'b0001111;
            8: segments = 7'b0000000;
            9: segments = 7'b0001100;
            default: segments = 7'b0000000;  // Blank or anode_active
        endcase
        end
   
    else if(chosendigit == 2'b01)
        begin
        anode_active = 4'b1101;
        case (dig1)
            0: segments = 7'b0000001;
            1: segments = 7'b1001111;
            2: segments = 7'b0010010;
            3: segments = 7'b0000110;
            4: segments = 7'b1001100;
            5: segments = 7'b0100100;
            6: segments = 7'b0100000;
            7: segments = 7'b0001111;
            8: segments = 7'b0000000;
            9: segments = 7'b0001100;
            default: segments = 7'b0000000;  // Blank or anode_active
        endcase
        end    
    else if(chosendigit == 2'b10)
        begin
        anode_active = 4'b1011;
        case (dig2)
            0: segments = 7'b0000001;
            1: segments = 7'b1001111;
            2: segments = 7'b0010010;
            3: segments = 7'b0000110;
            4: segments = 7'b1001100;
            5: segments = 7'b0100100;
            6: segments = 7'b0100000;
            7: segments = 7'b0001111;
            8: segments = 7'b0000000;
            9: segments = 7'b0001100;
            default: segments = 7'b0000000;  // Blank or anode_active
        endcase
        end
    else if(chosendigit == 2'b11)
        begin
        anode_active = 4'b0111;
        case (dig3)
            0: segments = 7'b0000001;
            1: segments = 7'b1001111;
            2: segments = 7'b0010010;
            3: segments = 7'b0000110;
            4: segments = 7'b1001100;
            5: segments = 7'b0100100;
            6: segments = 7'b0100000;
            7: segments = 7'b0001111;
            8: segments = 7'b0000000;
            9: segments = 7'b0001100;
            default: segments = 7'b0000000;  // Blank or anode_active
        endcase
        end
end
       
reg playHit, playOver;
wire soundsHit, soundsOver;
 
   sound_top dut (.clk_100MHz(clk), .play(playHit), .speaker(soundsHit));
   sound_top dut2 (.clk_100MHz(clk), .play(playOver), .speaker(soundsOver));

    // FSMD state and registers
    always @(posedge clk or posedge reset)
        if(reset) begin
            state_reg <= newgame;
            ball_reg <= 0;
            rgb_reg <= 0;
        end
   
        else begin
            state_reg <= state_next;
            ball_reg <= ball_next;
            if(w_p_tick)
                rgb_reg <= rgb_next;
        end
   
    // FSMD next state logic
    always @* begin
        gra_still = 1'b1;
        timer_start = 1'b0;
        d_inc = 1'b0;
        d_inc2 = 1'b0;
        d_clr = 1'b0;
        d_clr2 = 1'b0;
        state_next = state_reg;
        ball_next = ball_reg;
       
        case(state_reg)
            newgame: begin
                ball_next = 5'b01001;          // 9 balls
                d_clr = 1'b1;               // clear score
                d_clr2 = 1'b1;
               
                if(up != 2'b00 | down != 2'b00) begin      // button pressed
                    state_next = play;
                    ball_next = ball_reg - 1;    
                end
            end
           
            play: begin
                gra_still = 1'b0;   // animated screen
               
                if(hit) begin
                    d_inc = 1'b1;   // increment score
                    playHit = 1'b1;
                    end
                else if(hit2)begin
                    d_inc2 = 1'b1;
                    playHit = 1'b1;  // play sound
                    end
                 
                else if(miss) begin
                    if(ball_reg == 0)
                        state_next = gameOver;
                   
                    else
                        state_next = newball;
                   
                    timer_start = 1'b1;     // 2 sec timer
                    ball_next = ball_reg - 1;
                end
            end
           
            newball: // wait for 2 sec and until button pressed
            if(timer_up && (up != 2'b00 | down != 2'b00))
                state_next = play;
               
            gameOver:   // wait 2 sec to display game over
                begin
                    if (timer_up) begin
                        state_next = newgame;
                        playOver = 1'b0;  // Stop the game over sound after the timer is done
                    end
                    else begin
                        playOver = 1'b1;  // Play the game over sound while the game is over
                    end
                end
        endcase          
    end
   
    // rgb multiplexing
    always @*
        if(~w_vid_on)
            rgb_next = 12'h000; // blank
       
        else
            if(text_on[3] || ((state_reg == newgame) && text_on[1]) || ((state_reg == gameOver) && text_on[0]))
                rgb_next = text_rgb;    // colors in text
           
            else if(graph_on)
                rgb_next = graph_rgb;   // colors in graphics
               
            else if(text_on[2])
                rgb_next = text_rgb;    // colors in gameOver
               
            else
                rgb_next = 12'h000;     // black background
   
      // Multiplex between sound outputs based on state 
always @* begin
       if (playHit)
           sounds = soundsHit; // Play hit sound
       else if (playOver)
           sounds = soundsOver; // Play game over sound
       else
           sounds = 1'b0; // No sound
   end
   
    // output
    assign rgb = rgb_reg;
   
endmodule