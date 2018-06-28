library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
 
-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;
 
entity divider_pilot_tb is
end divider_pilot_tb;
 
architecture behavior of divider_pilot_tb is 
 
	-- component declaration for the unit under test (uut)

	component divider_pilot
	port(
		pilot_signed : in  std_logic;
		pilot_rx : in  std_logic_vector(11 downto 0);
		pilot_eq : out  std_logic_vector(11 downto 0)
		);
	end component;


	--inputs
	signal pilot_signed : std_logic := '0';
	signal pilot_rx : std_logic_vector(11 downto 0) := (others => '0');

	--outputs
	signal pilot_eq : std_logic_vector(11 downto 0);
	-- no clocks detected in port list. replace <clock> below with 
	-- appropriate port name 

	constant clk_period : time := 10 ns;
	signal clk : std_logic := '1';
begin
 
	-- instantiate the unit under test (uut)
	uut: divider_pilot 
		port map (
			pilot_signed => pilot_signed,
			pilot_rx => pilot_rx,
			pilot_eq => pilot_eq
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
		-- hold reset state for 100 ns.
		wait for 20 ns;	
		pilot_rx <= x"00c";
		pilot_signed <= '1';
	
		wait for clk_period;
		pilot_rx <= x"ff6";
		pilot_signed <= '0';
		
		wait for clk_period;
		pilot_rx <= x"00b";
		pilot_signed <= '0';

		wait;
	end process;

end;
