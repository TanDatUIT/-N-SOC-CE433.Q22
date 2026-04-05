module max3 (
    input  [7:0] a,
    input  [7:0] b,
    input  [7:0] c,
    output [7:0] max_o
);
    wire [7:0] ab;
    assign ab    = (a > b) ? a : b;   // comparator 1
    assign max_o = (ab > c) ? ab : c; // comparator 2
endmodule
