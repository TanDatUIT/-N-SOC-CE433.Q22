/*
 * median_filter_main.c
 * NIOS II application: Switching Median Filter SoC Demo
 * Board: DE2 (Cyclone II EP2C35F672C6) - system_2
 *
 * Register Map (MY_IP_0 @ 0x1011090):
 *   +0x00 (W) : DATA_IN  - ghi pixel_in[7:0], pulse valid_in
 *   +0x00 (R) : DATA_OUT - doc pixel_out[7:0] tu FIFO (auto pop)
 *   +0x04 (R) : STATUS   - [0] fifo_not_empty, [1] fifo_full, [8] done
 *   +0x08 (W) : CONTROL  - [0] soft_reset
 *   +0x0C (R) : OUT_COUNT- so pixel output da co
 *
 * Peripheral Map (system_2.sopcinfo):
 *   HEX PIO  @ 0x1011050  (32-bit output: [27:21]=HEX3,[20:14]=HEX2,[13:7]=HEX1,[6:0]=HEX0)
 *   LED PIO  @ 0x1011060  (10-bit output: LEDR[9:0])
 *   KEY PIO  @ 0x1011070  (4-bit input:   KEY[3:0] active low)
 *   MY_IP_0  @ 0x1011090
 */

#include <stdio.h>
#include <stdint.h>
#include "system.h"
#include "altera_avalon_jtag_uart_regs.h"
#include "io.h"

/* ---- Base addresses (system_2.sopcinfo) ---- */
#ifndef MY_IP_0_BASE
#define MY_IP_0_BASE  0x1011090
#endif

#define HEX_BASE      0x1011050
#define LED_BASE      0x1011060
#define KEY_BASE      0x1011070

/* ---- MY_IP_0 register offsets ---- */
#define REG_DATA       (MY_IP_0_BASE + 0x00)
#define REG_STATUS     (MY_IP_0_BASE + 0x04)
#define REG_CONTROL    (MY_IP_0_BASE + 0x08)
#define REG_COUNT      (MY_IP_0_BASE + 0x0C)
#define REG_IMG_WIDTH  (MY_IP_0_BASE + 0x10)
#define REG_IMG_HEIGHT (MY_IP_0_BASE + 0x14)

/* ---- Status bits ---- */
#define STATUS_NOT_EMPTY  (1 << 0)
#define STATUS_FULL       (1 << 1)
#define STATUS_DONE       (1 << 8)

/* ---- LED bits (LEDR) ---- */
#define LED_RUNNING   (1 << 0)   /* LEDR0: dang chay filter */
#define LED_DONE      (1 << 1)   /* LEDR1: hoan thanh */
#define LED_ERROR     (1 << 9)   /* LEDR9: loi */

/* LED thanh tien: LEDR[9:2] = 8 bit progress (su dung LEDR[8:2]) */
#define LED_PROGRESS_SHIFT  2

/* ---- KEY bits (active low) ---- */
#define KEY_START   (1 << 1)   /* KEY1: bat dau chay */
#define KEY_RESET   (1 << 2)   /* KEY2: reset */

/* ---- Kich thuoc anh toi da (dung cap phat buffer tinh) ---- */
#define MAX_IMG_W   1024
#define MAX_IMG_H   1024
#define MAX_IMG_SIZE (MAX_IMG_W * MAX_IMG_H)

/* ---- Macro doc/ghi register ---- */
#define WRITE_REG(addr, val)  IOWR_32DIRECT((addr), 0, (val))
#define READ_REG(addr)        IORD_32DIRECT((addr), 0)

/* ---- 7-segment lookup (active low, cac thanh phan: gfedcba) ---- */
/*
 *   --a--
 *  |     |
 *  f     b
 *  |     |
 *   --g--
 *  |     |
 *  e     c
 *  |     |
 *   --d--
 *
 * Bit order: bit6=g, bit5=f, bit4=e, bit3=d, bit2=c, bit1=b, bit0=a
 * Active LOW: 0 = bat sang, 1 = tat
 */
static const uint8_t SEG7[10] = {
    0x40, /* 0: 0b1000000 - tat g */
    0x79, /* 1: 0b1111001 - chi sang b,c */
    0x24, /* 2: 0b0100100 - sang a,b,d,e,g */
    0x30, /* 3: 0b0110000 - sang a,b,c,d,g */
    0x19, /* 4: 0b0011001 - sang b,c,f,g */
    0x12, /* 5: 0b0010010 - sang a,c,d,f,g */
    0x02, /* 6: 0b0000010 - sang a,c,d,e,f,g */
    0x78, /* 7: 0b1111000 - sang a,b,c */
    0x00, /* 8: 0b0000000 - tat ca sang */
    0x10, /* 9: 0b0010000 - sang a,b,c,d,f,g */
};

#define SEG7_BLANK  0x7F  /* Tat ca segments tat */
#define SEG7_DASH   0x3F  /* Chi sang g (dash) */

/* ---- Anh test (luu trong SDRAM, kich thuoc toi da) ---- */
static uint8_t input_img[MAX_IMG_SIZE];
static uint8_t output_img[MAX_IMG_SIZE];

/* ================================================================
 * Dieu khien LED va HEX
 * ================================================================ */

/*
 * Dat LEDR (10 bit)
 */
static void led_set(uint32_t val)
{
    WRITE_REG(LED_BASE, val & 0x3FF);
}

/*
 * Hien thi so 4 chu so (0-9999) len HEX3..HEX0
 * Moi HEX dung 7 bit, packed vao 32-bit:
 *   bits [6:0]   = HEX0
 *   bits [13:7]  = HEX1
 *   bits [20:14] = HEX2
 *   bits [27:21] = HEX3
 */
static void hex_show(uint16_t val)
{
    uint8_t d0 = val % 10;
    uint8_t d1 = (val / 10) % 10;
    uint8_t d2 = (val / 100) % 10;
    uint8_t d3 = (val / 1000) % 10;

    uint32_t data = ((uint32_t)SEG7[d3] << 21) |
                    ((uint32_t)SEG7[d2] << 14) |
                    ((uint32_t)SEG7[d1] <<  7) |
                    ((uint32_t)SEG7[d0] <<  0);
    WRITE_REG(HEX_BASE, data);
}

/*
 * Hien thi chu "donE" len HEX3..HEX0
 *  d = 0x21 (d), o = 0x23 (o), n = 0x2B (n), E = 0x06 (E)
 */
static void hex_show_done(void)
{
    /* d=0x21, o=0x23(viet lap thi dung 0), n=0x2B, E=0x06 */
    uint32_t data = ((uint32_t)0x21 << 21) |  /* HEX3: d */
                    ((uint32_t)0x40 << 14) |   /* HEX2: o (= 0) */
                    ((uint32_t)0x2B <<  7) |   /* HEX1: n */
                    ((uint32_t)0x06 <<  0);    /* HEX0: E */
    WRITE_REG(HEX_BASE, data);
}

/*
 * Tat het HEX
 */
static void hex_clear(void)
{
    uint32_t blank = ((uint32_t)SEG7_BLANK << 21) |
                     ((uint32_t)SEG7_BLANK << 14) |
                     ((uint32_t)SEG7_BLANK <<  7) |
                     ((uint32_t)SEG7_BLANK <<  0);
    WRITE_REG(HEX_BASE, blank);
}

/*
 * Cap nhat LED thanh tien: LEDR[8:2] = 7-bit progress (0-127 -> 0-100%)
 * LEDR[0] = running, LEDR[1] = done
 */
static void led_progress(int pixels_written)
{
    /* Scale 0..IMG_SIZE -> 0..127 (7-bit, LEDR[8:2]) */
    uint32_t prog = (uint32_t)pixels_written * 127 / IMG_SIZE;
    uint32_t led  = LED_RUNNING | (prog << LED_PROGRESS_SHIFT);
    led_set(led);

    /* Dong thoi hien thi so pixel da ghi len HEX */
    if (pixels_written % (IMG_SIZE / 10) == 0) {
        hex_show((uint16_t)(pixels_written & 0xFFFF));
    }
}

/* ================================================================
 * Dieu khien filter
 * ================================================================ */

static void filter_reset(void)
{
    WRITE_REG(REG_CONTROL, 1);
    WRITE_REG(REG_CONTROL, 0);
}

/*
 * Cau hinh kich thuoc anh cho hardware filter
 * Phai goi truoc khi chay filter
 */
static void filter_config(uint16_t w, uint16_t h)
{
    WRITE_REG(REG_IMG_WIDTH,  w);
    WRITE_REG(REG_IMG_HEIGHT, h);
    printf("Config filter: %dx%d -> output %dx%d (%d pixels)\n",
           w, h, w-2, h-2, (w-2)*(h-2));
}

/*
 * Doi KEY[bit] duoc nhan (active low: bit = 0 khi nhan)
 * Tra ve khi da nhan va tha ra (debounce don gian)
 */
static void wait_key(uint32_t key_bit)
{
    printf("Nhan KEY%d de tiep tuc...\n",
           (key_bit == KEY_START) ? 1 : 2);

    /* Doi nhan */
    while (READ_REG(KEY_BASE) & key_bit) { /* bit=1 = chua nhan */ }
    /* Doi tha */
    while (!(READ_REG(KEY_BASE) & key_bit)) { /* bit=0 = dang nhan */ }
}

/* ================================================================
 * Tao anh test
 * ================================================================ */

static void generate_test_image(uint16_t w, uint16_t h)
{
    int i, x, y;
    int size = w * h;

    for (y = 0; y < h; y++) {
        for (x = 0; x < w; x++) {
            input_img[y * w + x] = (uint8_t)((x + y) & 0xFF);
        }
    }

    /* Muoi tieu ~10% */
    for (i = 0; i < size; i += 10) {
        input_img[i] = (i % 20 == 0) ? 0 : 255;
    }

    printf("Anh test: %dx%d gradient + muoi tieu\n", w, h);
}

/* ================================================================
 * Chay filter
 * ================================================================ */

static int run_filter(uint16_t w, uint16_t h)
{
    int i;
    int out_idx = 0;
    int img_size = (int)w * h;
    int out_size = (int)(w - 2) * (h - 2);
    uint32_t status;

    printf("Bat dau loc median %dx%d...\n", w, h);
    led_set(LED_RUNNING);

    filter_reset();

    for (i = 0; i < img_size; i++) {

        status = READ_REG(REG_STATUS);
        if (status & STATUS_FULL) {
            while ((READ_REG(REG_STATUS) & STATUS_NOT_EMPTY)
                   && out_idx < out_size) {
                output_img[out_idx++] = (uint8_t)(READ_REG(REG_DATA) & 0xFF);
            }
        }

        WRITE_REG(REG_DATA, input_img[i]);

        if ((i & 0x1FFF) == 0) {
            led_progress(i);
        }
    }

    while (out_idx < out_size) {
        status = READ_REG(REG_STATUS);
        if (status & STATUS_NOT_EMPTY) {
            output_img[out_idx++] = (uint8_t)(READ_REG(REG_DATA) & 0xFF);
        }
        if ((status & STATUS_DONE) && !(status & STATUS_NOT_EMPTY)) {
            break;
        }
    }

    printf("Hoan thanh: %d pixel output (du kien %d)\n", out_idx, out_size);
    return out_idx;
}

/* ================================================================
 * In ket qua
 * ================================================================ */

static void print_results(int out_count)
{
    int i;
    int center_offset = IMG_W + 1;
    int filtered_count = 0;

    printf("\n--- Ket qua (20 pixel dau) ---\n");
    printf("%-5s %-10s %-10s %-10s\n", "Idx", "Input", "Output", "Changed?");
    printf("--------------------------------------\n");

    for (i = 0; i < 20 && i < out_count; i++) {
        uint8_t in_px  = input_img[i + center_offset];
        uint8_t out_px = output_img[i];
        int changed    = (in_px != out_px);
        printf("%-5d %-10d %-10d %s\n", i, in_px, out_px,
               changed ? "<-- filtered" : "");
    }

    for (i = 0; i < out_count; i++) {
        uint8_t orig = input_img[i + center_offset];
        if ((orig == 0 || orig == 255) && output_img[i] != orig) {
            filtered_count++;
        }
    }

    printf("\nTong pixel da loc (muoi tieu): %d / %d\n",
           filtered_count, out_count);

    /* Hien thi so pixel da loc len HEX */
    hex_show((uint16_t)(filtered_count > 9999 ? 9999 : filtered_count));
}

/* ================================================================
 * Main
 * ================================================================ */

int main(void)
{
    int out_count;

    /* ==== Thay doi kich thuoc anh tai day ==== */
    const uint16_t IMG_W = 256;
    const uint16_t IMG_H = 256;
    /* ========================================= */

    /* Khoi tao: tat LED, xoa HEX */
    led_set(0);
    hex_clear();

    printf("\n============================================\n");
    printf(" Switching Median Filter SoC Demo\n");
    printf(" NIOS II on Cyclone II EP2C35F672C6\n");
    printf(" MY_IP_0 base: 0x%08X\n", MY_IP_0_BASE);
    printf(" KEY base:     0x%08X\n", KEY_BASE);
    printf(" LED base:     0x%08X\n", LED_BASE);
    printf(" HEX base:     0x%08X\n", HEX_BASE);
    printf("============================================\n\n");

    /* Buoc 1: Cau hinh kich thuoc + tao anh test */
    filter_config(IMG_W, IMG_H);
    generate_test_image(IMG_W, IMG_H);

    /* Buoc 2: Doi KEY1 de bat dau */
    wait_key(KEY_START);

    /* Buoc 3: Chay filter */
    out_count = run_filter(IMG_W, IMG_H);

    /* Buoc 4: Ket qua */
    if (out_count > 0) {
        print_results(out_count);

        /* LED: tat running, bat done */
        led_set(LED_DONE);

        /* HEX hien thi "donE" */
        hex_show_done();

        printf("\nNhan KEY1 de chay lai...\n");
        wait_key(KEY_START);

    } else {
        printf("LOI: Khong nhan duoc output tu filter!\n");
        printf("Kiem tra ket noi Qsys va base address.\n");

        /* LED: bat error */
        led_set(LED_ERROR);
    }

    printf("\nDone.\n");
    return 0;
}
