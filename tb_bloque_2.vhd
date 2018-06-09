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
            data_in : out std_logic_vector(23 downto 0);    -- [Re(23,12), Im(11,0)]
            valid   : out std_logic;                        -- 1 if data_in is ready
            clk     : out std_logic
            );
        end component;

    -- expected signals to see in simultion
    signal data_in_tb   : std_logic_vector(23 downto 0);
    signal valid_tb     : std_logic;
    signal clk_tb       : std_logic;
    
      

begin

    -- Clock manager instance
    bloque2 : bloque_2
        port map(
            data_in => data_in_tb,
            valid   => valid_tb,
            clk     => clk_tb
            );

end;
