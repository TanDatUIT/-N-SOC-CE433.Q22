// 2-pass cascade median filter
// Pass 1: 256x256 → 254x254 (stored in frame buffer)
// Pass 2: 254x254 → 252x252 (final output)
module median_filter_cascade #(
    parameter IMG_WIDTH = 256
)(
    input        clk,
    input        rst_n,
    input        valid_in,
    input  [7:0] pixel_in,

    output       valid_out,
    output [7:0] pixel_out
);

    localparam W1          = IMG_WIDTH;
    localparam W2          = W1 - 2;           // 254
    localparam BUF_SIZE    = W2 * W2;          // 64516

    localparam PASS1 = 1'b0;
    localparam PASS2 = 1'b1;

    // -------------------------------------------------------
    // Pass 1
    // -------------------------------------------------------
    wire        valid_pass1;
    wire [7:0]  pixel_pass1;

    median_filter_top #(.IMG_WIDTH(W1)) u_pass1 (
        .clk      (clk),
        .rst_n    (rst_n),
        .valid_in (valid_in),
        .pixel_in (pixel_in),
        .valid_out(valid_pass1),
        .pixel_out(pixel_pass1)
    );

    // -------------------------------------------------------
    // Frame buffer: luu ket qua pass 1
    // -------------------------------------------------------
    reg [7:0]  frame_buf [0:BUF_SIZE-1];
    reg [16:0] buf_waddr;   // 17-bit: 0..64515
    reg [16:0] buf_raddr;
    reg        state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            buf_waddr <= 17'd0;
            buf_raddr <= 17'd0;
            state     <= PASS1;
        end
        else begin
            // Ghi pass1 output vao buffer
            if (valid_pass1 && state == PASS1) begin
                frame_buf[buf_waddr] <= pixel_pass1;
                if (buf_waddr == BUF_SIZE - 1) begin
                    buf_waddr <= 17'd0;
                    state     <= PASS2;
                end
                else begin
                    buf_waddr <= buf_waddr + 17'd1;
                end
            end

            // Doc tuan tu de feed vao pass 2
            if (state == PASS2 && buf_raddr < BUF_SIZE) begin
                buf_raddr <= buf_raddr + 17'd1;
            end
        end
    end

    // -------------------------------------------------------
    // Pass 2: doc tu frame buffer → median filter
    // -------------------------------------------------------
    wire        valid_to_p2 = (state == PASS2) && (buf_raddr < BUF_SIZE);
    wire [7:0]  pixel_to_p2 = frame_buf[buf_raddr];

    median_filter_top #(.IMG_WIDTH(W2)) u_pass2 (
        .clk      (clk),
        .rst_n    (rst_n),
        .valid_in (valid_to_p2),
        .pixel_in (pixel_to_p2),
        .valid_out(valid_out),
        .pixel_out(pixel_out)
    );

endmodule
