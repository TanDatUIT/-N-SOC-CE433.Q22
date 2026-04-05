// ============================================================
// Avalon-MM Slave Wrapper cho Switching Median Filter
// Giao tiep voi NIOS II qua Qsys
// ============================================================
// Register Map (32-bit, word address):
//   Addr 0 (W): DATA_IN   - ghi pixel_in[7:0], tu dong pulse valid_in
//   Addr 0 (R): DATA_OUT  - doc pixel_out[7:0] tu FIFO (auto pop)
//   Addr 1 (R): STATUS    - [0] fifo_not_empty, [1] fifo_full
//                            [8] done, [24:16] fifo_count
//   Addr 2 (W): CONTROL   - [0] soft_reset
//   Addr 3 (R): OUT_COUNT - so pixel output da nhan duoc
//   Addr 4 (W/R): IMG_WIDTH  - chieu rong anh thuc te (mac dinh 256)
//   Addr 5 (W/R): IMG_HEIGHT - chieu cao anh thuc te  (mac dinh 256)
// ============================================================

module avalon_median_wrapper #(
    parameter MAX_WIDTH  = 1024,  // kich thuoc toi da line buffer
    parameter MAX_HEIGHT = 1024,
    parameter FIFO_DEPTH = 256
)(
    // Avalon clock/reset
    input               clk,
    input               reset_n,

    // Avalon-MM Slave (3-bit address: 6 registers)
    input      [2:0]    address,
    input               write,
    input               read,
    input      [31:0]   writedata,
    output reg [31:0]   readdata,

    // Interrupt (optional)
    output              irq
);

    // ---- Runtime image size (configurable qua register) ----
    reg [15:0] cfg_width;   // chieu rong thuc te
    reg [15:0] cfg_height;  // chieu cao thuc te

    // out_size tinh luc runtime: (w-2)*(h-2)
    wire [31:0] out_size = (cfg_width - 16'd2) * (cfg_height - 16'd2);

    // ---- Soft reset ----
    reg soft_reset;
    wire rst_n_int = reset_n & ~soft_reset;

    // ---- Ket noi median_filter_top ----
    reg        valid_in;
    reg  [7:0] pixel_in;
    wire       valid_out;
    wire [7:0] pixel_out;

    median_filter_top #(
        .MAX_WIDTH(MAX_WIDTH)
    ) u_median (
        .clk       (clk),
        .rst_n     (rst_n_int),
        .valid_in  (valid_in),
        .pixel_in  (pixel_in),
        .img_width (cfg_width),
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
    wire       done = (out_count >= out_size);

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
            cfg_width  <= 16'd256;  // gia tri mac dinh
            cfg_height <= 16'd256;
        end
        else begin
            valid_in <= 1'b0;

            if (write) begin
                case (address)
                    3'd0: begin  // DATA_IN
                        pixel_in <= writedata[7:0];
                        valid_in <= 1'b1;
                    end
                    3'd2: begin  // CONTROL
                        soft_reset <= writedata[0];
                    end
                    3'd4: cfg_width  <= writedata[15:0];  // IMG_WIDTH
                    3'd5: cfg_height <= writedata[15:0];  // IMG_HEIGHT
                    default: ;
                endcase
            end
        end
    end

    // ---- Avalon Read + FIFO Pop ----
    reg fifo_pop;

    always @(posedge clk or negedge rst_n_int) begin
        if (!rst_n_int)
            rd_ptr <= 0;
        else if (fifo_pop && !fifo_empty)
            rd_ptr <= rd_ptr + 9'd1;
    end

    always @(*) begin
        fifo_pop = 1'b0;
        readdata = 32'd0;

        case (address)
            3'd0: begin  // DATA_OUT
                readdata = {24'd0, fifo_mem[rd_ptr[7:0]]};
                if (read && !fifo_empty)
                    fifo_pop = 1'b1;
            end
            3'd1: begin  // STATUS
                readdata = {7'd0, fifo_count,
                            6'd0, done,
                            fifo_full,
                            ~fifo_empty};
            end
            3'd2: readdata = {31'd0, soft_reset};  // CONTROL
            3'd3: readdata = out_count;             // OUT_COUNT
            3'd4: readdata = {16'd0, cfg_width};    // IMG_WIDTH
            3'd5: readdata = {16'd0, cfg_height};   // IMG_HEIGHT
            default: readdata = 32'd0;
        endcase
    end

    // ---- Interrupt: bao khi FIFO co du lieu hoac done ----
    assign irq = ~fifo_empty;

endmodule
