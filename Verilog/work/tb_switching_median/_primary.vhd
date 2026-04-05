library verilog;
use verilog.vl_types.all;
entity tb_switching_median is
    generic(
        W               : integer := 256;
        H               : integer := 256;
        SIZE            : vl_notype;
        OUT_W           : vl_notype;
        OUT_H           : vl_notype;
        OUT_SIZE        : vl_notype
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of W : constant is 1;
    attribute mti_svvh_generic_type of H : constant is 1;
    attribute mti_svvh_generic_type of SIZE : constant is 3;
    attribute mti_svvh_generic_type of OUT_W : constant is 3;
    attribute mti_svvh_generic_type of OUT_H : constant is 3;
    attribute mti_svvh_generic_type of OUT_SIZE : constant is 3;
end tb_switching_median;
