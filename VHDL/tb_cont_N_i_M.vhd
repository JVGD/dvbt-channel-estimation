library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tb_cont_N_i_M is
end tb_cont_N_i_M;

architecture behavioral of tb_cont_N_i_M is

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
		
	-- cont
	component cont_N_i_M is
		generic( 
			N : integer := 0; -- counter init number
			i : integer := 1; -- counter step count
			M : integer := 10 -- counter end number
			);
		port(
			clk : in std_logic;
			rst : in std_logic;
			enable: in std_logic;
			counter : out std_logic_vector(natural(ceil(log2(real(M+1))))-1 downto 0);
			cont_ended : out std_logic
			);
		end component;
		
		--signals for clk manager
		signal clk: std_logic;
		signal rst: std_logic;
		
		-- signals for counter
		signal N : integer := 0;
		signal i : integer := 1;
		signal M : integer := 10;
		signal enable : std_logic;
		signal counter : std_logic_vector(natural(ceil(log2(real(M+1))))-1 downto 0);
		signal cont_ended : std_logic;
		

begin

	-- Clock manager instance
    uut_clkmanager : clkmanager
        generic map(
            clk_period => 10 ns,
            rst_active_value => '1',
            rst_cycles => 2
			)
        port map (
            endsim => '0',
            clk => clk,
            rst => rst
            );
	
	uut_cont_N_i_M : cont_N_i_M
		generic map( 
			N => N,
			i => i, -- counter step count
			M => M  -- counter end number
			)
		port map(
			clk => clk,
			rst => rst,
			enable => enable,
			counter => counter,
			cont_ended => cont_ended
			);
	
	-- stimulus process
	stim_proc: process
	begin
		enable <= '0';
		wait for 90 ns;
		enable <= '1';
		wait;
	end process;
	
end behavioral;