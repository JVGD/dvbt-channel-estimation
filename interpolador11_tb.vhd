library ieee;
use ieee.std_logic_1164.all;
use work.mi_paquete.all;
use ieee.numeric_std.all;

entity interpolador11_tb is
end interpolador11_tb;

architecture behavior of interpolador11_tb is 

	-- component declaration for the unit under test (uut)

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
				
	-- clkmanager component
    component clkmanager is
        generic (
            CLK_PERIOD       : time      := 10 ns;  --! Period of generated clock
            RST_ACTIVE_VALUE : std_logic := '0';    --! Reset polarity
            RST_CYCLES       : integer   := 10      --! Number of cycles that reset will be asserted at the beginning of the simulation
            );
        port (
            endsim : in  std_logic;  --! \c clk stops changing when endsim='1', which effectively stops the simulation
            clk    : out std_logic;  --! Generated clock
            rst    : out std_logic   --! Generated reset
            );
        end component;

	--inputs
	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal sup : complex12 := (re => (others=>'0'), im => (others=>'0'));
	signal inf : complex12 := (re => (others=>'0'), im => (others=>'0'));
	signal valid : std_logic := '0';

	--outputs
	signal estim : complex12 := (re => (others=>'0'), im => (others=>'0'));
	signal estim_valid : std_logic := '0';
	signal finished	: std_logic;

begin

	-- instantiate the unit under test (uut)
	uut: interpolador11 
		port map (
			clk => clk,
			rst => rst,
			sup => sup,
			inf => inf,
			valid => valid,
			estim => estim,
			estim_valid => estim_valid
			);

	-- Clock manager instance
    clk_mng : clkmanager
        generic map(
            clk_period => 10 ns,
            rst_active_value => '1',
            rst_cycles => 1)
        port map (
            endsim => '0',
            clk => clk,
            rst => rst
            );

	-- stimulus process
	stim_proc: process
	begin		
		-- hold reset state for 100 ns.
		-- Pilots already equalized
		wait for 20 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"019";   -- d"1.562500" b"000000011001"
		inf.im <= x"ffa";   -- d"-0.375000" b"111111111010"
		sup.re <= x"012";   -- d"1.125000" b"000000010010"
		sup.im <= x"ff1";   -- d"-0.937500" b"111111110001"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data	


		wait;
	end process;

end;
