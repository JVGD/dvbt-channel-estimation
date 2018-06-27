library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divex is
    port(
        x   : in std_logic_vector(31 downto 0);
        y   : in std_logic_vector(31 downto 0);
        r   : out std_logic_vector(31 downto 0)
        );
end divex;

architecture behavioral of divex is
begin
    r <= std_logic_vector(to_signed(to_integer(signed(x) / signed(y)),32));
end behavioral;