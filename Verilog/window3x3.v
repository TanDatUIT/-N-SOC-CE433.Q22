module window3x3 #(
    parameter MAX_WIDTH = 1024  // kich thuoc toi da cua line buffer
)(
    input            clk,
    input            rst_n,
    input            valid_in,
    input      [7:0] pixel_in,
    input     [15:0] img_width, // chieu rong anh thuc te (runtime)

    output reg       valid_window,

    output reg [7:0] p1,
    output reg [7:0] p2,
    output reg [7:0] p3,
    output reg [7:0] p4,
    output reg [7:0] p5,
    output reg [7:0] p6,
    output reg [7:0] p7,
    output reg [7:0] p8,
    output reg [7:0] p9
);

    reg [7:0] line1 [0:MAX_WIDTH-1];
    reg [7:0] line2 [0:MAX_WIDTH-1];

    reg [15:0] col_cnt;
    reg [15:0] row_cnt;

    reg [7:0] line1_data;
    reg [7:0] line2_data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            col_cnt       <= 16'd0;
            row_cnt       <= 16'd0;
            valid_window  <= 1'b0;

            p1 <= 8'd0; p2 <= 8'd0; p3 <= 8'd0;
            p4 <= 8'd0; p5 <= 8'd0; p6 <= 8'd0;
            p7 <= 8'd0; p8 <= 8'd0; p9 <= 8'd0;

            line1_data <= 8'd0;
            line2_data <= 8'd0;
        end
        else begin
            valid_window <= 1'b0;

            if (valid_in) begin
                // Đọc dữ liệu cũ từ line buffer tại cột hiện tại
                line1_data <= line1[col_cnt];
                line2_data <= line2[col_cnt];

                // Dịch ngang 3 pixel cho hàng trên cùng
                p1 <= p2;
                p2 <= p3;
                p3 <= line2[col_cnt];

                // Dịch ngang 3 pixel cho hàng giữa
                p4 <= p5;
                p5 <= p6;
                p6 <= line1[col_cnt];

                // Dịch ngang 3 pixel cho hàng hiện tại
                p7 <= p8;
                p8 <= p9;
                p9 <= pixel_in;

                // Cập nhật line buffers
                line2[col_cnt] <= line1[col_cnt];
                line1[col_cnt] <= pixel_in;

                // valid window khi đã có ít nhất 3 hàng và 3 cột
                if ((row_cnt >= 16'd2) && (col_cnt >= 16'd2)) begin
                    valid_window <= 1'b1;
                end

                // Tăng bộ đếm cột/hàng
                if (col_cnt == img_width - 16'd1) begin
                    col_cnt <= 16'd0;
                    row_cnt <= row_cnt + 16'd1;
                end
                else begin
                    col_cnt <= col_cnt + 16'd1;
                end
            end
        end
    end

endmodule