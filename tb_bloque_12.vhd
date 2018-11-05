library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use work.mi_paquete.all;
 
-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;
 
entity tb_bloque_12 is
end tb_bloque_12;
 
architecture behavior of tb_bloque_12 is 
 
    -- component declaration for the unit under test (uut)
    component bloque_12
		port(
			clk : in std_logic;
			rst : in std_logic;
			ram_ready : in std_logic;
			data : in std_logic_vector(23 downto 0);
			addr : out std_logic_vector(7 downto 0);
			pilot_inf : out complex12;
			pilot_sup : out complex12;
			valid : out std_logic;
			interp_ready : in std_logic
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
            clk    : out std_logic;  --! Generated clock
            rst    : out std_logic   --! Generated reset
            );
		end component;
		
	component interpolador11
		port(
			clk         : in std_logic;
			rst         : in std_logic;
			finished	: out std_logic;
			sup         : in complex12;
			inf         : in complex12;
			valid       : in std_logic;
			estim       : out complex12; 
			estim_valid : out std_logic
			);
		end component;
		
	-- signals of UUT
	signal clk : std_logic;
	signal rst : std_logic;
	signal ram_ready : std_logic;
	signal data : std_logic_vector(23 downto 0);
	signal addr : std_logic_vector(7 downto 0);
	signal pilot_inf : complex12;
	signal pilot_sup : complex12;
	signal valid : std_logic;
	signal interp_ready : std_logic;
    
begin

	-- instantiate the unit under test (uut)
	uut_bloque_12: bloque_12 
		port map (
			clk => clk,
			rst => rst,
			ram_ready => ram_ready,
			data => data,
			addr => addr,
			pilot_inf => pilot_inf,
			pilot_sup => pilot_sup,
			valid => valid,
			interp_ready => interp_ready
			);

	-- Clock manager instance
    uut_clkmanager : clkmanager
        generic map(
            clk_period => 10 ns,
            rst_active_value => '1',
            rst_cycles => 4
			)
        port map (
            endsim => '0',
            clk => clk,
            rst => rst
            );

--	uut_interpolador11 : interpolador11 
--		port map (
--			clk => clk,
--			finished => finished,
--			rst => rst,
--			sup => datan1,
--			inf => datan,
--			valid => data_valid,
--			estim => ch_est,
--			estim_valid => ch_valid
--			);		


	-- stimulus process
	stim_proc: process
	begin
		-- interp ready at begin
		interp_ready <= '1';
		
		wait for 30 ns;
		ram_ready <= '1';
		
		wait for 10 ns;
		interp_ready <= '0';
		
		wait for 110 ns;
		interp_ready <= '1';

		wait for 20 ns;
		interp_ready <= '0';

		wait for 110 ns;
		interp_ready <= '1';

		wait for 20 ns;
		interp_ready <= '0';

		wait for 110 ns;
		interp_ready <= '1';
		
		wait;
	end process;

end;
