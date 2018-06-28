library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity twos_compliment is
	generic(
		N : integer := 12		-- Number inputs bits
		);
	port(
		number_in : in std_logic_vector(N-1 downto 0);
		number_out : out std_logic_vector(N-1 downto 0)
		);
end twos_compliment;

architecture behavioral of twos_compliment is

	signal negated : std_logic_vector(N-1 downto 0);

begin

	-- Concurrent operations
	negated <= not(number_in);
	number_out <= std_logic_vector(unsigned(negated) + 1);

end behavioral;

