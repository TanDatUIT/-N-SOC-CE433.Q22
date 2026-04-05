`timescale 1ns/1ps

module tb_switching_median;

    parameter W    = 256;
    parameter H    = 256;
    parameter SIZE = W * H;

    // Output size after window3x3 border removal
    parameter OUT_W = W - 2;  // 254
    parameter OUT_H = H - 2;  // 254
    parameter OUT_SIZE = OUT_W * OUT_H;  // 64516

    reg        clk;
    reg        rst_n;
    reg        valid_in;
    reg  [7:0] pixel_in;

    wire       valid_out;
    wire [7:0] pixel_out;

    reg [7:0] mem [0:SIZE-1];
    integer   fout;
    integer   pixel_count;
    integer   out_count;

    // DUT: median_filter_top co switching logic ben trong
    median_filter_top #(
        .IMG_WIDTH(W)
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .valid_in  (valid_in),
        .pixel_in  (pixel_in),
        .valid_out (valid_out),
        .pixel_out (pixel_out)
    );

    // Clock 10ns period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Load image data
    initial begin
        $readmemh("noisy_image.hex", mem);
        fout = $fopen("filtered.hex", "w");
        pixel_count = 0;
        out_count   = 0;
    end

    // Feed pixels sequentially, 1 pixel per clock
    always @(posedge clk) begin
        if (!rst_n) begin
            valid_in   <= 1'b0;
            pixel_in   <= 8'd0;
            pixel_count <= 0;
        end
        else begin
            if (pixel_count < SIZE) begin
                valid_in <= 1'b1;
                pixel_in <= mem[pixel_count];
                pixel_count <= pixel_count + 1;
            end
            else begin
                valid_in <= 1'b0;
                pixel_in <= 8'd0;
            end
        end
    end

    // Capture output
    always @(posedge clk) begin
        if (valid_out) begin
            $fwrite(fout, "%02h\n", pixel_out);
            out_count <= out_count + 1;
        end
    end

    // Reset + run
    initial begin
        rst_n = 1'b0;
        #20;
        rst_n = 1'b1;

        // Wait enough for all pixels + pipeline flush
        #10000000;

        $display("Output pixels: %0d (expected %0d)", out_count, OUT_SIZE);
        $fclose(fout);
        $finish;
    end

endmodule
