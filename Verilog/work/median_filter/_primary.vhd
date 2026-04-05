library verilog;
use verilog.vl_types.all;
entity median_filter is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        valid_in        : in     vl_logic;
        in1             : in     vl_logic_vector(7 downto 0);
        in2             : in     vl_logic_vector(7 downto 0);
        in3             : in     vl_logic_vector(7 downto 0);
        in4             : in     vl_logic_vector(7 downto 0);
        in5             : in     vl_logic_vector(7 downto 0);
        in6             : in     vl_logic_vector(7 downto 0);
        in7             : in     vl_logic_vector(7 downto 0);
        in8             : in     vl_logic_vector(7 downto 0);
        in9             : in     vl_logic_vector(7 downto 0);
        median          : out    vl_logic_vector(7 downto 0);
        valid_out       : out    vl_logic
    );
end median_filter;
