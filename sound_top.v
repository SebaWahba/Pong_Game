`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 09:44:50 PM
// Design Name: 
// Module Name: sound_top
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


module sound_top(input clk_100MHz, play, output speaker);
    // Play button debounce
    reg x, y, z;

    always @(posedge clk_100MHz) begin
        x <= play;
        y <= x;
        z <= y;
    end
    assign w_play = z;

    // Signals for each tone
    wire A_440Hz_signal;
    wire A_500Hz_signal;
    wire A_1000Hz_signal;
    wire A_2000Hz_signal;

    // Instantiate tone modules
    A_440Hz t_a (.clk_100MHz(clk_100MHz), .o_440Hz(A_440Hz_signal));
    A_500Hz t_b (.clk_100MHz(clk_100MHz), .o_500Hz(A_500Hz_signal));
    A_1000Hz t_c (.clk_100MHz(clk_100MHz), .o_1000Hz(A_1000Hz_signal));
    A_2000Hz t_d (.clk_100MHz(clk_100MHz), .o_2000Hz(A_2000Hz_signal));

    // State Machine Registers and Delays
    parameter CLK_FREQ = 100_000_000;                   // 100MHz
    parameter integer D_500ms = 0.50000000 * CLK_FREQ;  // 500ms
    parameter integer D_break = 0.10000000 * CLK_FREQ;  // 100ms

    reg [25:0] count = 26'b0;
    reg counter_clear = 1'b0;
    reg flag_500ms = 1'b0;
    reg flag_break = 1'b0;
    reg [2:0] state;

    always @(posedge clk_100MHz) begin
        // reaction to counter_clear signal
        if(counter_clear) begin
            count <= 26'b0;
            counter_clear <= 1'b0;
            flag_500ms <= 1'b0;
        end

        // set flags based on count
        if(!counter_clear) begin
            count <= count + 1;
            if(count == D_break) begin
                flag_break <= 1'b1;
            end
            if(count == D_500ms) begin
                flag_500ms <= 1'b1;
            end
        end

        // State Machine (Game Over Sequence)
        case(state)
            3'b000 : begin  // Initial state
                counter_clear <= 1'b1;
                if(w_play) begin
                    state <= 3'b001;  // Start sound sequence
                end    
            end

            3'b001 : begin  // Play 500 Hz for 500ms
                if(flag_500ms) begin
                    counter_clear <= 1'b1;
                    state <= 3'b010;
                end
            end

            3'b010 : begin  // Play 1000 Hz for 500ms
                if(flag_500ms) begin
                    counter_clear <= 1'b1;
                    state <= 3'b011;
                end
            end

            3'b011 : begin  // Play 2000 Hz for 500ms
                if(flag_500ms) begin
                    counter_clear <= 1'b1;
                    state <= 3'b100;
                end
            end

            3'b100 : begin  // Play 440 Hz (or any end tone) for 500ms
                if(flag_500ms) begin
                    counter_clear <= 1'b1;
                    state <= 3'b000;  // End of sound sequence
                end
            end
        endcase
    end

    // Output to speaker: Choose tone based on state
    assign speaker = (w_play) ? 
                     (state == 3'b001 ? A_500Hz_signal :
                      state == 3'b010 ? A_1000Hz_signal :
                      state == 3'b011 ? A_2000Hz_signal :
                      state == 3'b100 ? A_440Hz_signal : 1'b0) : 1'b0;
endmodule