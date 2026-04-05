`timescale 1ns/1ps

module tb_median_filter;

    reg clk;
    reg rst_n;
    reg valid_in;
    reg [7:0] in1, in2, in3, in4, in5, in6, in7, in8, in9;

    wire [7:0] median;
    wire       valid_out;

    reg [7:0] exp0, exp1, exp2, exp3, exp4, exp5;
    integer out_idx;

    median_filter dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .in1(in1), .in2(in2), .in3(in3),
        .in4(in4), .in5(in5), .in6(in6),
        .in7(in7), .in8(in8), .in9(in9),
        .median(median),
        .valid_out(valid_out)
    );

    // clock 100MHz
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // monitor output
    always @(posedge clk) begin
        if (valid_out) begin
            case (out_idx)
                0: begin
                    $display("Input [1 2 3 4 5 6 7 8 9] | expect=%0d | med=%0d | %s",
                             exp0, median, (median==exp0) ? "PASS" : "FAIL");
                end
                1: begin
                    $display("Input [9 1 7 3 5 8 2 6 4] | expect=%0d | med=%0d | %s",
                             exp1, median, (median==exp1) ? "PASS" : "FAIL");
                end
                2: begin
                    $display("Input [5 5 5 1 2 9 10 7 3] | expect=%0d | med=%0d | %s",
                             exp2, median, (median==exp2) ? "PASS" : "FAIL");
                end
                3: begin
                    $display("Input [0 255 1 2 50 100 200 255 0] | expect=%0d | med=%0d | %s",
                             exp3, median, (median==exp3) ? "PASS" : "FAIL");
                end
                4: begin
                    $display("Input [229 119 18 143 242 206 232 197 92] | expect=%0d | med=%0d | %s",
                             exp4, median, (median==exp4) ? "PASS" : "FAIL");
                end
                5: begin
                    $display("Input [8 3 8 3 8 3 8 3 8] | expect=%0d | med=%0d | %s",
                             exp5, median, (median==exp5) ? "PASS" : "FAIL");
                end
            endcase

            out_idx = out_idx + 1;
        end
    end

    initial begin
        // expected value set tay, không dùng for/while
        exp0 = 8'd5;
        exp1 = 8'd5;
        exp2 = 8'd5;
        exp3 = 8'd50;
        exp4 = 8'd197;
        exp5 = 8'd8;

        out_idx = 0;

        rst_n    = 1'b0;
        valid_in = 1'b0;
        in1 = 0; in2 = 0; in3 = 0;
        in4 = 0; in5 = 0; in6 = 0;
        in7 = 0; in8 = 0; in9 = 0;

        #20;
        rst_n = 1'b1;

        // Case 0
        #10;
        valid_in = 1'b1;
        in1 = 1; in2 = 2; in3 = 3;
        in4 = 4; in5 = 5; in6 = 6;
        in7 = 7; in8 = 8; in9 = 9;

        // Case 1
        #10;
        in1 = 9; in2 = 1; in3 = 7;
        in4 = 3; in5 = 5; in6 = 8;
        in7 = 2; in8 = 6; in9 = 4;

        // Case 2
        #10;
        in1 = 5; in2 = 5; in3 = 5;
        in4 = 1; in5 = 2; in6 = 9;
        in7 = 10; in8 = 7; in9 = 3;

        // Case 3
        #10;
        in1 = 0; in2 = 255; in3 = 1;
        in4 = 2; in5 = 50;  in6 = 100;
        in7 = 200; in8 = 255; in9 = 0;

        // Case 4
        #10;
        in1 = 229; in2 = 119; in3 = 18;
        in4 = 143; in5 = 242; in6 = 206;
        in7 = 232; in8 = 197; in9 = 92;

        // Case 5
        #10;
        in1 = 8; in2 = 3; in3 = 8;
        in4 = 3; in5 = 8; in6 = 3;
        in7 = 8; in8 = 3; in9 = 8;

        // stop input
        #10;
        valid_in = 1'b0;
        in1 = 0; in2 = 0; in3 = 0;
        in4 = 0; in5 = 0; in6 = 0;
        in7 = 0; in8 = 0; in9 = 0;

        #80;
        $finish;
    end

endmodule