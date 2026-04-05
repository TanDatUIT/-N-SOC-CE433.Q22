// ============================================================
// Avalon-MM Slave Wrapper cho Switching Median Filter
// Giao tiep voi NIOS II qua Qsys
// ============================================================
// Register Map (32-bit, byte address = word_addr * 4):
//   Addr 0 (W): DATA_IN  - ghi pixel_in[7:0], tu dong pulse valid_in
//   Addr 0 (R): DATA_OUT - doc pixel_out[7:0] tu FIFO (auto pop)
//   Addr 1 (R): STATUS   - [0] fifo_not_empty
//                           [1] fifo_full
//                           [8] done (da nhan du output)
//                           [31:16] fifo_count
//   Addr 2 (W): CONTROL  - ghi 1 de soft-reset pipeline
//   Addr 3 (R): OUT_COUNT - so pixel output da nhan duoc
// ============================================================

module avalon_median_wrapper #(
    parameter IMG_WIDTH  = 256,
    parameter IMG_HEIGHT = 256,
    parameter FIFO_DEPTH = 256   // buffer 1 hang output
)(
    // Avalon clock/reset
    input               clk,
    input               reset_n,

    // Avalon-MM Slave
    input      [1:0]    address,
    input               write,
    input               read,
    input      [31:0]   writedata,
    output reg [31:0]   readdata,

    // Interrupt (optional)
    output              irq
);

    // ---- Tinh toan kich thuoc output ----
    localparam OUT_W    = IMG_WIDTH  - 2;  // 254
    localparam OUT_H    = IMG_HEIGHT - 2;  // 254
    localparam OUT_SIZE = OUT_W * OUT_H;   // 64516

    // ---- Soft reset ----
    reg soft_reset;
    wire rst_n_int = reset_n & ~soft_reset;

    // ---- Ket noi median_filter_top ----
    reg        valid_in;
    reg  [7:0] pixel_in;
    wire       valid_out;
    wire [7:0] pixel_out;

    median_filter_top #(
        .IMG_WIDTH(IMG_WIDTH)
    ) u_median (
        .clk       (clk),
        .rst_n     (rst_n_int),
        .valid_in  (valid_in),
        .pixel_in  (pixel_in),
        .valid_out (valid_out),
        .pixel_out (pixel_out)
    );

    // ---- Output FIFO (circular buffer) ----
    reg [7:0] fifo_mem [0:FIFO_DEPTH-1];
    reg [8:0] wr_ptr;
    reg [8:0] rd_ptr;

    wire [8:0] fifo_count = wr_ptr - rd_ptr;
    wire fifo_empty = (wr_ptr == rd_ptr);
    wire fifo_full  = (fifo_count == FIFO_DEPTH[8:0]);

    // Ghi vao FIFO khi co output tu filter
    always @(posedge clk or negedge rst_n_int) begin
        if (!rst_n_int) begin
            wr_ptr <= 0;
        end
        else if (valid_out && !fifo_full) begin
            fifo_mem[wr_ptr[7:0]] <= pixel_out;
            wr_ptr <= wr_ptr + 9'd1;
        end
    end

    // ---- Dem so output ----
    reg [31:0] out_count;
    wire       done = (out_count >= OUT_SIZE);

    always @(posedge clk or negedge rst_n_int) begin
        if (!rst_n_int)
            out_count <= 32'd0;
        else if (valid_out)
            out_count <= out_count + 1;
    end

    // ---- Avalon Write ----
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            valid_in   <= 1'b0;
            pixel_in   <= 8'd0;
            soft_reset <= 1'b0;
        end
        else begin
            valid_in <= 1'b0;  // mac dinh: pulse 1 clock

            if (write) begin
                case (address)
                    2'd0: begin  // DATA_IN
                        pixel_in <= writedata[7:0];
                        valid_in <= 1'b1;
                    end
                    2'd2: begin  // CONTROL
                        soft_reset <= writedata[0];
                    end
                    default: ;
                endcase
            end
        end
    end

    // ---- Avalon Read + FIFO Pop ----
    reg fifo_pop;

    always @(posedge clk or negedge rst_n_int) begin
        if (!rst_n_int) begin
            rd_ptr <= 0;
        end
        else if (fifo_pop && !fifo_empty) begin
            rd_ptr <= rd_ptr + 9'd1;
        end
    end

    always @(*) begin
        fifo_pop = 1'b0;
        readdata = 32'd0;

        case (address)
            2'd0: begin  // DATA_OUT (doc pixel + auto pop)
                readdata = {24'd0, fifo_mem[rd_ptr[7:0]]};
                if (read && !fifo_empty)
                    fifo_pop = 1'b1;
            end
            2'd1: begin  // STATUS
                readdata = {14'd0, fifo_count[8:0],  // [31:9] padding + count
                            6'd0, done,             // [8]
                            fifo_full,              // [1]
                            ~fifo_empty};           // [0]
            end
            2'd2: begin  // CONTROL (read back)
                readdata = {31'd0, soft_reset};
            end
            2'd3: begin  // OUT_COUNT
                readdata = out_count;
            end
            default: readdata = 32'd0;
        endcase
    end

    // ---- Interrupt: bao khi FIFO co du lieu hoac done ----
    assign irq = ~fifo_empty;

endmodule
