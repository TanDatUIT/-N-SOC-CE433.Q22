library verilog;
use verilog.vl_types.all;
entity median_filter_top is
    generic(
        IMG_WIDTH       : integer := 256
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        valid_in        : in     vl_logic;
        pixel_in        : in     vl_logic_vector(7 downto 0);
        valid_out       : out    vl_logic;
        pixel_out       : out    vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IMG_WIDTH : constant is 1;
end median_filter_top;
