`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  UIT
// Engineer: Bui Tan Dat
// 
// Create Date: 03/12/2026 10:48:40 PM
// Design Name: 
// Module Name: median_filter
// Project Name: median filter 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module median_filter(
input clk,
input rst_n,
input wire [7:0] in0, in1, in2, in3, in4, in5, in6, in7, in8,
output wire [7:0] median);
// 1 2 3 4 5 6 7 8 ; sap xep tang dan
wire [7:0] wS[0:16], wL[0:16];
// 9 tang pipeline
reg [7:0] register_stage1 [0:8];
reg [7:0] register_stage2 [0:8];
reg [7:0] register_stage3 [0:8];
reg [7:0] register_stage4 [0:8];
reg [7:0] register_stage5 [0:8];
reg [7:0] register_stage6 [0:8];
reg [7:0] register_stage7 [0:8];
reg [7:0] register_stage8 [0:8];
reg [7:0] register_stage9 [0:8];

//stage 1
swap comp1(in0,in5, wS[0], wL[0]);
swap comp2(in1,in6, wS[1], wL[1]);
swap comp3(in2,in7, wS[2], wL[2]);
swap comp4(in3,in8, wS[3], wL[3]);

always @(posedge clk or negedge rst_n) begin 
    if ( !rst_n) begin 
        register_stage1[0] <= 8'd0;
        register_stage1[1] <= 8'd0;
        register_stage1[2] <= 8'd0;
        register_stage1[3] <= 8'd0;
        register_stage1[4] <= 8'd0;
        register_stage1[5] <= 8'd0;
        register_stage1[6] <= 8'd0;
        register_stage1[7] <= 8'd0;
        register_stage1[8] <= 8'd0;
        end
    else begin 
        register_stage1[0] <= wS[0];
        register_stage1[1] <= wS[1]; 
        register_stage1[2] <= wS[2]; 
        register_stage1[3] <= wS[3];
        register_stage1[4] <= in4;   
        register_stage1[5] <= wL[0];                                    
        register_stage1[6] <= wL[1];                                   
        register_stage1[7] <= wL[2];                                   
        register_stage1[8] <= wL[3];                               
        
    end 
end

// stage 2
swap comp5(register_stage1[5], register_stage1[7], wS[4], wL[4]); // X5 X7
swap comp6(register_stage1[6], register_stage1[8], wS[5], wL[5]); // X6 X8
always @(posedge clk or negedge rst_n) begin 
    if ( !rst_n) begin 
        register_stage2[0] <= 8'd0;
        register_stage2[1] <= 8'd0;
        register_stage2[2] <= 8'd0;
        register_stage2[3] <= 8'd0;
        register_stage2[4] <= 8'd0;
        register_stage2[5] <= 8'd0;
        register_stage2[6] <= 8'd0;
        register_stage2[7] <= 8'd0;
        register_stage2[8] <= 8'd0;      
          end
    else begin 
        register_stage2[0] <=    register_stage1[0]; 
        register_stage2[1] <=    register_stage1[1]; 
        register_stage2[2] <=    register_stage1[2]; 
        register_stage2[3] <=    register_stage1[3]; 
        register_stage2[4] <=    register_stage1[4]; 
        register_stage2[5] <=    wS[4]; 
        register_stage2[6] <=    wS[5]; 
        register_stage2[7] <=    wL[4]; 
        register_stage2[8] <=    wL[5]; 
        
    end
end

// Da dung w4-5
//stage 3

swap comp7(register_stage2[7], register_stage2[8], wS[6], wL[6]);
always @(posedge clk or negedge rst_n) begin 
    if ( !rst_n) begin 
        register_stage3[0] <= 8'd0;
        register_stage3[1] <= 8'd0;
        register_stage3[2] <= 8'd0;
        register_stage3[3] <= 8'd0;
        register_stage3[4] <= 8'd0;
        register_stage3[5] <= 8'd0;
        register_stage3[6] <= 8'd0;
        register_stage3[7] <= 8'd0;
        register_stage3[8] <= 8'd0;
        end
     else begin 
        register_stage3[0] <=   register_stage2[0]   ;
        register_stage3[1] <=   register_stage2[1]   ;
        register_stage3[2] <=   register_stage2[2]   ;
        register_stage3[3] <=   register_stage2[3]   ;
        register_stage3[4] <=   register_stage2[4]   ;
        register_stage3[5] <=   register_stage2[5]   ;
        register_stage3[6] <=   register_stage2[6]   ;
        register_stage3[7] <=   wS[6]   ;
        register_stage3[8] <=   wL[6] ;
     end
     
end
//Da dung W6
//stage 4


swap comp8(register_stage3[6], register_stage3[7], wS[7], wL[7]);
swap comp9(register_stage3[3], register_stage3[4], wS[8], wL[8]);


always @(posedge clk or negedge rst_n) begin 
    if ( !rst_n) begin 
        register_stage4[0] <= 8'd0;
        register_stage4[1] <= 8'd0;
        register_stage4[2] <= 8'd0;
        register_stage4[3] <= 8'd0;
        register_stage4[4] <= 8'd0;
        register_stage4[5] <= 8'd0;
        register_stage4[6] <= 8'd0;
        register_stage4[7] <= 8'd0;
        register_stage4[8] <= 8'd0;
        end
     else begin 
        register_stage4[0] <= register_stage3[0];
        register_stage4[1] <= register_stage3[1];
        register_stage4[2] <= register_stage3[2];
        register_stage4[3] <= wS[8];
        register_stage4[4] <= wL[8];
        register_stage4[5] <= register_stage3[5];
        register_stage4[6] <= wS[7];
        register_stage4[7] <= wL[7];
        register_stage4[8] <= register_stage3[8];        
     end
end
//stage 5

swap comp10( register_stage4[5], register_stage4[6], wS[9], wL[9]);
swap comp11( register_stage4[2], register_stage4[4], wS[10], wL[10]);

always @(posedge clk or negedge rst_n) begin 
    if ( !rst_n) begin 
        register_stage5[0] <= 8'd0;
        register_stage5[1] <= 8'd0;
        register_stage5[2] <= 8'd0;
        register_stage5[3] <= 8'd0;
        register_stage5[4] <= 8'd0;
        register_stage5[5] <= 8'd0;
        register_stage5[6] <= 8'd0;
        register_stage5[7] <= 8'd0;
        register_stage5[8] <= 8'd0;
        end
     else begin
        register_stage5[0] <= register_stage4[0];
        register_stage5[1] <= register_stage4[1];
        register_stage5[2] <= wS[10];
        register_stage5[3] <= register_stage4[3];
        register_stage5[4] <= wL[10];
        register_stage5[5] <= wS[9];
        register_stage5[6] <= wL[9];
        register_stage5[7] <= register_stage4[7];
        register_stage5[8] <= register_stage4[8];     
     end
end
// stage 6
swap comp12(register_stage5[4], register_stage5[6], wS[11], wL[11]);
    
always @(posedge clk or negedge rst_n) begin 
    if ( !rst_n) begin 
        register_stage6[0] <= 8'd0;
        register_stage6[1] <= 8'd0;
        register_stage6[2] <= 8'd0;
        register_stage6[3] <= 8'd0;
        register_stage6[4] <= 8'd0;
        register_stage6[5] <= 8'd0;
        register_stage6[6] <= 8'd0;
        register_stage6[7] <= 8'd0;
        register_stage6[8] <= 8'd0;
        end
     else begin
        register_stage6[0] <= register_stage5[0];
        register_stage6[1] <= register_stage5[1];
        register_stage6[2] <= register_stage5[2];
        register_stage6[3] <= register_stage5[3];
        register_stage6[4] <= wS[11];
        register_stage6[5] <= register_stage5[5];
        register_stage6[6] <= wL[11];
        register_stage6[7] <= register_stage5[7];
        register_stage6[8] <= register_stage5[8];
     
     end 
end

// stage 7  

swap comp13(register_stage6[4],register_stage6[5], wS[12], wL[12]);
swap comp14(register_stage6[1],register_stage6[3], wS[13], wL[13]);

always @(posedge clk or negedge rst_n) begin 
    if ( !rst_n) begin 
        register_stage7[0] <= 8'd0;
        register_stage7[1] <= 8'd0;
        register_stage7[2] <= 8'd0;
        register_stage7[3] <= 8'd0;
        register_stage7[4] <= 8'd0;
        register_stage7[5] <= 8'd0;
        register_stage7[6] <= 8'd0;
        register_stage7[7] <= 8'd0;
        register_stage7[8] <= 8'd0;
        end
    else begin 
        register_stage7[0] <=  register_stage6[0];
        register_stage7[1] <= wS[13];
        register_stage7[2] <=  register_stage6[2];
        register_stage7[3] <= wL[13];
        register_stage7[4] <= wS[12];
        register_stage7[5] <= wL[12];
        register_stage7[6] <=  register_stage6[6];
        register_stage7[7] <=  register_stage6[7];
        register_stage7[8] <=  register_stage6[8];    
    end 
end


// stage 8

swap comp15(register_stage7[3],register_stage7[5], wS[14], wL[14]  );
always @(posedge clk or negedge rst_n) begin 
    if ( !rst_n) begin 
        register_stage8[0] <= 8'd0;
        register_stage8[1] <= 8'd0;
        register_stage8[2] <= 8'd0;
        register_stage8[3] <= 8'd0;
        register_stage8[4] <= 8'd0;
        register_stage8[5] <= 8'd0;
        register_stage8[6] <= 8'd0;
        register_stage8[7] <= 8'd0;
        register_stage8[8] <= 8'd0;
        end
     else begin 
        register_stage8[0] <= register_stage7[0];
        register_stage8[1] <= register_stage7[1];
        register_stage8[2] <= register_stage7[2];
        register_stage8[3] <= wS[14];
        register_stage8[4] <= register_stage7[4];
        register_stage8[5] <= wL[14];
        register_stage8[6] <=register_stage7[6];
        register_stage8[7] <=register_stage7[7];
        register_stage8[8] <=register_stage7[8];     
     end 
end

// stage 9
swap comp16(register_stage8[3], register_stage8[4], wS[15], wL[15]);
always @(posedge clk or negedge rst_n) begin 
    if ( !rst_n) begin 
        register_stage9[0] <= 8'd0;
        register_stage9[1] <= 8'd0;
        register_stage9[2] <= 8'd0;
        register_stage9[3] <= 8'd0;
        register_stage9[4] <= 8'd0;
        register_stage9[5] <= 8'd0;
        register_stage9[6] <= 8'd0;
        register_stage9[7] <= 8'd0;
        register_stage9[8] <= 8'd0;
        end
     else begin
        register_stage9[0] <=  register_stage8[0];
        register_stage9[1] <=  register_stage8[1];
        register_stage9[2] <=  register_stage8[2];
        register_stage9[3] <= wS[15];
        register_stage9[4] <= wL[15];
        register_stage9[5] <=  register_stage8[5];
        register_stage9[6] <=  register_stage8[6];
        register_stage9[7] <=  register_stage8[7];
        register_stage9[8] <=  register_stage8[8];    
     end
end

// stage 10
reg [7:0] register_stage10 [0:8];
swap comp17(register_stage9[0], register_stage9[4], wS[16], median);
always @(posedge clk or negedge rst_n) begin 
    if ( !rst_n) begin 
        register_stage10[0] <= 8'd0;
        register_stage10[1] <= 8'd0;
        register_stage10[2] <= 8'd0;
        register_stage10[3] <= 8'd0;
        register_stage10[4] <= 8'd0;
        register_stage10[5] <= 8'd0;
        register_stage10[6] <= 8'd0;
        register_stage10[7] <= 8'd0;
        register_stage10[8] <= 8'd0;
        end
     else begin
        register_stage10[0] <=  wS[16];
        register_stage10[1] <=  register_stage9[1];
        register_stage10[2] <=  register_stage9[2];
        register_stage10[3] <=  register_stage9[3];
        register_stage10[4] <= median;        
        register_stage10[5] <=  register_stage9[5];
        register_stage10[6] <=  register_stage9[6];
        register_stage10[7] <=  register_stage9[7];
        register_stage10[8] <=  register_stage9[8];    
     end
end
    
endmodule
