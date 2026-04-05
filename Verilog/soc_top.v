module soc_top (
    input  wire        CLOCK_50,
    input  wire [3:0]  KEY,

    // LEDs
    output wire [9:0]  LEDR,
    output wire [7:0]  LEDG,

    // HEX 7-segment (active low, 7-bit mỗi display)
    output wire [6:0]  HEX0,
    output wire [6:0]  HEX1,
    output wire [6:0]  HEX2,
    output wire [6:0]  HEX3,

    // SDRAM (IS42S16400 on DE2)
    output wire [11:0] DRAM_ADDR,
    output wire        DRAM_BA_0,
    output wire        DRAM_BA_1,
    output wire        DRAM_CAS_N,
    output wire        DRAM_CKE,
    output wire        DRAM_CLK,
    output wire        DRAM_CS_N,
    inout  wire [15:0] DRAM_DQ,
    output wire        DRAM_LDQM,
    output wire        DRAM_UDQM,
    output wire        DRAM_RAS_N,
    output wire        DRAM_WE_N
);

    wire [1:0]  dram_ba;
    wire [1:0]  dram_dqm;
    wire [31:0] hex_data;   // HEX PIO 32-bit: [27:21]=HEX3, [20:14]=HEX2, [13:7]=HEX1, [6:0]=HEX0

    assign DRAM_BA_0 = dram_ba[0];
    assign DRAM_BA_1 = dram_ba[1];
    assign DRAM_LDQM = dram_dqm[0];
    assign DRAM_UDQM = dram_dqm[1];

    assign HEX0 = hex_data[6:0];
    assign HEX1 = hex_data[13:7];
    assign HEX2 = hex_data[20:14];
    assign HEX3 = hex_data[27:21];

    // LEDG[0] = PLL locked, LEDG[7:1] = tự do cho C code
    wire pll_locked;
    assign LEDG[0] = pll_locked;

    system_2 u0 (
        .clk_clk                           (CLOCK_50),
        .reset_reset_n                     (KEY[0]),

        // PIO
        .key_external_connection_export    (KEY),
        .led_external_connection_export    (LEDR),
        .hex_external_connection_export    (hex_data),

        // PLL conduits
        .altpll_0_areset_conduit_export    (1'b0),
        .altpll_0_locked_conduit_export    (pll_locked),
        .altpll_0_phasedone_conduit_export (),

        // SDRAM
        .new_sdram_controller_0_wire_addr  (DRAM_ADDR),
        .new_sdram_controller_0_wire_ba    (dram_ba),
        .new_sdram_controller_0_wire_cas_n (DRAM_CAS_N),
        .new_sdram_controller_0_wire_cke   (DRAM_CKE),
        .new_sdram_controller_0_wire_cs_n  (DRAM_CS_N),
        .new_sdram_controller_0_wire_dq    (DRAM_DQ),
        .new_sdram_controller_0_wire_dqm   (dram_dqm),
        .new_sdram_controller_0_wire_ras_n (DRAM_RAS_N),
        .new_sdram_controller_0_wire_we_n  (DRAM_WE_N),
        .sdram_clk_clk                     (DRAM_CLK)
    );

endmodule
