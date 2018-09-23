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
--	signal sup : complex12 := (re => (others=>'0'), im => (others=>'0'));
	signal sup : complex12:= (re => (others=>'0'), im => (others=>'0'));
	signal inf : complex12:= (re => (others=>'0'), im => (others=>'0'));
	signal valid : std_logic := '0';

	--outputs
	signal estim : complex12;
	signal estim_valid : std_logic;
	signal finished	: std_logic;
	
begin

	-- instantiate the unit under test (uut)
	uut: interpolador11 
		port map (
			clk => clk,
			finished => finished,
			rst => rst,
			sup => sup,
			inf => inf,
			valid => valid,
			estim => estim,
			estim_valid => estim_valid
			);			

	dump_bloque_9_pilots_est : datawrite
		generic map(
			SIMULATION_LABEL => "datawrite",            --! Allow to separate messages from different instances in SIMULATION
			VERBOSE => false,                          	--! Print more internal details
			DEBUG => false,                          	--! Print debug info (developers only)        
			OUTPUT_FILE => "verification/tb_interpoled_data.txt",    --! File where data will be stored
			OUTPUT_NIBBLES => 6,                        --! Hex chars on each output line 
			DATA_WIDTH => 24                            --! Width of input data
			)
		port map(
			clk => clk,             --! Will sample input on rising_edge of this clock
			data => estim.re & estim.im,
			valid  => estim_valid,    --! Active high, indicates data is valid
			endsim => '0'           --! Active high, tells the process to close its open files
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
			
		wait for 10 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"019";   -- d"1.562500" b"000000011001"
		inf.im <= x"ffa";   -- d"-0.375000" b"111111111010"
		sup.re <= x"012";   -- d"1.125000" b"000000010010"
		sup.im <= x"ff1";   -- d"-0.937500" b"111111110001"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"012";   -- d"1.125000" b"000000010010"
		inf.im <= x"ff1";   -- d"-0.937500" b"111111110001"
		sup.re <= x"00b";   -- d"0.687500" b"000000001011"
		sup.im <= x"ff4";   -- d"-0.750000" b"111111110100"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"00b";   -- d"0.687500" b"000000001011"
		inf.im <= x"ff4";   -- d"-0.750000" b"111111110100"
		sup.re <= x"010";   -- d"1.000000" b"000000010000"
		sup.im <= x"ff3";   -- d"-0.812500" b"111111110011"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"010";   -- d"1.000000" b"000000010000"
		inf.im <= x"ff3";   -- d"-0.812500" b"111111110011"
		sup.re <= x"010";   -- d"1.000000" b"000000010000"
		sup.im <= x"fe6";   -- d"-1.625000" b"111111100110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"010";   -- d"1.000000" b"000000010000"
		inf.im <= x"fe6";   -- d"-1.625000" b"111111100110"
		sup.re <= x"006";   -- d"0.375000" b"000000000110"
		sup.im <= x"fde";   -- d"-2.125000" b"111111011110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"006";   -- d"0.375000" b"000000000110"
		inf.im <= x"fde";   -- d"-2.125000" b"111111011110"
		sup.re <= x"ff7";   -- d"-0.562500" b"111111110111"
		sup.im <= x"fe3";   -- d"-1.812500" b"111111100011"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff7";   -- d"-0.562500" b"111111110111"
		inf.im <= x"fe3";   -- d"-1.812500" b"111111100011"
		sup.re <= x"fee";   -- d"-1.125000" b"111111101110"
		sup.im <= x"fe9";   -- d"-1.437500" b"111111101001"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"fee";   -- d"-1.125000" b"111111101110"
		inf.im <= x"fe9";   -- d"-1.437500" b"111111101001"
		sup.re <= x"feb";   -- d"-1.312500" b"111111101011"
		sup.im <= x"ff1";   -- d"-0.937500" b"111111110001"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"feb";   -- d"-1.312500" b"111111101011"
		inf.im <= x"ff1";   -- d"-0.937500" b"111111110001"
		sup.re <= x"feb";   -- d"-1.312500" b"111111101011"
		sup.im <= x"ffe";   -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"feb";   -- d"-1.312500" b"111111101011"
		inf.im <= x"ffe";   -- d"-0.125000" b"111111111110"
		sup.re <= x"ff2";   -- d"-0.875000" b"111111110010"
		sup.im <= x"000";   -- d"0.000000" b"000000000000"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff2";   -- d"-0.875000" b"111111110010"
		inf.im <= x"000";   -- d"0.000000" b"000000000000"
		sup.re <= x"ff4";   -- d"-0.750000" b"111111110100"
		sup.im <= x"ffe";   -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff4";   -- d"-0.750000" b"111111110100"
		inf.im <= x"ffe";   -- d"-0.125000" b"111111111110"
		sup.re <= x"fee";   -- d"-1.125000" b"111111101110"
		sup.im <= x"002";   -- d"0.125000" b"000000000010"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"fee";   -- d"-1.125000" b"111111101110"
		inf.im <= x"002";   -- d"0.125000" b"000000000010"
		sup.re <= x"ff5";   -- d"-0.687500" b"111111110101"
		sup.im <= x"00d";   -- d"0.812500" b"000000001101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff5";   -- d"-0.687500" b"111111110101"
		inf.im <= x"00d";   -- d"0.812500" b"000000001101"
		sup.re <= x"001";   -- d"0.062500" b"000000000001"
		sup.im <= x"00c";   -- d"0.750000" b"000000001100"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"001";   -- d"0.062500" b"000000000001"
		inf.im <= x"00c";   -- d"0.750000" b"000000001100"
		sup.re <= x"004";   -- d"0.250000" b"000000000100"
		sup.im <= x"004";   -- d"0.250000" b"000000000100"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"004";   -- d"0.250000" b"000000000100"
		inf.im <= x"004";   -- d"0.250000" b"000000000100"
		sup.re <= x"000";   -- d"0.000000" b"000000000000"
		sup.im <= x"fff";   -- d"-0.062500" b"111111111111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"000";   -- d"0.000000" b"000000000000"
		inf.im <= x"fff";   -- d"-0.062500" b"111111111111"
		sup.re <= x"ffb";   -- d"-0.312500" b"111111111011"
		sup.im <= x"ffe";   -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ffb";   -- d"-0.312500" b"111111111011"
		inf.im <= x"ffe";   -- d"-0.125000" b"111111111110"
		sup.re <= x"ff4";   -- d"-0.750000" b"111111110100"
		sup.im <= x"003";   -- d"0.187500" b"000000000011"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff4";   -- d"-0.750000" b"111111110100"
		inf.im <= x"003";   -- d"0.187500" b"000000000011"
		sup.re <= x"ff4";   -- d"-0.750000" b"111111110100"
		sup.im <= x"012";   -- d"1.125000" b"000000010010"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff4";   -- d"-0.750000" b"111111110100"
		inf.im <= x"012";   -- d"1.125000" b"000000010010"
		sup.re <= x"003";   -- d"0.187500" b"000000000011"
		sup.im <= x"01b";   -- d"1.687500" b"000000011011"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"003";   -- d"0.187500" b"000000000011"
		inf.im <= x"01b";   -- d"1.687500" b"000000011011"
		sup.re <= x"018";   -- d"1.500000" b"000000011000"
		sup.im <= x"00f";   -- d"0.937500" b"000000001111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"018";   -- d"1.500000" b"000000011000"
		inf.im <= x"00f";   -- d"0.937500" b"000000001111"
		sup.re <= x"015";   -- d"1.312500" b"000000010101"
		sup.im <= x"fff";   -- d"-0.062500" b"111111111111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"015";   -- d"1.312500" b"000000010101"
		inf.im <= x"fff";   -- d"-0.062500" b"111111111111"
		sup.re <= x"00c";   -- d"0.750000" b"000000001100"
		sup.im <= x"ff9";   -- d"-0.437500" b"111111111001"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"00c";   -- d"0.750000" b"000000001100"
		inf.im <= x"ff9";   -- d"-0.437500" b"111111111001"
		sup.re <= x"006";   -- d"0.375000" b"000000000110"
		sup.im <= x"ff9";   -- d"-0.437500" b"111111111001"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"006";   -- d"0.375000" b"000000000110"
		inf.im <= x"ff9";   -- d"-0.437500" b"111111111001"
		sup.re <= x"002";   -- d"0.125000" b"000000000010"
		sup.im <= x"fff";   -- d"-0.062500" b"111111111111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"002";   -- d"0.125000" b"000000000010"
		inf.im <= x"fff";   -- d"-0.062500" b"111111111111"
		sup.re <= x"004";   -- d"0.250000" b"000000000100"
		sup.im <= x"006";   -- d"0.375000" b"000000000110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"004";   -- d"0.250000" b"000000000100"
		inf.im <= x"006";   -- d"0.375000" b"000000000110"
		sup.re <= x"010";   -- d"1.000000" b"000000010000"
		sup.im <= x"004";   -- d"0.250000" b"000000000100"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"010";   -- d"1.000000" b"000000010000"
		inf.im <= x"004";   -- d"0.250000" b"000000000100"
		sup.re <= x"010";   -- d"1.000000" b"000000010000"
		sup.im <= x"ff6";   -- d"-0.625000" b"111111110110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"010";   -- d"1.000000" b"000000010000"
		inf.im <= x"ff6";   -- d"-0.625000" b"111111110110"
		sup.re <= x"006";   -- d"0.375000" b"000000000110"
		sup.im <= x"ff3";   -- d"-0.812500" b"111111110011"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"006";   -- d"0.375000" b"000000000110"
		inf.im <= x"ff3";   -- d"-0.812500" b"111111110011"
		sup.re <= x"fff";   -- d"-0.062500" b"111111111111"
		sup.im <= x"ffa";   -- d"-0.375000" b"111111111010"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"fff";   -- d"-0.062500" b"111111111111"
		inf.im <= x"ffa";   -- d"-0.375000" b"111111111010"
		sup.re <= x"004";   -- d"0.250000" b"000000000100"
		sup.im <= x"000";   -- d"0.000000" b"000000000000"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"004";   -- d"0.250000" b"000000000100"
		inf.im <= x"000";   -- d"0.000000" b"000000000000"
		sup.re <= x"009";   -- d"0.562500" b"000000001001"
		sup.im <= x"ffe";   -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"009";   -- d"0.562500" b"000000001001"
		inf.im <= x"ffe";   -- d"-0.125000" b"111111111110"
		sup.re <= x"00d";   -- d"0.812500" b"000000001101"
		sup.im <= x"ffa";   -- d"-0.375000" b"111111111010"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"00d";   -- d"0.812500" b"000000001101"
		inf.im <= x"ffa";   -- d"-0.375000" b"111111111010"
		sup.re <= x"00c";   -- d"0.750000" b"000000001100"
		sup.im <= x"ff4";   -- d"-0.750000" b"111111110100"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"00c";   -- d"0.750000" b"000000001100"
		inf.im <= x"ff4";   -- d"-0.750000" b"111111110100"
		sup.re <= x"004";   -- d"0.250000" b"000000000100"
		sup.im <= x"fed";   -- d"-1.187500" b"111111101101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"004";   -- d"0.250000" b"000000000100"
		inf.im <= x"fed";   -- d"-1.187500" b"111111101101"
		sup.re <= x"ff7";   -- d"-0.562500" b"111111110111"
		sup.im <= x"ff2";   -- d"-0.875000" b"111111110010"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff7";   -- d"-0.562500" b"111111110111"
		inf.im <= x"ff2";   -- d"-0.875000" b"111111110010"
		sup.re <= x"ff6";   -- d"-0.625000" b"111111110110"
		sup.im <= x"000";   -- d"0.000000" b"000000000000"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff6";   -- d"-0.625000" b"111111110110"
		inf.im <= x"000";   -- d"0.000000" b"000000000000"
		sup.re <= x"001";   -- d"0.062500" b"000000000001"
		sup.im <= x"004";   -- d"0.250000" b"000000000100"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"001";   -- d"0.062500" b"000000000001"
		inf.im <= x"004";   -- d"0.250000" b"000000000100"
		sup.re <= x"006";   -- d"0.375000" b"000000000110"
		sup.im <= x"000";   -- d"0.000000" b"000000000000"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"006";   -- d"0.375000" b"000000000110"
		inf.im <= x"000";   -- d"0.000000" b"000000000000"
		sup.re <= x"008";   -- d"0.500000" b"000000001000"
		sup.im <= x"ffe";   -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"008";   -- d"0.500000" b"000000001000"
		inf.im <= x"ffe";   -- d"-0.125000" b"111111111110"
		sup.re <= x"00d";   -- d"0.812500" b"000000001101"
		sup.im <= x"ffb";   -- d"-0.312500" b"111111111011"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"00d";   -- d"0.812500" b"000000001101"
		inf.im <= x"ffb";   -- d"-0.312500" b"111111111011"
		sup.re <= x"00e";   -- d"0.875000" b"000000001110"
		sup.im <= x"ff2";   -- d"-0.875000" b"111111110010"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"00e";   -- d"0.875000" b"000000001110"
		inf.im <= x"ff2";   -- d"-0.875000" b"111111110010"
		sup.re <= x"005";   -- d"0.312500" b"000000000101"
		sup.im <= x"fee";   -- d"-1.125000" b"111111101110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"005";   -- d"0.312500" b"000000000101"
		inf.im <= x"fee";   -- d"-1.125000" b"111111101110"
		sup.re <= x"002";   -- d"0.125000" b"000000000010"
		sup.im <= x"fee";   -- d"-1.125000" b"111111101110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"002";   -- d"0.125000" b"000000000010"
		inf.im <= x"fee";   -- d"-1.125000" b"111111101110"
		sup.re <= x"ffe";   -- d"-0.125000" b"111111111110"
		sup.im <= x"fea";   -- d"-1.375000" b"111111101010"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ffe";   -- d"-0.125000" b"111111111110"
		inf.im <= x"fea";   -- d"-1.375000" b"111111101010"
		sup.re <= x"ff2";   -- d"-0.875000" b"111111110010"
		sup.im <= x"feb";   -- d"-1.312500" b"111111101011"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff2";   -- d"-0.875000" b"111111110010"
		inf.im <= x"feb";   -- d"-1.312500" b"111111101011"
		sup.re <= x"fed";   -- d"-1.187500" b"111111101101"
		sup.im <= x"ff8";   -- d"-0.500000" b"111111111000"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"fed";   -- d"-1.187500" b"111111101101"
		inf.im <= x"ff8";   -- d"-0.500000" b"111111111000"
		sup.re <= x"ff5";   -- d"-0.687500" b"111111110101"
		sup.im <= x"001";   -- d"0.062500" b"000000000001"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff5";   -- d"-0.687500" b"111111110101"
		inf.im <= x"001";   -- d"0.062500" b"000000000001"
		sup.re <= x"ffd";   -- d"-0.187500" b"111111111101"
		sup.im <= x"ffe";   -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ffd";   -- d"-0.187500" b"111111111101"
		inf.im <= x"ffe";   -- d"-0.125000" b"111111111110"
		sup.re <= x"ffd";   -- d"-0.187500" b"111111111101"
		sup.im <= x"ffb";   -- d"-0.312500" b"111111111011"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ffd";   -- d"-0.187500" b"111111111101"
		inf.im <= x"ffb";   -- d"-0.312500" b"111111111011"
		sup.re <= x"ffe";   -- d"-0.125000" b"111111111110"
		sup.im <= x"ffb";   -- d"-0.312500" b"111111111011"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ffe";   -- d"-0.125000" b"111111111110"
		inf.im <= x"ffb";   -- d"-0.312500" b"111111111011"
		sup.re <= x"ffd";   -- d"-0.187500" b"111111111101"
		sup.im <= x"ff7";   -- d"-0.562500" b"111111110111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ffd";   -- d"-0.187500" b"111111111101"
		inf.im <= x"ff7";   -- d"-0.562500" b"111111110111"
		sup.re <= x"ff8";   -- d"-0.500000" b"111111111000"
		sup.im <= x"ff9";   -- d"-0.437500" b"111111111001"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff8";   -- d"-0.500000" b"111111111000"
		inf.im <= x"ff9";   -- d"-0.437500" b"111111111001"
		sup.re <= x"ffa";   -- d"-0.375000" b"111111111010"
		sup.im <= x"000";   -- d"0.000000" b"000000000000"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ffa";   -- d"-0.375000" b"111111111010"
		inf.im <= x"000";   -- d"0.000000" b"000000000000"
		sup.re <= x"002";   -- d"0.125000" b"000000000010"
		sup.im <= x"ffe";   -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"002";   -- d"0.125000" b"000000000010"
		inf.im <= x"ffe";   -- d"-0.125000" b"111111111110"
		sup.re <= x"001";   -- d"0.062500" b"000000000001"
		sup.im <= x"ff4";   -- d"-0.750000" b"111111110100"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"001";   -- d"0.062500" b"000000000001"
		inf.im <= x"ff4";   -- d"-0.750000" b"111111110100"
		sup.re <= x"ff6";   -- d"-0.625000" b"111111110110"
		sup.im <= x"ff5";   -- d"-0.687500" b"111111110101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff6";   -- d"-0.625000" b"111111110110"
		inf.im <= x"ff5";   -- d"-0.687500" b"111111110101"
		sup.re <= x"ff3";   -- d"-0.812500" b"111111110011"
		sup.im <= x"ffc";   -- d"-0.250000" b"111111111100"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff3";   -- d"-0.812500" b"111111110011"
		inf.im <= x"ffc";   -- d"-0.250000" b"111111111100"
		sup.re <= x"ff6";   -- d"-0.625000" b"111111110110"
		sup.im <= x"000";   -- d"0.000000" b"000000000000"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff6";   -- d"-0.625000" b"111111110110"
		inf.im <= x"000";   -- d"0.000000" b"000000000000"
		sup.re <= x"ff9";   -- d"-0.437500" b"111111111001"
		sup.im <= x"003";   -- d"0.187500" b"000000000011"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff9";   -- d"-0.437500" b"111111111001"
		inf.im <= x"003";   -- d"0.187500" b"000000000011"
		sup.re <= x"002";   -- d"0.125000" b"000000000010"
		sup.im <= x"004";   -- d"0.250000" b"000000000100"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"002";   -- d"0.125000" b"000000000010"
		inf.im <= x"004";   -- d"0.250000" b"000000000100"
		sup.re <= x"007";   -- d"0.437500" b"000000000111"
		sup.im <= x"ffa";   -- d"-0.375000" b"111111111010"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"007";   -- d"0.437500" b"000000000111"
		inf.im <= x"ffa";   -- d"-0.375000" b"111111111010"
		sup.re <= x"ffc";   -- d"-0.250000" b"111111111100"
		sup.im <= x"fee";   -- d"-1.125000" b"111111101110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ffc";   -- d"-0.250000" b"111111111100"
		inf.im <= x"fee";   -- d"-1.125000" b"111111101110"
		sup.re <= x"fed";   -- d"-1.187500" b"111111101101"
		sup.im <= x"ff3";   -- d"-0.812500" b"111111110011"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"fed";   -- d"-1.187500" b"111111101101"
		inf.im <= x"ff3";   -- d"-0.812500" b"111111110011"
		sup.re <= x"feb";   -- d"-1.312500" b"111111101011"
		sup.im <= x"002";   -- d"0.125000" b"000000000010"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"feb";   -- d"-1.312500" b"111111101011"
		inf.im <= x"002";   -- d"0.125000" b"000000000010"
		sup.re <= x"ff0";   -- d"-1.000000" b"111111110000"
		sup.im <= x"009";   -- d"0.562500" b"000000001001"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff0";   -- d"-1.000000" b"111111110000"
		inf.im <= x"009";   -- d"0.562500" b"000000001001"
		sup.re <= x"ff8";   -- d"-0.500000" b"111111111000"
		sup.im <= x"00f";   -- d"0.937500" b"000000001111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff8";   -- d"-0.500000" b"111111111000"
		inf.im <= x"00f";   -- d"0.937500" b"000000001111"
		sup.re <= x"003";   -- d"0.187500" b"000000000011"
		sup.im <= x"00f";   -- d"0.937500" b"000000001111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"003";   -- d"0.187500" b"000000000011"
		inf.im <= x"00f";   -- d"0.937500" b"000000001111"
		sup.re <= x"00a";   -- d"0.625000" b"000000001010"
		sup.im <= x"006";   -- d"0.375000" b"000000000110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"00a";   -- d"0.625000" b"000000001010"
		inf.im <= x"006";   -- d"0.375000" b"000000000110"
		sup.re <= x"006";   -- d"0.375000" b"000000000110"
		sup.im <= x"ffd";   -- d"-0.187500" b"111111111101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"006";   -- d"0.375000" b"000000000110"
		inf.im <= x"ffd";   -- d"-0.187500" b"111111111101"
		sup.re <= x"000";   -- d"0.000000" b"000000000000"
		sup.im <= x"fff";   -- d"-0.062500" b"111111111111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"000";   -- d"0.000000" b"000000000000"
		inf.im <= x"fff";   -- d"-0.062500" b"111111111111"
		sup.re <= x"003";   -- d"0.187500" b"000000000011"
		sup.im <= x"002";   -- d"0.125000" b"000000000010"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"003";   -- d"0.187500" b"000000000011"
		inf.im <= x"002";   -- d"0.125000" b"000000000010"
		sup.re <= x"005";   -- d"0.312500" b"000000000101"
		sup.im <= x"ffe";   -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"005";   -- d"0.312500" b"000000000101"
		inf.im <= x"ffe";   -- d"-0.125000" b"111111111110"
		sup.re <= x"001";   -- d"0.062500" b"000000000001"
		sup.im <= x"ffc";   -- d"-0.250000" b"111111111100"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"001";   -- d"0.062500" b"000000000001"
		inf.im <= x"ffc";   -- d"-0.250000" b"111111111100"
		sup.re <= x"002";   -- d"0.125000" b"000000000010"
		sup.im <= x"ffe";   -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"002";   -- d"0.125000" b"000000000010"
		inf.im <= x"ffe";   -- d"-0.125000" b"111111111110"
		sup.re <= x"002";   -- d"0.125000" b"000000000010"
		sup.im <= x"ffc";   -- d"-0.250000" b"111111111100"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"002";   -- d"0.125000" b"000000000010"
		inf.im <= x"ffc";   -- d"-0.250000" b"111111111100"
		sup.re <= x"ffd";   -- d"-0.187500" b"111111111101"
		sup.im <= x"ffc";   -- d"-0.250000" b"111111111100"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ffd";   -- d"-0.187500" b"111111111101"
		inf.im <= x"ffc";   -- d"-0.250000" b"111111111100"
		sup.re <= x"ffe";   -- d"-0.125000" b"111111111110"
		sup.im <= x"004";   -- d"0.250000" b"000000000100"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ffe";   -- d"-0.125000" b"111111111110"
		inf.im <= x"004";   -- d"0.250000" b"000000000100"
		sup.re <= x"008";   -- d"0.500000" b"000000001000"
		sup.im <= x"005";   -- d"0.312500" b"000000000101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"008";   -- d"0.500000" b"000000001000"
		inf.im <= x"005";   -- d"0.312500" b"000000000101"
		sup.re <= x"00d";   -- d"0.812500" b"000000001101"
		sup.im <= x"ffd";   -- d"-0.187500" b"111111111101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"00d";   -- d"0.812500" b"000000001101"
		inf.im <= x"ffd";   -- d"-0.187500" b"111111111101"
		sup.re <= x"00b";   -- d"0.687500" b"000000001011"
		sup.im <= x"ff7";   -- d"-0.562500" b"111111110111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"00b";   -- d"0.687500" b"000000001011"
		inf.im <= x"ff7";   -- d"-0.562500" b"111111110111"
		sup.re <= x"00a";   -- d"0.625000" b"000000001010"
		sup.im <= x"ff2";   -- d"-0.875000" b"111111110010"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"00a";   -- d"0.625000" b"000000001010"
		inf.im <= x"ff2";   -- d"-0.875000" b"111111110010"
		sup.re <= x"006";   -- d"0.375000" b"000000000110"
		sup.im <= x"fed";   -- d"-1.187500" b"111111101101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"006";   -- d"0.375000" b"000000000110"
		inf.im <= x"fed";   -- d"-1.187500" b"111111101101"
		sup.re <= x"ff9";   -- d"-0.437500" b"111111111001"
		sup.im <= x"fe8";   -- d"-1.500000" b"111111101000"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff9";   -- d"-0.437500" b"111111111001"
		inf.im <= x"fe8";   -- d"-1.500000" b"111111101000"
		sup.re <= x"ff5";   -- d"-0.687500" b"111111110101"
		sup.im <= x"ff3";   -- d"-0.812500" b"111111110011"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff5";   -- d"-0.687500" b"111111110101"
		inf.im <= x"ff3";   -- d"-0.812500" b"111111110011"
		sup.re <= x"ff7";   -- d"-0.562500" b"111111110111"
		sup.im <= x"ff7";   -- d"-0.562500" b"111111110111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff7";   -- d"-0.562500" b"111111110111"
		inf.im <= x"ff7";   -- d"-0.562500" b"111111110111"
		sup.re <= x"ff6";   -- d"-0.625000" b"111111110110"
		sup.im <= x"ff7";   -- d"-0.562500" b"111111110111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff6";   -- d"-0.625000" b"111111110110"
		inf.im <= x"ff7";   -- d"-0.562500" b"111111110111"
		sup.re <= x"ff5";   -- d"-0.687500" b"111111110101"
		sup.im <= x"ffc";   -- d"-0.250000" b"111111111100"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff5";   -- d"-0.687500" b"111111110101"
		inf.im <= x"ffc";   -- d"-0.250000" b"111111111100"
		sup.re <= x"ffb";   -- d"-0.312500" b"111111111011"
		sup.im <= x"ffd";   -- d"-0.187500" b"111111111101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ffb";   -- d"-0.312500" b"111111111011"
		inf.im <= x"ffd";   -- d"-0.187500" b"111111111101"
		sup.re <= x"ffe";   -- d"-0.125000" b"111111111110"
		sup.im <= x"ff5";   -- d"-0.687500" b"111111110101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ffe";   -- d"-0.125000" b"111111111110"
		inf.im <= x"ff5";   -- d"-0.687500" b"111111110101"
		sup.re <= x"ff6";   -- d"-0.625000" b"111111110110"
		sup.im <= x"fef";   -- d"-1.062500" b"111111101111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff6";   -- d"-0.625000" b"111111110110"
		inf.im <= x"fef";   -- d"-1.062500" b"111111101111"
		sup.re <= x"fee";   -- d"-1.125000" b"111111101110"
		sup.im <= x"ff5";   -- d"-0.687500" b"111111110101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"fee";   -- d"-1.125000" b"111111101110"
		inf.im <= x"ff5";   -- d"-0.687500" b"111111110101"
		sup.re <= x"fee";   -- d"-1.125000" b"111111101110"
		sup.im <= x"ff7";   -- d"-0.562500" b"111111110111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"fee";   -- d"-1.125000" b"111111101110"
		inf.im <= x"ff7";   -- d"-0.562500" b"111111110111"
		sup.re <= x"fe8";   -- d"-1.500000" b"111111101000"
		sup.im <= x"ffc";   -- d"-0.250000" b"111111111100"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"fe8";   -- d"-1.500000" b"111111101000"
		inf.im <= x"ffc";   -- d"-0.250000" b"111111111100"
		sup.re <= x"fea";   -- d"-1.375000" b"111111101010"
		sup.im <= x"005";   -- d"0.312500" b"000000000101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"fea";   -- d"-1.375000" b"111111101010"
		inf.im <= x"005";   -- d"0.312500" b"000000000101"
		sup.re <= x"ff3";   -- d"-0.812500" b"111111110011"
		sup.im <= x"009";   -- d"0.562500" b"000000001001"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff3";   -- d"-0.812500" b"111111110011"
		inf.im <= x"009";   -- d"0.562500" b"000000001001"
		sup.re <= x"ff7";   -- d"-0.562500" b"111111110111"
		sup.im <= x"004";   -- d"0.250000" b"000000000100"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff7";   -- d"-0.562500" b"111111110111"
		inf.im <= x"004";   -- d"0.250000" b"000000000100"
		sup.re <= x"ff1";   -- d"-0.937500" b"111111110001"
		sup.im <= x"002";   -- d"0.125000" b"000000000010"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff1";   -- d"-0.937500" b"111111110001"
		inf.im <= x"002";   -- d"0.125000" b"000000000010"
		sup.re <= x"ff1";   -- d"-0.937500" b"111111110001"
		sup.im <= x"006";   -- d"0.375000" b"000000000110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff1";   -- d"-0.937500" b"111111110001"
		inf.im <= x"006";   -- d"0.375000" b"000000000110"
		sup.re <= x"ff3";   -- d"-0.812500" b"111111110011"
		sup.im <= x"008";   -- d"0.500000" b"000000001000"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff3";   -- d"-0.812500" b"111111110011"
		inf.im <= x"008";   -- d"0.500000" b"000000001000"
		sup.re <= x"ff0";   -- d"-1.000000" b"111111110000"
		sup.im <= x"008";   -- d"0.500000" b"000000001000"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff0";   -- d"-1.000000" b"111111110000"
		inf.im <= x"008";   -- d"0.500000" b"000000001000"
		sup.re <= x"ff1";   -- d"-0.937500" b"111111110001"
		sup.im <= x"00c";   -- d"0.750000" b"000000001100"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff1";   -- d"-0.937500" b"111111110001"
		inf.im <= x"00c";   -- d"0.750000" b"000000001100"
		sup.re <= x"ff8";   -- d"-0.500000" b"111111111000"
		sup.im <= x"00b";   -- d"0.687500" b"000000001011"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff8";   -- d"-0.500000" b"111111111000"
		inf.im <= x"00b";   -- d"0.687500" b"000000001011"
		sup.re <= x"ff4";   -- d"-0.750000" b"111111110100"
		sup.im <= x"009";   -- d"0.562500" b"000000001001"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff4";   -- d"-0.750000" b"111111110100"
		inf.im <= x"009";   -- d"0.562500" b"000000001001"
		sup.re <= x"fec";   -- d"-1.250000" b"111111101100"
		sup.im <= x"010";   -- d"1.000000" b"000000010000"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"fec";   -- d"-1.250000" b"111111101100"
		inf.im <= x"010";   -- d"1.000000" b"000000010000"
		sup.re <= x"fef";   -- d"-1.062500" b"111111101111"
		sup.im <= x"01d";   -- d"1.812500" b"000000011101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"fef";   -- d"-1.062500" b"111111101111"
		inf.im <= x"01d";   -- d"1.812500" b"000000011101"
		sup.re <= x"002";   -- d"0.125000" b"000000000010"
		sup.im <= x"027";   -- d"2.437500" b"000000100111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"002";   -- d"0.125000" b"000000000010"
		inf.im <= x"027";   -- d"2.437500" b"000000100111"
		sup.re <= x"00f";   -- d"0.937500" b"000000001111"
		sup.im <= x"01f";   -- d"1.937500" b"000000011111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"00f";   -- d"0.937500" b"000000001111"
		inf.im <= x"01f";   -- d"1.937500" b"000000011111"
		sup.re <= x"017";   -- d"1.437500" b"000000010111"
		sup.im <= x"01a";   -- d"1.625000" b"000000011010"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"017";   -- d"1.437500" b"000000010111"
		inf.im <= x"01a";   -- d"1.625000" b"000000011010"
		sup.re <= x"01b";   -- d"1.687500" b"000000011011"
		sup.im <= x"006";   -- d"0.375000" b"000000000110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"01b";   -- d"1.687500" b"000000011011"
		inf.im <= x"006";   -- d"0.375000" b"000000000110"
		sup.re <= x"015";   -- d"1.312500" b"000000010101"
		sup.im <= x"ffb";   -- d"-0.312500" b"111111111011"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"015";   -- d"1.312500" b"000000010101"
		inf.im <= x"ffb";   -- d"-0.312500" b"111111111011"
		sup.re <= x"008";   -- d"0.500000" b"000000001000"
		sup.im <= x"ffd";   -- d"-0.187500" b"111111111101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"008";   -- d"0.500000" b"000000001000"
		inf.im <= x"ffd";   -- d"-0.187500" b"111111111101"
		sup.re <= x"008";   -- d"0.500000" b"000000001000"
		sup.im <= x"007";   -- d"0.437500" b"000000000111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"008";   -- d"0.500000" b"000000001000"
		inf.im <= x"007";   -- d"0.437500" b"000000000111"
		sup.re <= x"010";   -- d"1.000000" b"000000010000"
		sup.im <= x"005";   -- d"0.312500" b"000000000101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"010";   -- d"1.000000" b"000000010000"
		inf.im <= x"005";   -- d"0.312500" b"000000000101"
		sup.re <= x"013";   -- d"1.187500" b"000000010011"
		sup.im <= x"fff";   -- d"-0.062500" b"111111111111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"013";   -- d"1.187500" b"000000010011"
		inf.im <= x"fff";   -- d"-0.062500" b"111111111111"
		sup.re <= x"012";   -- d"1.125000" b"000000010010"
		sup.im <= x"ffd";   -- d"-0.187500" b"111111111101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"012";   -- d"1.125000" b"000000010010"
		inf.im <= x"ffd";   -- d"-0.187500" b"111111111101"
		sup.re <= x"011";   -- d"1.062500" b"000000010001"
		sup.im <= x"ff5";   -- d"-0.687500" b"111111110101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"011";   -- d"1.062500" b"000000010001"
		inf.im <= x"ff5";   -- d"-0.687500" b"111111110101"
		sup.re <= x"00a";   -- d"0.625000" b"000000001010"
		sup.im <= x"fef";   -- d"-1.062500" b"111111101111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"00a";   -- d"0.625000" b"000000001010"
		inf.im <= x"fef";   -- d"-1.062500" b"111111101111"
		sup.re <= x"005";   -- d"0.312500" b"000000000101"
		sup.im <= x"ff5";   -- d"-0.687500" b"111111110101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"005";   -- d"0.312500" b"000000000101"
		inf.im <= x"ff5";   -- d"-0.687500" b"111111110101"
		sup.re <= x"009";   -- d"0.562500" b"000000001001"
		sup.im <= x"ff6";   -- d"-0.625000" b"111111110110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"009";   -- d"0.562500" b"000000001001"
		inf.im <= x"ff6";   -- d"-0.625000" b"111111110110"
		sup.re <= x"00b";   -- d"0.687500" b"000000001011"
		sup.im <= x"fee";   -- d"-1.125000" b"111111101110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"00b";   -- d"0.687500" b"000000001011"
		inf.im <= x"fee";   -- d"-1.125000" b"111111101110"
		sup.re <= x"ffe";   -- d"-0.125000" b"111111111110"
		sup.im <= x"fe5";   -- d"-1.687500" b"111111100101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ffe";   -- d"-0.125000" b"111111111110"
		inf.im <= x"fe5";   -- d"-1.687500" b"111111100101"
		sup.re <= x"ff6";   -- d"-0.625000" b"111111110110"
		sup.im <= x"fed";   -- d"-1.187500" b"111111101101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff6";   -- d"-0.625000" b"111111110110"
		inf.im <= x"fed";   -- d"-1.187500" b"111111101101"
		sup.re <= x"ff2";   -- d"-0.875000" b"111111110010"
		sup.im <= x"ff3";   -- d"-0.812500" b"111111110011"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff2";   -- d"-0.875000" b"111111110010"
		inf.im <= x"ff3";   -- d"-0.812500" b"111111110011"
		sup.re <= x"ff0";   -- d"-1.000000" b"111111110000"
		sup.im <= x"ff7";   -- d"-0.562500" b"111111110111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff0";   -- d"-1.000000" b"111111110000"
		inf.im <= x"ff7";   -- d"-0.562500" b"111111110111"
		sup.re <= x"ff0";   -- d"-1.000000" b"111111110000"
		sup.im <= x"ffe";   -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff0";   -- d"-1.000000" b"111111110000"
		inf.im <= x"ffe";   -- d"-0.125000" b"111111111110"
		sup.re <= x"ff7";   -- d"-0.562500" b"111111110111"
		sup.im <= x"000";   -- d"0.000000" b"000000000000"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff7";   -- d"-0.562500" b"111111110111"
		inf.im <= x"000";   -- d"0.000000" b"000000000000"
		sup.re <= x"ff8";   -- d"-0.500000" b"111111111000"
		sup.im <= x"ffc";   -- d"-0.250000" b"111111111100"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff8";   -- d"-0.500000" b"111111111000"
		inf.im <= x"ffc";   -- d"-0.250000" b"111111111100"
		sup.re <= x"ff0";   -- d"-1.000000" b"111111110000"
		sup.im <= x"ffc";   -- d"-0.250000" b"111111111100"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff0";   -- d"-1.000000" b"111111110000"
		inf.im <= x"ffc";   -- d"-0.250000" b"111111111100"
		sup.re <= x"ff1";   -- d"-0.937500" b"111111110001"
		sup.im <= x"005";   -- d"0.312500" b"000000000101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff1";   -- d"-0.937500" b"111111110001"
		inf.im <= x"005";   -- d"0.312500" b"000000000101"
		sup.re <= x"ff7";   -- d"-0.562500" b"111111110111"
		sup.im <= x"003";   -- d"0.187500" b"000000000011"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff7";   -- d"-0.562500" b"111111110111"
		inf.im <= x"003";   -- d"0.187500" b"000000000011"
		sup.re <= x"ff3";   -- d"-0.812500" b"111111110011"
		sup.im <= x"002";   -- d"0.125000" b"000000000010"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff3";   -- d"-0.812500" b"111111110011"
		inf.im <= x"002";   -- d"0.125000" b"000000000010"
		sup.re <= x"fec";   -- d"-1.250000" b"111111101100"
		sup.im <= x"008";   -- d"0.500000" b"000000001000"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"fec";   -- d"-1.250000" b"111111101100"
		inf.im <= x"008";   -- d"0.500000" b"000000001000"
		sup.re <= x"ff1";   -- d"-0.937500" b"111111110001"
		sup.im <= x"00f";   -- d"0.937500" b"000000001111"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff1";   -- d"-0.937500" b"111111110001"
		inf.im <= x"00f";   -- d"0.937500" b"000000001111"
		sup.re <= x"ff6";   -- d"-0.625000" b"111111110110"
		sup.im <= x"019";   -- d"1.562500" b"000000011001"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"ff6";   -- d"-0.625000" b"111111110110"
		inf.im <= x"019";   -- d"1.562500" b"000000011001"
		sup.re <= x"002";   -- d"0.125000" b"000000000010"
		sup.im <= x"01e";   -- d"1.875000" b"000000011110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"002";   -- d"0.125000" b"000000000010"
		inf.im <= x"01e";   -- d"1.875000" b"000000011110"
		sup.re <= x"011";   -- d"1.062500" b"000000010001"
		sup.im <= x"01a";   -- d"1.625000" b"000000011010"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"011";   -- d"1.062500" b"000000010001"
		inf.im <= x"01a";   -- d"1.625000" b"000000011010"
		sup.re <= x"017";   -- d"1.437500" b"000000010111"
		sup.im <= x"00a";   -- d"0.625000" b"000000001010"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"017";   -- d"1.437500" b"000000010111"
		inf.im <= x"00a";   -- d"0.625000" b"000000001010"
		sup.re <= x"00e";   -- d"0.875000" b"000000001110"
		sup.im <= x"ffa";   -- d"-0.375000" b"111111111010"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"00e";   -- d"0.875000" b"000000001110"
		inf.im <= x"ffa";   -- d"-0.375000" b"111111111010"
		sup.re <= x"001";   -- d"0.062500" b"000000000001"
		sup.im <= x"ffd";   -- d"-0.187500" b"111111111101"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"001";   -- d"0.062500" b"000000000001"
		inf.im <= x"ffd";   -- d"-0.187500" b"111111111101"
		sup.re <= x"001";   -- d"0.062500" b"000000000001"
		sup.im <= x"006";   -- d"0.375000" b"000000000110"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data

		wait for 250 ns;
		valid <= '1';   -- inf and sup valid data
		inf.re <= x"001";   -- d"0.062500" b"000000000001"
		inf.im <= x"006";   -- d"0.375000" b"000000000110"
		sup.re <= x"005";   -- d"0.312500" b"000000000101"
		sup.im <= x"008";   -- d"0.500000" b"000000001000"

		wait for 10 ns;
		valid <= '0';   -- inf and sup valid data
				

		wait;
	end process;

end;
