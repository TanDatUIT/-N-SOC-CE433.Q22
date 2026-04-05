`timescale 1ns/1ps

module tb_image_median_cascade;

    parameter W    = 256;
    parameter H    = 256;
    parameter SIZE = W * H;

    reg clk;
    reg rst_n;
    reg valid_in;

    reg [7:0] mem [0:SIZE-1];

    integer row, col;
    integer fout;

    reg [7:0] pixel_in_reg;
    wire [7:0] pixel_out;
    wire       valid_out;

    median_filter_cascade #(.IMG_WIDTH(W)) dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .valid_in (valid_in),
        .pixel_in (pixel_in_reg),
        .valid_out(valid_out),
        .pixel_out(pixel_out)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $readmemh("noisy_image.hex", mem);
        fout = $fopen("filtered_cascade.hex", "w");
    end

    // Feed pixels: 1 pixel moi cycle
    always @(posedge clk) begin
        if (!rst_n) begin
            row      <= 0;
            col      <= 0;
            valid_in <= 1'b0;
            pixel_in_reg <= 8'd0;
        end
        else begin
            if (row < H) begin
                valid_in     <= 1'b1;
                pixel_in_reg <= mem[row * W + col];

                if (col == W - 1) begin
                    col <= 0;
                    row <= row + 1;
                end
                else begin
                    col <= col + 1;
                end
            end
            else begin
                valid_in     <= 1'b0;
                pixel_in_reg <= 8'd0;
            end
        end
    end

    // Thu ket qua 2-pass
    always @(posedge clk) begin
        if (valid_out)
            $fwrite(fout, "%02h\n", pixel_out);
    end

    initial begin
        rst_n = 1'b0;
        #20;
        rst_n = 1'b1;

        // Du thoi gian: pass1 (65536 clk) + buffer + pass2 (64516 clk) + flush
        #30000000;
        $fclose(fout);
        $display("Simulation done. Output: filtered_cascade.hex");
        $finish;
    end

endmodule
