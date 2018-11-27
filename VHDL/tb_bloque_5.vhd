library ieee;
use ieee.std_logic_1164.all;

entity tb_bloque_05 is
end tb_bloque_05;

architecture behavior of tb_bloque_05 is

    -- Declaramos componente
    component bloque_5
		port(
			clk   : in std_logic;   --clock
			rst : in std_logic;	--reset
			Yout  : out std_logic;	--randomized output
			valid : out std_logic;
			enable : in std_logic
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
        
	component datawrite
		generic(
			SIMULATION_LABEL    : string  := "datawrite";                    --! Allow to separate messages from different instances in SIMULATION
			VERBOSE             : boolean := false;                          --! Print more internal details
			DEBUG               : boolean := false;                          --! Print debug info (developers only)        
			OUTPUT_FILE         : string  := "./output/datawrite_test.txt";  --! File where data will be stored
			OUTPUT_NIBBLES      : integer := 2;                              --! Hex chars on each output line 
			DATA_WIDTH          : integer := 8                               --! Width of input data
			);
		port(
			clk    : in std_logic;                                --! Will sample input on rising_edge of this clock
			data   : in std_logic_vector (DATA_WIDTH-1 downto 0); --! Data to write to file
			valid  : in std_logic;                                --! Active high, indicates data is valid
			endsim : in std_logic                                 --! Active high, tells the process to close its open files
			);
		end component;



    --seales
    signal Yout : std_logic_vector(0 downto 0);
	signal enable : std_logic;

    -- Signals for Clock Manager
    -- No inicializamos rst y clk porque son out
    signal rst : std_logic;
    signal clk : std_logic := '1';
    signal valid : std_logic;

	-- signals for datacompare

begin
	--Instantiation of component
	prbs_bloque : bloque_5
        port map(
            clk   => clk,
            rst => rst,
            Yout  => Yout(0),
            valid => valid,
			enable => enable
        );
	
    -- Clock manager instance
    clk_mng : clkmanager
        generic map(
            clk_period => 10 ns,
            rst_active_value => '1',
            rst_cycles => 2)
        port map (
            endsim => '0',
            clk => clk,
            rst => rst
            );
			
	ver_bloque_5 :datawrite
		generic map(
			SIMULATION_LABEL => "datawrite",            --! Allow to separate messages from different instances in SIMULATION
			VERBOSE => false,                          	--! Print more internal details
			DEBUG => false,                          	--! Print debug info (developers only)        
			OUTPUT_FILE => "verification/tb_bloque_5_generated.txt", --! File where data will be stored
			OUTPUT_NIBBLES => 1,                        --! Hex chars on each output line 
			DATA_WIDTH => 4                            --! Width of input data
			)
		port map(
			clk => clk,             	--! Will sample input on rising_edge of this clock
			data => "000" & Yout,	--! Data to write to file
			valid  => valid,    	--! Active high, indicates data is valid
			endsim => '0'           	--! Active high, tells the process to close its open files
			);
			
	stim : process
	begin
		enable <= '0';
		wait for 40 ns;
		
		enable <= '1';
		wait for 17050 ns;
		
		enable <= '0';
		wait;
	end process;

end behavior;