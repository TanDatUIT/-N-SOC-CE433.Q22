module sort3 (
    input  [7:0] a,
    input  [7:0] b,
    input  [7:0] c,
    output [7:0] min_o,
    output [7:0] med_o,
    output [7:0] max_o
);

wire [7:0] a1, b1;
wire [7:0] a2, c1;
wire [7:0] b2, c2;

// Step 1: sort a,b
swap s1(.a(a), .b(b), .min(a1), .max(b1));

// Step 2: sort a,c
swap s2(.a(a1), .b(c), .min(a2), .max(c1));

// Step 3: sort b,c
swap s3(.a(b1), .b(c1), .min(b2), .max(c2));

assign min_o = a2;
assign med_o = b2;
assign max_o = c2;

endmodule