library ieee;
use ieee.std_logic_1164.all;
 
-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;
 
entity twos_compliment_tb is
end twos_compliment_tb;
 
architecture behavior of twos_compliment_tb is 
 
	-- component declaration for the unit under test (uut)

	component twos_compliment
		generic(
			N : integer := 12		-- Number inputs bits
			);
		port(
			number_in : in std_logic_vector(N-1 downto 0);
			number_out : out std_logic_vector(N-1 downto 0)
			);
		end component;


	--inputs
	signal N : integer := 3;
	signal clk : std_logic := '1';
	signal rst : std_logic := '1';
	signal number_in : std_logic_vector(N-1 downto 0) := (others => '0');

	--outputs
	signal number_out : std_logic_vector(N-1 downto 0);

	-- clock period definitions
	constant clk_period : time := 10 ns;
 
begin
 
	-- instantiate the unit under test (uut)
	uut: twos_compliment 
		generic map(
			N => 3
			)
		port map (
			number_in => number_in,
			number_out => number_out
			);

	-- clock process definitions
	clk_process :process
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;


	-- stimulus process
	stim_proc: process
	begin		
		-- hold reset state for 100 ns
		wait for 2*clk_period;	
		rst <= '0';
		wait for clk_period;
		
		-- insert stimulus here 
		number_in <= "000";
		wait for clk_period;
		number_in <= "001";
		wait for clk_period;
		number_in <= "010";
		wait for clk_period;
		number_in <= "011";
		wait for clk_period;
		number_in <= "111";
		wait for clk_period;
		number_in <= "110";
		wait for clk_period;
		number_in <= "101";
		wait for clk_period;
		number_in <= "100";		
		
		wait;
	end process;

end;
