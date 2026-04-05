`timescale 1ns/1ps

module tb_image_median;

    parameter W    = 256;
    parameter H    = 256;
    parameter SIZE = W * H;

    reg clk;
    reg rst_n;
    reg valid_in;

    reg [7:0] mem [0:SIZE-1];

    integer row, col;
    integer r0, r1, r2;
    integer c0, c1, c2;
    integer idx0, idx1, idx2;
    integer fout;

    reg [7:0] in1, in2, in3;
    reg [7:0] in4, in5, in6;
    reg [7:0] in7, in8, in9;

    wire [7:0] median;
    wire       valid_out;

    median_filter dut(
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .in1(in1), .in2(in2), .in3(in3),
        .in4(in4), .in5(in5), .in6(in6),
        .in7(in7), .in8(in8), .in9(in9),
        .median(median),
        .valid_out(valid_out)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $readmemh("noisy_image.hex", mem);
        fout = $fopen("filtered.hex", "w");
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            row      <= 0;
            col      <= 0;
            valid_in <= 1'b0;

            in1 <= 0; in2 <= 0; in3 <= 0;
            in4 <= 0; in5 <= 0; in6 <= 0;
            in7 <= 0; in8 <= 0; in9 <= 0;
        end
        else begin
            if (row < H) begin
                valid_in <= 1'b1;

                // clamp row
                r0 = (row == 0)     ? 0     : (row - 1);
                r1 = row;
                r2 = (row == H - 1) ? H - 1 : (row + 1);

                // clamp col
                c0 = (col == 0)     ? 0     : (col - 1);
                c1 = col;
                c2 = (col == W - 1) ? W - 1 : (col + 1);

                idx0 = r0 * W;
                idx1 = r1 * W;
                idx2 = r2 * W;

                in1 <= mem[idx0 + c0];
                in2 <= mem[idx0 + c1];
                in3 <= mem[idx0 + c2];

                in4 <= mem[idx1 + c0];
                in5 <= mem[idx1 + c1];
                in6 <= mem[idx1 + c2];

                in7 <= mem[idx2 + c0];
                in8 <= mem[idx2 + c1];
                in9 <= mem[idx2 + c2];

                if (col == W - 1) begin
                    col <= 0;
                    row <= row + 1;
                end
                else begin
                    col <= col + 1;
                end
            end
            else begin
                valid_in <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if (valid_out) begin
            $fwrite(fout, "%02h\n", median);
        end
    end

    initial begin
        rst_n = 1'b0;
        #20;
        rst_n = 1'b1;

        // chạy đủ lâu cho toàn ảnh + pipeline flush
        #10000000;
        $fclose(fout);
        $finish;
    end

endmodule