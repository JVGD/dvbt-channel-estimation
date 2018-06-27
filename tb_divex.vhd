library ieee;
use ieee.std_logic_1164.all;

entity tb_divex is
end entity;

architecture foo of tb_divex is
    signal x:       std_logic_vector(31 downto 0) :=x"000000FF";
    signal y:       std_logic_vector(31 downto 0) :=x"00000005";
    signal r:       std_logic_vector(31 downto 0);
begin

DUT:
    entity work.divex
        port map (
            x => x,
            y => y,
            r => r
        );

STIMULUS:
    process 
    begin
        wait for 10 ns;
        x <= x"00000046";
        y <= x"00000003";
        wait for 10 ns;
        wait;      
    end process;

end architecture;
