library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mi_paquete.all;

entity tb_estimador is
end tb_estimador;

architecture behavior of tb_estimador is 

     -- Block for reading data from file
	 -- and clock generation
    component bloque_2
        port(
            data_b2     : out std_logic_vector(23 downto 0);    -- [Re(23,12), Im(11,0)]
            valid_b2    : out std_logic;                        -- 1 if ofdm_symbol is ready
            clk_b2      : out std_logic;
            rst_b2      : out std_logic
            );
        end component;

	-- unit under test
	component estimador
		port(
			clk : in  std_logic;
			rst : in  std_logic;
			data_in : in  std_logic_vector(23 downto 0);
			valid_in : in  std_logic;
			ch_est : out  complex12;
			ch_valid : out  std_logic
			);
		end component;

	-- for writing data output
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

	-- inputs
	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal ofdm_symbol : std_logic_vector(23 downto 0) := (others => '0');
	signal valid_in : std_logic := '0';

	-- outputs
	signal ch_est : complex12;
	signal ch_valid : std_logic;

	-- clock period definitions
	constant clk_period : time := 10 ns;

begin
	
    uut_bloque_2 : bloque_2
        port map(
            data_b2     => ofdm_symbol,
            valid_b2    => valid_in,
            clk_b2      => clk,
            rst_b2      => rst
            );

	uut_estimador : estimador 
		port map (
			clk => clk,
			rst => rst,
			data_in => ofdm_symbol,
			valid_in => valid_in,
			ch_est => ch_est,
			ch_valid => ch_valid
			);
			
	dump_bloque_14_ch_est : datawrite
		generic map(
			SIMULATION_LABEL => "estimator_ch_est.txt",            --! Allow to separate messages from different instances in SIMULATION
			VERBOSE => false,                          	--! Print more internal details
			DEBUG => false,                          	--! Print debug info (developers only)        
			OUTPUT_FILE => "../verificacion/ficheros_VHDL/estimador_ch_est.txt",    --! File where data will be stored
			OUTPUT_NIBBLES => 6,                        --! Hex chars on each output line 
			DATA_WIDTH => 24                            --! Width of input data
			)
		port map(
			clk => clk,             --! Will sample input on rising_edge of this clock
			data => ch_est.re & ch_est.im,
			valid  => ch_valid,    --! Active high, indicates data is valid
			endsim => '0'           --! Active high, tells the process to close its open files
			);

	-- stimulus process
	stim_proc: process
	begin		
		wait;
	end process;

end behavior;
