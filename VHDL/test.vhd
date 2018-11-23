library ieee;
use ieee.std_logic_1164.all;


entity test is
end test;

architecture behavioral of test is

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

	component datacompare is
		generic(
			SIMULATION_LABEL         : string  := "b2 datacompare";               --! Allow to separate messages from different instances in SIMULATION
			VERBOSE                  : boolean := false;                          --! Report correct data and not only erroneous data
			DEBUG                    : boolean := false;                          --! Print debug info (developers only)        
			GOLD_OUTPUT_FILE         : string  := "symbOFDM.txt"; 				  --! File where data is stored
			GOLD_OUTPUT_NIBBLES      : integer := 2;                              --! Maximum hex chars for each output data 
			DATA_WIDTH               : integer := 8                               --! Width of inout data
			);
		port(
			clk    : in std_logic;                                --! Expects input data aligned to this clock
			data   : in std_logic_vector (DATA_WIDTH-1 downto 0); --! Data to compare with data in file
			valid  : in std_logic;                                --! Active high, indicates data is valid
			endsim : in std_logic                                 --! Active high, tells the process to close its open files
			);
		end component;

	
	--clkmanager
	signal clk : std_logic;
	signal rst : std_logic;
	
	-- datacomp
	signal data : std_logic_vector(3 downto 0) := (others=>'0');
	signal valid : std_logic;
	

begin

    -- Clock manager instance
    bloque_1_clk : clkmanager
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
		
	-- datacompare
	bloque_2_datacompare : datacompare
		generic map(
			SIMULATION_LABEL => "test datacompare",               	--! Allow to separate messages from different instances in SIMULATION
			VERBOSE => true,                          				--! Report correct data and not only erroneous data
			DEBUG => false,                          				--! Print debug info (developers only)        
			GOLD_OUTPUT_FILE => "test.txt",		 				  	--! File where data is stored
			GOLD_OUTPUT_NIBBLES => 1,                              	--! Maximum hex chars for each output data 
			DATA_WIDTH => 4                               			--! Width of inout data
			)
		port map(
			clk => clk,                                	--! Expects input data aligned to this clock
			data => data, 								--! Data to compare with data in file
			valid => valid,                            --! Active high, indicates data is valid
			endsim => '0'                              --! Active high, tells the process to close its open files
			);


	
	-- Concurrent
	valid <= not(rst);
	-- stimulus process
	stim_proc: process
	begin	
		wait for 20 ns;
		data(0)<= '1';
		wait for 10 ns;
		data(0)<= '0';
		wait for 10 ns;
		data(0)<= '1';
		wait for 10 ns;
		data(0)<= '0';
		wait for 10 ns;
		data(0)<= '0';
		wait for 10 ns;
		data(0)<= '0';
		wait;
	end process;

end behavioral;

