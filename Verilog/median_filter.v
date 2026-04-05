`timescale 1ns/1ps
module median_filter (
	input wire clk,
	input wire rst_n,
	input wire valid_in,
	input wire [7:0]  in1, in2, in3, in4, in5, in6, in7, in8, in9,
	output reg [7:0] median,
	output reg valid_out
);

reg [7:0] stage1 [0:8];
reg [7:0] stage2 [0:2];

wire [7:0] s1 [0:8];
wire [7:0] s2 [0:2];

// them delay valid cho tung tang pipeline
reg valid_stage1;
reg valid_stage2;

// stage 1
sort3 sort0(
	.a(in1), .b(in2), .c(in3),
	.min_o(s1[0]), .med_o(s1[1]), .max_o(s1[2])
);

sort3 sort1(
	.a(in4), .b(in5), .c(in6),
	.min_o(s1[3]), .med_o(s1[4]), .max_o(s1[5])
);

sort3 sort2(
	.a(in7), .b(in8), .c(in9),
	.min_o(s1[6]), .med_o(s1[7]), .max_o(s1[8])
);

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin 
		stage1[0] <= 8'd0;
		stage1[1] <= 8'd0;
		stage1[2] <= 8'd0;
		stage1[3] <= 8'd0;
		stage1[4] <= 8'd0;
		stage1[5] <= 8'd0;
		stage1[6] <= 8'd0;
		stage1[7] <= 8'd0;
		stage1[8] <= 8'd0;
		valid_stage1 <= 1'b0;
	end
	else begin
		stage1[0] <= s1[0]; // min nhom 1
		stage1[1] <= s1[1]; // med nhom 1
		stage1[2] <= s1[2]; // max nhom 1
		
		stage1[3] <= s1[3]; // min nhom 2
		stage1[4] <= s1[4]; // med nhom 2
		stage1[5] <= s1[5]; // max nhom 2
		
		stage1[6] <= s1[6]; // min nhom 3
		stage1[7] <= s1[7]; // med nhom 3
		stage1[8] <= s1[8]; // max nhom 3
		
		valid_stage1 <= valid_in;
	end
end

// stage 2
// max cua cac min (2 comparators)
wire [7:0] tmp0_max;
max3 u_max_of_mins(
	.a(stage1[0]), .b(stage1[3]), .c(stage1[6]),
	.max_o(tmp0_max)
);

// med cua cac med (3 comparators)
wire [7:0] tmp1_med;
sort3 sort4_meds(
	.a(stage1[1]), .b(stage1[4]), .c(stage1[7]),
	.min_o(), .med_o(tmp1_med), .max_o()
);

// min cua cac max (2 comparators)
wire [7:0] tmp2_min;
min3 u_min_of_maxs(
	.a(stage1[2]), .b(stage1[5]), .c(stage1[8]),
	.min_o(tmp2_min)
);

assign s2[0] = tmp0_max; // max cua cac min
assign s2[1] = tmp1_med; // med cua cac med
assign s2[2] = tmp2_min; // min cua cac max
 
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin 
		stage2[0] <= 8'd0;
		stage2[1] <= 8'd0;
		stage2[2] <= 8'd0;
		valid_stage2 <= 1'b0;
	end
	else begin
		stage2[0] <= s2[0];
		stage2[1] <= s2[1];
		stage2[2] <= s2[2];
		valid_stage2 <= valid_stage1;
	end
end

// stage 3
wire [7:0] out_min;
wire [7:0] out_med;
wire [7:0] out_max;

sort3 sort_final9(
	.a(stage2[0]), .b(stage2[1]), .c(stage2[2]),
	.min_o(out_min), .med_o(out_med), .max_o(out_max)
);

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		median    <= 8'd0;
		valid_out <= 1'b0;
	end
	else begin
		median    <= out_med;
		valid_out <= valid_stage2;
	end
end

endmodule