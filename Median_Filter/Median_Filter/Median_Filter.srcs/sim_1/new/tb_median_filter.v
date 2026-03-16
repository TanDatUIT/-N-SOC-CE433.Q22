`timescale 1ns / 1ps

module tb_median_filter();
    reg clk;
    reg rst_n;
    reg [7:0] in0, in1, in2, in3, in4, in5, in6, in7, in8;
    wire [7:0] median;

    median_filter uut (
        .clk(clk), .rst_n(rst_n),
        .in0(in0), .in1(in1), .in2(in2), .in3(in3),
        .in4(in4), .in5(in5), .in6(in6), .in7(in7), .in8(in8),
        .median(median)
    );

    always #5 clk = ~clk; // 100MHz simulation cho nhanh

    initial begin
        clk = 0; rst_n = 0;
        #20 rst_n = 1;

        @(posedge clk);
        {in0,in1,in2,in3,in4,in5,in6,in7,in8} = {8'd10, 8'd50, 8'd20, 8'd90, 8'd40, 8'd80, 8'd30, 8'd70, 8'd60};

        @(posedge clk);
        {in0,in1,in2,in3,in4,in5,in6,in7,in8} = {8'd255, 8'd0, 8'd255, 8'd120, 8'd122, 8'd121, 8'd0, 8'd255, 8'd0};

        @(posedge clk);
        {in0,in1,in2,in3,in4,in5,in6,in7,in8} = {8'd90, 8'd80, 8'd70, 8'd60, 8'd50, 8'd40, 8'd30, 8'd20, 8'd10};

        @(posedge clk);
        {in0,in1,in2,in3,in4,in5,in6,in7,in8} = {8'd25, 8'd24, 8'd26, 8'd25, 8'd25, 8'd10, 8'd90, 8'd25, 8'd25};

        repeat(20) @(posedge clk);
        $stop;
    end

    // Ghi chú cho Huy: Theo d?i Output ? c?a s? Tcl Console
    always @(posedge clk) begin
        if (rst_n)
            $display("Time: %t | Median Out: %d", $time, median);
    end
endmodule