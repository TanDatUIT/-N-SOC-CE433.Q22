`timescale 1ns / 1ps

module tb_median_filter_part2();
    reg clk, rst_n;
    reg [7:0] in0, in1, in2, in3, in4, in5, in6, in7, in8;
    wire [7:0] median;

    // Clock 400MHz
    initial clk = 0;
    always #1.25 clk = ~clk;

    median_filter dut (clk, rst_n, in0, in1, in2, in3, in4, in5, in6, in7, in8, median);

    task check(input [7:0] i0, i1, i2, i3, i4, i5, i6, i7, i8, input [7:0] exp);
        begin
            {in0, in1, in2, in3, in4, in5, in6, in7, in8} = {i0, i1, i2, i3, i4, i5, i6, i7, i8};
            repeat(10) @(posedge clk); #0.1;
            if (median === exp) $display("[PASS] Input: %d... -> Median: %d", i0, median);
            else $display("[FAIL] Input: %d... -> Expected: %d, Got: %d", i0, exp, median);
        end
    endtask

    initial begin
        rst_n = 0; #10 rst_n = 1;
        $display("--- BAT DAU TEST ---");

        // M?C 1: TU?N T? & S?P X?P
        check(10, 11, 12, 13, 14, 15, 16, 17, 18, 14);
        check(255, 250, 240, 230, 220, 210, 200, 190, 180, 220);
        check(5, 10, 15, 20, 25, 30, 35, 40, 45, 25);
        check(2, 4, 6, 8, 10, 12, 14, 16, 18, 10);
        check(100, 90, 80, 70, 60, 50, 40, 30, 20, 60);
        check(1, 1, 2, 2, 3, 3, 4, 4, 5, 3);
        check(120, 121, 122, 123, 124, 125, 126, 127, 128, 124);
        check(0, 5, 10, 15, 20, 25, 30, 35, 40, 20);
        check(99, 88, 77, 66, 55, 44, 33, 22, 11, 55);
        check(30, 31, 32, 33, 34, 35, 36, 37, 38, 34);

        // M?C 2: NHI?U MU?I TIÊU
        check(0, 0, 0, 0, 0, 1, 2, 3, 255, 0);
        check(255, 255, 255, 255, 255, 200, 150, 100, 0, 255);
        check(0, 255, 0, 255, 0, 255, 0, 255, 50, 50);
        check(255, 0, 255, 0, 255, 0, 255, 0, 180, 255);
        check(0, 0, 255, 255, 75, 76, 77, 78, 79, 77);
        check(10, 20, 0, 0, 0, 255, 255, 255, 255, 0);
        check(128, 0, 0, 0, 255, 255, 255, 255, 129, 129);
        check(0, 255, 12, 13, 14, 15, 16, 0, 255, 14);
        check(255, 255, 255, 0, 0, 0, 40, 41, 42, 41);
        check(0, 0, 0, 0, 10, 11, 12, 13, 14, 10);

        // M?C 3: NG?U NHIÊN & L?P L?I
        check(15, 15, 15, 15, 15, 2, 3, 4, 5, 15);
        check(100, 200, 100, 200, 100, 200, 100, 200, 150, 150);
        check(7, 12, 5, 19, 1, 33, 22, 11, 8, 11);
        check(50, 60, 50, 60, 50, 60, 50, 60, 55, 55);
        check(1, 2, 3, 1, 2, 3, 1, 2, 3, 2);
        check(80, 80, 80, 20, 20, 20, 50, 50, 50, 50);
        check(12, 99, 45, 67, 2, 8, 31, 54, 20, 31);
        check(255, 255, 0, 0, 128, 128, 64, 64, 192, 128);
        check(10, 10, 10, 20, 20, 20, 5, 5, 5, 10);
        check(9, 1, 8, 2, 7, 3, 6, 4, 5, 5);

        $display("--- KET THUC ---"); $finish;
    end
endmodule