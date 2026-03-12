`timescale 1ns / 1ps

module tb_shift_register();

    reg clk;
    reg rst;
    reg [7:0] a_i;
    wire [7:0] a0, a1, a2, a3;

    shift_register #(8) uut (
        .clk(clk),
        .rst(rst),
        .a_i(a_i),
        .a0(a0),
        .a1(a1),
        .a2(a2),
        .a3(a3)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        // Buoc 1: Reset he thong
        rst = 1; a_i = 0;
        #10 rst = 0; // Sau 10ns thi tat reset

        // Buoc 2: Dua du lieu vao va quan sat su dich chuyen
        #10 a_i = 8'd11; // a0 se nhan 11
        #10 a_i = 8'd22; // a0 nhan 22, 11 dich sang a1
        #10 a_i = 8'd33; // a0 nhan 33, 22 -> a1, 11 -> a2
        #10 a_i = 8'd44; // Day thanh ghi (a3 nhan 11)
        
        #50 $stop;
    end

    initial begin
        $monitor("Thoi gian=%0t | In=%d | a0=%d | a1=%d | a2=%d | a3=%d", 
                 $time, a_i, a0, a1, a2, a3);
    end

endmodule