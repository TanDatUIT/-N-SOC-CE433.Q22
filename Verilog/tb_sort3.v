`timescale 1ns/1ps

module tb_sort3;

reg  [7:0] a, b, c;
wire [7:0] min, med, max;

sort3 dut (
    .a(a),
    .b(b),
    .c(c),
    .min_o(min),
    .med_o(med),
    .max_o(max)
);

task run_case;
    input [7:0] ta, tb, tc;
    input [7:0] exp_min, exp_med, exp_max;
begin
    a = ta;
    b = tb;
    c = tc;
    #10;

    if ((min === exp_min) && (med === exp_med) && (max === exp_max)) begin
        $display("PASS | in = %0d %0d %0d | min=%0d med=%0d max=%0d",
                 ta, tb, tc, min, med, max);
    end
    else begin
        $display("FAIL | in = %0d %0d %0d | got min=%0d med=%0d max=%0d | exp min=%0d med=%0d max=%0d",
                 ta, tb, tc, min, med, max, exp_min, exp_med, exp_max);
    end
end
endtask

initial begin
    $display("==== TEST sort3 ====");

    run_case(8'd1,   8'd2,   8'd3,   8'd1,   8'd2,   8'd3);
    run_case(8'd3,   8'd2,   8'd1,   8'd1,   8'd2,   8'd3);
    run_case(8'd3,   8'd1,   8'd2,   8'd1,   8'd2,   8'd3);
    run_case(8'd2,   8'd3,   8'd1,   8'd1,   8'd2,   8'd3);
    run_case(8'd2,   8'd1,   8'd3,   8'd1,   8'd2,   8'd3);
    run_case(8'd1,   8'd3,   8'd2,   8'd1,   8'd2,   8'd3);

    run_case(8'd5,   8'd5,   8'd5,   8'd5,   8'd5,   8'd5);
    run_case(8'd5,   8'd5,   8'd1,   8'd1,   8'd5,   8'd5);
    run_case(8'd9,   8'd2,   8'd9,   8'd2,   8'd9,   8'd9);
    run_case(8'd0,   8'd255, 8'd127, 8'd0,   8'd127, 8'd255);
    run_case(8'd200, 8'd10,  8'd50,  8'd10,  8'd50,  8'd200);
    run_case(8'd128, 8'd64,  8'd192, 8'd64,  8'd128, 8'd192);

    $display("==== END TEST sort3 ====");
    $finish;
end

endmodule