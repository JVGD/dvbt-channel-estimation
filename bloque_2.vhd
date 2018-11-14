library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vhdl_verification.all;


entity bloque_2 is
    port(
        data_b2     : out std_logic_vector(23 downto 0);    -- [Re(23,12), Im(11,0)]
        valid_b2    : out std_logic;                        -- 1 if data_in is ready
        clk_b2      : out std_logic;
        rst_b2      : out std_logic
        );
end bloque_2;

architecture behavioral of bloque_2 is

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

    -- clkmanager signals
    signal s_endsim_clk : std_logic := '0';    -- esta es IN para manejar el clk
	signal s_endsim_gen : std_logic := '0';    -- esta es IN para manejar el clk
	signal s_rst : std_logic;
    signal s_clk : std_logic := '1';
    
	-- datagen signals
	signal s_can_write : std_logic := '0';
	signal s_data_b2 : std_logic_vector(23 downto 0);
	signal s_valid_b2 : std_logic;
	
	-- datacompare signals
	


begin

    -- Clock manager instance
    bloque_1_clk : clkmanager
        generic map(
            clk_period => 10 ns,
            rst_active_value => '1',
            rst_cycles => 2
			)
        port map (
			endsim => s_endsim_clk,
			clk => s_clk,
			rst => s_rst
            );
    
    -- Data Gen
    bloque_1_datagen : datagen
        generic map(
            VERBOSE                  => false,            --! Print more internal details
            DEBUG                    => false,            --! Print debug info (developers only)
            STIMULI_FILE             => "symbOFDM.txt",   --! File where data is stored
            STIMULI_NIBBLES          => 6,                --! Number of hex chars in the line of the data file
            DATA_WIDTH               => 24,               --! Width of generated data = STIM_NIBB * 4hex
            THROUGHPUT               => 1,                --! Output 1 valid data each THROUGHPUT cycles
            INVALID_DATA             => keep,             --! Output value when data is not valid
            CYCLES_AFTER_LAST_VECTOR => 300)              --! Number of cycles between last data and assertion of endsim
        port map(
            clk       => s_clk,                           --! Align generated data to this clock
            can_write => s_can_write,                       --! Active high, tells datagen it can assert valid. Use for control-flow
            data      => s_data_b2, 						  --! Generated data
            valid     => s_valid_b2,                        --! Active high, indicates data is valid
            endsim    => s_endsim_gen                           --! Active high, tells the other simulation processes to close their open files
            );
			

    -- Outputing the CLK for the rest of the blocks
    data_b2 <= s_data_b2;
	valid_b2 <= s_valid_b2;
	clk_b2 <= s_clk;
    rst_b2 <= s_rst;
	
	-- for data gen
	s_can_write <= not(s_rst);

end behavioral;

