module shift_register #(parameter DATA_WIDTH = 8) (
    input clk,
    input rst,
    input [DATA_WIDTH-1:0] a_i,
    output reg [DATA_WIDTH-1:0] a0, a1, a2, a3
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            {a0, a1, a2, a3} <= 0;
        end else begin
            // a0 <= Gia tri moi 
            a0 <= a_i;
            a1 <= a0;
            a2 <= a1;
            a3 <= a2;
        end
    end
endmodule
