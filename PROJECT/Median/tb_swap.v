module tb_swap();
// KHONG CAN XUNG CLOCK
reg [7:0] ai,bi;
wire [7:0] ao,bo;
swap dut( ai,bi,ao,bo);

initial begin
ai = 8'd0;
bi = 8'd0;
#5;
ai = 8'h12; 
bi = 8'h11;
#10;
ai = 8'h0;
bi ;= 8'h01;
#5;
ai = 8'h44;
bi = 8'h74;
#10;
ai = 8'hCA;
bi = 8'hca;
#5
ai = 8'hca;
bi = 8'hCA;
#5
ai = 8'hDD;
bi = 8'hDD;

$stop;
end

endmodule 