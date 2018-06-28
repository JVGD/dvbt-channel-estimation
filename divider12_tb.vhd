library ieee;
use ieee.std_logic_1164.all;
 
-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;
 
entity divider12_tb is
end divider12_tb;
 
architecture behavior of divider12_tb is 
 
    -- component declaration for the unit under test (uut)
 
    component divider12
    port(
		rst : in std_logic;
		clk : in  std_logic;
		valid_in : in std_logic;
		x : in  std_logic_vector(11 downto 0);
		y : in  std_logic_vector(11 downto 0);
		z : out  std_logic_vector(11 downto 0);
		valid_out : out std_logic
		);
    end component;
	
	-- clkmanager component
    component clkmanager is
        generic (
            clk_period       : time      := 10 ns;  --! period of generated clock
            rst_active_value : std_logic := '0';    --! reset polarity
            rst_cycles       : integer   := 10      --! number of cycles that reset will be asserted at the beginning of the simulation
            );
        port (
            endsim : in  std_logic;  --! \c clk stops changing when endsim='1', which effectively stops the simulation
            clk    : out std_logic;  --! generated clock
            rst    : out std_logic   --! generated reset
            );
        end component;
    

	--inputs
	signal rst :std_logic := '1';
	signal clk : std_logic := '0';
	signal valid_in : std_logic := '0';
	signal x : std_logic_vector(11 downto 0) := (others => '0');
	signal y : std_logic_vector(11 downto 0) := (others => '0');
	signal valid_out : std_logic;

	--outputs
	signal z : std_logic_vector(11 downto 0);

	-- clock period definitions
	constant clk_period : time := 10 ns;
 
begin
 
	-- instantiate the unit under test (uut)
	uut: divider12 
	port map (
		rst => rst,
		clk => clk,
		valid_in => valid_in,
		x => x,
		y => y,
		z => z,
		valid_out => valid_out
		);

       -- clock manager instance
    clk_mng : clkmanager
        generic map(
            clk_period => clk_period,
            rst_active_value => '1',
            rst_cycles => 1
			)
        port map (
            endsim => '0',
            clk => clk,
            rst => rst
            );
 

	-- stimulus process
	stim_proc: process
	begin		

		wait for 2*clk_period;

		-- insert stimulus here 
		--x: -4.570000, X: -4.562500 fb7 111110110111
		--y: -4.300000, Y: -4.312500 fbb 111110111011
		--r: 1.062791, R: 1.062500 011 000000010001
		x <= "111110110111";
		y <= "111110111011";
		valid_in <= '1';
		wait for clk_period;
		valid_in <= '0';

		wait for clk_period*21;
		--x: -4.900000, X: -4.875000 fb2 111110110010
		--y: -3.900000, Y: -3.875000 fc2 111111000010
		--r: 1.256410, R: 1.250000 014 000000010100
		x <= "111110110010";
		y <= "111111000010";
		valid_in <= '1';
		wait for clk_period;
		valid_in <= '0';
		
		wait for clk_period*21;
		--x: 2.800000, X: 2.812500 02d 000000101101
		--y: -6.400000, Y: -6.375000 f9a 111110011010
		--r: -0.437500, R: -0.437500 ff9 111111111001
		x <= "000000101101";
		y <= "111110011010";
		valid_in <= '1';
		wait for clk_period;
		valid_in <= '0';

		wait for clk_period*21;
		--x: -4.570000, X: -4.562500 fb7 111110110111
		--y: 4.300000, Y: 4.312500 045 000001000101
		--r: -1.062791, R: -1.062500 fef 111111101111
		x <= "111110110111";
		y <= "000001000101";
		valid_in <= '1';
		wait for clk_period;
		valid_in <= '0';
		

		
		wait;

	end process;

end;
