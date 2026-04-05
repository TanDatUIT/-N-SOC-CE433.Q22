library verilog;
use verilog.vl_types.all;
entity window3x3 is
    generic(
        IMG_WIDTH       : integer := 256
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        valid_in        : in     vl_logic;
        pixel_in        : in     vl_logic_vector(7 downto 0);
        valid_window    : out    vl_logic;
        p1              : out    vl_logic_vector(7 downto 0);
        p2              : out    vl_logic_vector(7 downto 0);
        p3              : out    vl_logic_vector(7 downto 0);
        p4              : out    vl_logic_vector(7 downto 0);
        p5              : out    vl_logic_vector(7 downto 0);
        p6              : out    vl_logic_vector(7 downto 0);
        p7              : out    vl_logic_vector(7 downto 0);
        p8              : out    vl_logic_vector(7 downto 0);
        p9              : out    vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IMG_WIDTH : constant is 1;
end window3x3;
