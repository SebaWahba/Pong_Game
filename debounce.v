`timescale 1ns / 1ps

module debouncer(
    input clk,
    input in,
    output out
    );
    
    reg r1, r2, r3;
    
    always @(posedge clk) begin
        r1 <= in;
        r2 <= r1;
        r3 <= r2;
    end
    
    assign out = r3;
    
endmodule
