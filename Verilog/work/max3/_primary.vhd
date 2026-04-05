library verilog;
use verilog.vl_types.all;
entity max3 is
    port(
        a               : in     vl_logic_vector(7 downto 0);
        b               : in     vl_logic_vector(7 downto 0);
        c               : in     vl_logic_vector(7 downto 0);
        max_o           : out    vl_logic_vector(7 downto 0)
    );
end max3;
