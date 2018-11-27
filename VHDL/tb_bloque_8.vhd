library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.mi_paquete.all;
use work.vhdl_verification.all;

entity tb_bloque_08 is
end tb_bloque_08;
 
architecture behavior of tb_bloque_08 is 
 
    -- component declaration for the unit under test (uut)
     -- component declaration
    component bloque_8
		port(
			clk         : in std_logic;
			rst         : in std_logic;
			addr_symb   : out std_logic_vector(10 downto 0);
			data_symb   : in std_logic_vector(23 downto 0);
			symb_ready  : in std_logic;
			addr_pilot  : out std_logic_vector(10 downto 0);
			data_pilot  : in std_logic_vector(23 downto 0);
			pilot_ready : in std_logic;
			pilot_rx 	: out complex12;
			pilot_tx_signed : out std_logic;
			pilot_txrx_fin : out std_logic;
			valid : out std_logic
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
	
	    -- datagen component
    component datagen is
        generic(
            VERBOSE                  : boolean := false;                      --! Print more internal details
            DEBUG                    : boolean := false;                      --! Print debug info (developers only)
            STIMULI_FILE             : string  := "symbOFDM.txt";             --! File where data is stored
            STIMULI_NIBBLES          : integer := 2;                          --! Maximum hex chars for each input data 
            DATA_WIDTH               : integer := 8;                          --! Width of generated data
            THROUGHPUT               : integer := 0;                          --! Output 1 valid data each THROUGHPUT cycles
            INVALID_DATA             : datagen_invalid_data := unknown;       --! Output value when data is not valid
            CYCLES_AFTER_LAST_VECTOR : integer := 10                          --! Number of cycles between last data and assertion of endsim
            );
        port(
            clk       : in std_logic;                                 --! Align generated data to this clock
            can_write : in std_logic;                                 --! Active high, tells datagen it can assert valid. Use for control-flow
            data      : out std_logic_vector (DATA_WIDTH-1 downto 0); --! Generated data
            valid     : out std_logic;                                --! Active high, indicates data is valid
            endsim    : out std_logic                                 --! Active high, tells the other simulation processes to close their open files
            );
        end component;


	signal clk         	: std_logic;
	signal rst         	: std_logic;
	signal addr_symb   	: std_logic_vector(10 downto 0);
	signal data_symb   	: std_logic_vector(23 downto 0) := (others=>'0');
	signal symb_ready  	: std_logic := '0';
	signal addr_pilot  	: std_logic_vector(10 downto 0);
	signal data_pilot  	: std_logic_vector(23 downto 0) := (others=>'0');
	signal pilot_ready 	: std_logic := '0';
	signal pilot_rx 	: complex12;
	signal pilot_tx_signed : std_logic;
	signal pilot_txrx_fin : std_logic;
	signal valid 		: std_logic;
	
	signal endsim : std_logic := '0';
	signal start_sim :std_logic := '0';
	signal pilot_valid :std_logic;
	signal symb_valid :std_logic;

        
begin
 
    -- Clock manager instance
    clk_mng : clkmanager
        generic map(
            clk_period => 10 ns,
            rst_active_value => '1',
            rst_cycles => 1)
        port map (
            endsim => endsim,
            clk => clk,
            rst => rst
            );
			
    -- Data Gen : pilots tx or prbs(0:12:end)
    pilots_datagen : datagen
        generic map(
            VERBOSE                  => false,            --! Print more internal details
            DEBUG                    => false,            --! Print debug info (developers only)
            STIMULI_FILE             => "verification/matlab_tx_pilots.txt",   --! File where data is stored
            STIMULI_NIBBLES          => 6,                --! Number of hex chars in the line of the data file
            DATA_WIDTH               => 24,               --! Width of generated data = STIM_NIBB * 4hex
            THROUGHPUT               => 1,                --! Output 1 valid data each THROUGHPUT cycles
            INVALID_DATA             => keep,             --! Output value when data is not valid
            CYCLES_AFTER_LAST_VECTOR => 300)              --! Number of cycles between last data and assertion of endsim
        port map(
            clk       => clk,                           --! Align generated data to this clock
            can_write => start_sim,                       --! Active high, tells datagen it can assert valid. Use for control-flow
            data      => data_pilot, 						  --! Generated data
            valid     => pilot_valid,                        --! Active high, indicates data is valid
            endsim    => endsim                           --! Active high, tells the other simulation processes to close their open files
            );
 
    -- Data Gen : pilots rx or symb(0:12:end)
    symb_datagen : datagen
        generic map(
            VERBOSE                  => false,            --! Print more internal details
            DEBUG                    => false,            --! Print debug info (developers only)
            STIMULI_FILE             => "verification/matlab_rx_pilots.txt",   --! File where data is stored
            STIMULI_NIBBLES          => 6,                --! Number of hex chars in the line of the data file
            DATA_WIDTH               => 24,               --! Width of generated data = STIM_NIBB * 4hex
            THROUGHPUT               => 1,                --! Output 1 valid data each THROUGHPUT cycles
            INVALID_DATA             => keep,             --! Output value when data is not valid
            CYCLES_AFTER_LAST_VECTOR => 300)              --! Number of cycles between last data and assertion of endsim
        port map(
            clk       => clk,                           --! Align generated data to this clock
            can_write => start_sim,                       --! Active high, tells datagen it can assert valid. Use for control-flow
            data      => data_symb, 						  --! Generated data
            valid     => symb_valid,                        --! Active high, indicates data is valid
            endsim    => endsim                           --! Active high, tells the other simulation processes to close their open files
            );

    -- instantiate the unit under test (uut)
    uut_bloque_8 : bloque_8 
        port map (
            clk => clk,
			rst => rst,
			addr_symb   => addr_symb,
			data_symb   => data_symb,
			symb_ready  => symb_ready,
			addr_pilot  => addr_pilot,
			data_pilot  => data_pilot,
			pilot_ready => pilot_ready,
			pilot_rx 	=> pilot_rx,
			pilot_tx_signed => pilot_tx_signed,
			pilot_txrx_fin => pilot_txrx_fin,
			valid => valid 
			);
            
    -- stimulus process
    stim_proc: process
    begin		
        -- reset
        wait for 50 ns;
        symb_ready <= '1';
		pilot_ready <= '1';
		wait for 10 ns;
        start_sim <= '1';
    end process;

end;
