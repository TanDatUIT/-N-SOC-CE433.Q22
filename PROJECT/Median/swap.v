module swap(
	input [7:0] Ai,Bi,
	output [7:0] Ao, Bo
);
//8 bit, vi 1 dong - pixel la 2 HEX
// A > B => SWAP => TANG DAN
assign Ao = ( Ai > Bi)? Bi : Ai;
assign Bo = (Ai > Bi)? Ai : Bi;

endmodule