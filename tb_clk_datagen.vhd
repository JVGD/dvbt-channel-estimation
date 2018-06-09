library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vhdl_verification.all;

entity tb_clk_datagen is
end tb_clk_datagen;

architecture behavior of tb_clk_datagen is 

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


    -- Signals for Clock Manager
    -- No inicializamos rst y clk porque son out
    constant clk_period : time := 10 ns;
    signal rst : std_logic;
    signal clk : std_logic := '1';
    signal endsim : std_logic := '0';    -- esta es IN para manejar el clk

    -- Signals for Datagen
    -- No ponemos endsim porque ya ha sido declarada
    -- estas seales son OUT asi que no se inicializan
    --  data_in (23 downto 12) parte real
    --  data_in (11 downto 0) parte imaginaria
    signal data_in  : std_logic_vector (23 downto 0) := (others=>'0');
    signal valid : std_logic := '0';
    
    

begin

    -- Clock manager instance
    clk_mng : clkmanager
        generic map(
            clk_period => clk_period,
            rst_active_value => '1',
            rst_cycles => 2)
        port map (
            endsim => endsim,
            clk => clk,
            rst => rst
            );
    
    -- Data Gen
    data_gen : datagen
        generic map(
            VERBOSE                  => false,            --! Print more internal details
            DEBUG                    => false,            --! Print debug info (developers only)
            STIMULI_FILE             => "symbOFDM.txt",   --! File where data is stored
            STIMULI_NIBBLES          => 6,                --! Number of hex chars in the line of the data file
            DATA_WIDTH               => 24,               --! Width of generated data = STIM_NIBB * 4hex
            THROUGHPUT               => 4,                --! Output 1 valid data each THROUGHPUT cycles
            INVALID_DATA             => keep,             --! Output value when data is not valid
            CYCLES_AFTER_LAST_VECTOR => 300)              --! Number of cycles between last data and assertion of endsim
        port map(
            clk       => clk,                             --! Align generated data to this clock
            can_write => '1',                             --! Active high, tells datagen it can assert valid. Use for control-flow
            data      => data_in, 						  --! Generated data
            valid     => valid,                           --! Active high, indicates data is valid
            endsim    => endsim                           --! Active high, tells the other simulation processes to close their open files
            );
            
end;
