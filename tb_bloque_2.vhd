-- testbench template 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_bloque_2 is
end tb_bloque_2;

architecture behavior of tb_bloque_2 is 

    -- component declaration
    component bloque_2
        port(
            data_b2     : out std_logic_vector(23 downto 0);    -- [Re(23,12), Im(11,0)]
            valid_b2    : out std_logic;                        -- 1 if data_in is ready
            clk_b2      : out std_logic;
            rst_b2      : out std_logic
            );
        end component;

    -- expected signals to see in simultion
    signal data_in_tb   : std_logic_vector(23 downto 0);
    signal valid_tb     : std_logic;
    signal clk_tb       : std_logic;
    signal rst_tb       : std_logic;   
      

begin

    -- Clock manager instance
    bloque2 : bloque_2
        port map(
            data_b2     => data_in_tb,
            valid_b2    => valid_tb,
            clk_b2      => clk_tb,
            rst_b2      => rst_tb
            );

end;
