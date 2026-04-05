module median_filter_top #(
    parameter MAX_WIDTH = 1024
)(
    input        clk,
    input        rst_n,
    input        valid_in,
    input  [7:0] pixel_in,
    input [15:0] img_width,  // chieu rong anh thuc te (runtime)

    output       valid_out,
    output [7:0] pixel_out
);

    wire        valid_window;
    wire [7:0]  p1, p2, p3;
    wire [7:0]  p4, p5, p6;
    wire [7:0]  p7, p8, p9;

    window3x3 #(
        .MAX_WIDTH(MAX_WIDTH)
    ) u_window (
        .clk        (clk),
        .rst_n      (rst_n),
        .valid_in   (valid_in),
        .pixel_in   (pixel_in),
        .img_width  (img_width),
        .valid_window(valid_window),
        .p1(p1), .p2(p2), .p3(p3),
        .p4(p4), .p5(p5), .p6(p6),
        .p7(p7), .p8(p8), .p9(p9)
    );

    // Median filter pipeline (3 tang, 19 bo so sanh)
    wire [7:0] median_w;
    median_filter u_pipeline (
        .clk      (clk),
        .rst_n    (rst_n),
        .valid_in (valid_window),
        .in1(p1), .in2(p2), .in3(p3),
        .in4(p4), .in5(p5), .in6(p6),
        .in7(p7), .in8(p8), .in9(p9),
        .median   (median_w),
        .valid_out(valid_out)
    );

    // Delay pixel trung tam (p5) 3 clock cho khop voi pipeline latency
    reg [7:0] center_d1, center_d2, center_d3;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            center_d1 <= 8'd0;
            center_d2 <= 8'd0;
            center_d3 <= 8'd0;
        end
        else begin
            center_d1 <= p5;
            center_d2 <= center_d1;
            center_d3 <= center_d2;
        end
    end

    // Switching Median: chi loc khi pixel trung tam la nhieu (0 hoac 255)
    // Neu khong phai nhieu -> giu nguyen pixel goc
    assign pixel_out = (center_d3 == 8'd0 || center_d3 == 8'd255)
                       ? median_w
                       : center_d3;

endmodule
