library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divN is
    generic(
        N : integer := 12
        );
    port(
        y : in std_logic_vector(N-1 downto 0);
        x : in std_logic_vector(N-1 downto 0);
        z : out std_logic_vector(N-1 downto 0)
        );
end divN;

architecture behavioral of divN is
begin
    --z <= std_logic_vector(to_signed(to_integer(signed(y) / signed(x)),N));
    z <= std_logic_vector(y / x);
end behavioral;

