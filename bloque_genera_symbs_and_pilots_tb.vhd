library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mi_paquete.all;
 
entity bloque_genera_sybms_and_pilots_tb is
end bloque_genera_sybms_and_pilots_tb;
 
architecture behavior of bloque_genera_sybms_and_pilots_tb is 
     
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
			pilot_tx_signed : out std_logic
			);
        end component;
        
    component bloque_genera_symbOFDM
        port(
            clk         : out std_logic;
            rst         : out std_logic;
            addr_symb   : in  std_logic_vector(10 downto 0);
            data_symb   : out std_logic_vector(23 downto 0);
            symb_ready  : out std_logic
            );
        end component;
        
    component bloque_genera_pilots
        port(
            clk          : in std_logic;
            rst          : in std_logic;
            addr_pilots  : in  std_logic_vector(10 downto 0);
            data_pilots  : out std_logic_vector(23 downto 0);
            pilots_ready : out std_logic
            );
        end component;        
            
    signal s_clk : std_logic;
    signal s_rst : std_logic;

    signal s_addr_symb : std_logic_vector(10 downto 0) := (others=>'0');
    signal s_data_symb : std_logic_vector(23 downto 0) := (others=>'0');
    signal s_symb_ready : std_logic;

    signal s_addr_pilot : std_logic_vector(10 downto 0) := (others=>'0');
    signal s_data_pilot : std_logic_vector(23 downto 0) := (others=>'0');
    signal s_pilot_ready : std_logic;
	
	signal pilot_rx : complex12;
	signal pilot_tx_signed : std_logic;
	
	signal pilot_rx_teo : complex12 := (re => (others=>'0'), im => (others=>'0'));
	signal pilot_tx_signed_teo : std_logic := '0';
	


begin
 
    -- instantiate the unit under test (uut)
    uut_bloque_8 : bloque_8 
        port map (
            clk => s_clk,
            rst => s_rst,
            addr_symb => s_addr_symb,
            data_symb => s_data_symb,
            symb_ready => s_symb_ready,
            addr_pilot => s_addr_pilot,
            data_pilot => s_data_pilot,
            pilot_ready => s_pilot_ready,
			pilot_tx_signed => pilot_tx_signed,
			pilot_rx => pilot_rx
			);
            
     uut_genera_symb : bloque_genera_symbOFDM 
        port map (
            clk => s_clk,
            rst => s_rst,
            addr_symb => s_addr_symb,
            data_symb => s_data_symb,
            symb_ready => s_symb_ready 
            );
            
     uut_genera_pilots : bloque_genera_pilots 
        port map (
            clk => s_clk,
            rst => s_rst,
            addr_pilots => s_addr_pilot,
            data_pilots => s_data_pilot,
            pilots_ready => s_pilot_ready 
            );            

	-- stimulus process
	stim_proc: process
	begin		
		-- hold reset state for 100 ns.
		wait for 34140 ns;	
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"fde";     -- d"-2.125000" b"111111011110"
		pilot_rx_teo.im <= x"008";     -- d"0.500000" b"000000001000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"018";     -- d"1.500000" b"000000011000"
		pilot_rx_teo.im <= x"feb";     -- d"-1.312500" b"111111101011"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"00f";     -- d"0.937500" b"000000001111"
		pilot_rx_teo.im <= x"ff0";     -- d"-1.000000" b"111111110000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"016";     -- d"1.375000" b"000000010110"
		pilot_rx_teo.im <= x"fee";     -- d"-1.125000" b"111111101110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"fea";     -- d"-1.375000" b"111111101010"
		pilot_rx_teo.im <= x"023";     -- d"2.187500" b"000000100011"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"007";     -- d"0.437500" b"000000000111"
		pilot_rx_teo.im <= x"fd3";     -- d"-2.812500" b"111111010011"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ff3";     -- d"-0.812500" b"111111110011"
		pilot_rx_teo.im <= x"fd9";     -- d"-2.437500" b"111111011001"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"018";     -- d"1.500000" b"000000011000"
		pilot_rx_teo.im <= x"01e";     -- d"1.875000" b"000000011110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"01c";     -- d"1.750000" b"000000011100"
		pilot_rx_teo.im <= x"013";     -- d"1.187500" b"000000010011"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"01c";     -- d"1.750000" b"000000011100"
		pilot_rx_teo.im <= x"003";     -- d"0.187500" b"000000000011"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"fee";     -- d"-1.125000" b"111111101110"
		pilot_rx_teo.im <= x"000";     -- d"0.000000" b"000000000000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ff0";     -- d"-1.000000" b"111111110000"
		pilot_rx_teo.im <= x"ffe";     -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"018";     -- d"1.500000" b"000000011000"
		pilot_rx_teo.im <= x"ffe";     -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ff1";     -- d"-0.937500" b"111111110001"
		pilot_rx_teo.im <= x"011";     -- d"1.062500" b"000000010001"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"fff";     -- d"-0.062500" b"111111111111"
		pilot_rx_teo.im <= x"ff0";     -- d"-1.000000" b"111111110000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ffa";     -- d"-0.375000" b"111111111010"
		pilot_rx_teo.im <= x"ffb";     -- d"-0.312500" b"111111111011"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"000";     -- d"0.000000" b"000000000000"
		pilot_rx_teo.im <= x"002";     -- d"0.125000" b"000000000010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ff9";     -- d"-0.437500" b"111111111001"
		pilot_rx_teo.im <= x"ffd";     -- d"-0.187500" b"111111111101"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ff0";     -- d"-1.000000" b"111111110000"
		pilot_rx_teo.im <= x"004";     -- d"0.250000" b"000000000100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"fef";     -- d"-1.062500" b"111111101111"
		pilot_rx_teo.im <= x"018";     -- d"1.500000" b"000000011000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"004";     -- d"0.250000" b"000000000100"
		pilot_rx_teo.im <= x"024";     -- d"2.250000" b"000000100100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"020";     -- d"2.000000" b"000000100000"
		pilot_rx_teo.im <= x"014";     -- d"1.250000" b"000000010100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"fe4";     -- d"-1.750000" b"111111100100"
		pilot_rx_teo.im <= x"001";     -- d"0.062500" b"000000000001"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"010";     -- d"1.000000" b"000000010000"
		pilot_rx_teo.im <= x"ff7";     -- d"-0.562500" b"111111110111"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ff8";     -- d"-0.500000" b"111111111000"
		pilot_rx_teo.im <= x"009";     -- d"0.562500" b"000000001001"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ffe";     -- d"-0.125000" b"111111111110"
		pilot_rx_teo.im <= x"002";     -- d"0.125000" b"000000000010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ffb";     -- d"-0.312500" b"111111111011"
		pilot_rx_teo.im <= x"ff9";     -- d"-0.437500" b"111111111001"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"015";     -- d"1.312500" b"000000010101"
		pilot_rx_teo.im <= x"005";     -- d"0.312500" b"000000000101"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"015";     -- d"1.312500" b"000000010101"
		pilot_rx_teo.im <= x"ff2";     -- d"-0.875000" b"111111110010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ff8";     -- d"-0.500000" b"111111111000"
		pilot_rx_teo.im <= x"012";     -- d"1.125000" b"000000010010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"001";     -- d"0.062500" b"000000000001"
		pilot_rx_teo.im <= x"008";     -- d"0.500000" b"000000001000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"006";     -- d"0.375000" b"000000000110"
		pilot_rx_teo.im <= x"000";     -- d"0.000000" b"000000000000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"00c";     -- d"0.750000" b"000000001100"
		pilot_rx_teo.im <= x"ffd";     -- d"-0.187500" b"111111111101"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"fef";     -- d"-1.062500" b"111111101111"
		pilot_rx_teo.im <= x"008";     -- d"0.500000" b"000000001000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ff0";     -- d"-1.000000" b"111111110000"
		pilot_rx_teo.im <= x"010";     -- d"1.000000" b"000000010000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ffa";     -- d"-0.375000" b"111111111010"
		pilot_rx_teo.im <= x"01a";     -- d"1.625000" b"000000011010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"00c";     -- d"0.750000" b"000000001100"
		pilot_rx_teo.im <= x"012";     -- d"1.125000" b"000000010010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ff2";     -- d"-0.875000" b"111111110010"
		pilot_rx_teo.im <= x"fff";     -- d"-0.062500" b"111111111111"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"002";     -- d"0.125000" b"000000000010"
		pilot_rx_teo.im <= x"006";     -- d"0.375000" b"000000000110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ff8";     -- d"-0.500000" b"111111111000"
		pilot_rx_teo.im <= x"000";     -- d"0.000000" b"000000000000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"00b";     -- d"0.687500" b"000000001011"
		pilot_rx_teo.im <= x"ffd";     -- d"-0.187500" b"111111111101"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"011";     -- d"1.062500" b"000000010001"
		pilot_rx_teo.im <= x"ffa";     -- d"-0.375000" b"111111111010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"fed";     -- d"-1.187500" b"111111101101"
		pilot_rx_teo.im <= x"012";     -- d"1.125000" b"000000010010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ff9";     -- d"-0.437500" b"111111111001"
		pilot_rx_teo.im <= x"018";     -- d"1.500000" b"000000011000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"003";     -- d"0.187500" b"000000000011"
		pilot_rx_teo.im <= x"fe8";     -- d"-1.500000" b"111111101000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ffd";     -- d"-0.187500" b"111111111101"
		pilot_rx_teo.im <= x"fe2";     -- d"-1.875000" b"111111100010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"fee";     -- d"-1.125000" b"111111101110"
		pilot_rx_teo.im <= x"fe4";     -- d"-1.750000" b"111111100100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"019";     -- d"1.562500" b"000000011001"
		pilot_rx_teo.im <= x"00a";     -- d"0.625000" b"000000001010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ff2";     -- d"-0.875000" b"111111110010"
		pilot_rx_teo.im <= x"002";     -- d"0.125000" b"000000000010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"004";     -- d"0.250000" b"000000000100"
		pilot_rx_teo.im <= x"002";     -- d"0.125000" b"000000000010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ffc";     -- d"-0.250000" b"111111111100"
		pilot_rx_teo.im <= x"ffa";     -- d"-0.375000" b"111111111010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"002";     -- d"0.125000" b"000000000010"
		pilot_rx_teo.im <= x"006";     -- d"0.375000" b"000000000110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ffc";     -- d"-0.250000" b"111111111100"
		pilot_rx_teo.im <= x"ff5";     -- d"-0.687500" b"111111110101"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ff5";     -- d"-0.687500" b"111111110101"
		pilot_rx_teo.im <= x"ff7";     -- d"-0.562500" b"111111110111"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ff8";     -- d"-0.500000" b"111111111000"
		pilot_rx_teo.im <= x"000";     -- d"0.000000" b"000000000000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ffd";     -- d"-0.187500" b"111111111101"
		pilot_rx_teo.im <= x"003";     -- d"0.187500" b"000000000011"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"fff";     -- d"-0.062500" b"111111111111"
		pilot_rx_teo.im <= x"010";     -- d"1.000000" b"000000010000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"00e";     -- d"0.875000" b"000000001110"
		pilot_rx_teo.im <= x"00e";     -- d"0.875000" b"000000001110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"011";     -- d"1.062500" b"000000010001"
		pilot_rx_teo.im <= x"005";     -- d"0.312500" b"000000000101"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"00e";     -- d"0.875000" b"000000001110"
		pilot_rx_teo.im <= x"000";     -- d"0.000000" b"000000000000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"009";     -- d"0.562500" b"000000001001"
		pilot_rx_teo.im <= x"ffb";     -- d"-0.312500" b"111111111011"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"002";     -- d"0.125000" b"000000000010"
		pilot_rx_teo.im <= x"006";     -- d"0.375000" b"000000000110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ff6";     -- d"-0.625000" b"111111110110"
		pilot_rx_teo.im <= x"008";     -- d"0.500000" b"000000001000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ffa";     -- d"-0.375000" b"111111111010"
		pilot_rx_teo.im <= x"fe8";     -- d"-1.500000" b"111111101000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"fe6";     -- d"-1.625000" b"111111100110"
		pilot_rx_teo.im <= x"fef";     -- d"-1.062500" b"111111101111"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"01d";     -- d"1.812500" b"000000011101"
		pilot_rx_teo.im <= x"ffd";     -- d"-0.187500" b"111111111101"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"016";     -- d"1.375000" b"000000010110"
		pilot_rx_teo.im <= x"ff3";     -- d"-0.812500" b"111111110011"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ff5";     -- d"-0.687500" b"111111110101"
		pilot_rx_teo.im <= x"013";     -- d"1.187500" b"000000010011"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"004";     -- d"0.250000" b"000000000100"
		pilot_rx_teo.im <= x"014";     -- d"1.250000" b"000000010100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ff3";     -- d"-0.812500" b"111111110011"
		pilot_rx_teo.im <= x"ff8";     -- d"-0.500000" b"111111111000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ff8";     -- d"-0.500000" b"111111111000"
		pilot_rx_teo.im <= x"004";     -- d"0.250000" b"000000000100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"000";     -- d"0.000000" b"000000000000"
		pilot_rx_teo.im <= x"001";     -- d"0.062500" b"000000000001"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"004";     -- d"0.250000" b"000000000100"
		pilot_rx_teo.im <= x"003";     -- d"0.187500" b"000000000011"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"007";     -- d"0.437500" b"000000000111"
		pilot_rx_teo.im <= x"ffd";     -- d"-0.187500" b"111111111101"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"002";     -- d"0.125000" b"000000000010"
		pilot_rx_teo.im <= x"ffb";     -- d"-0.312500" b"111111111011"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"002";     -- d"0.125000" b"000000000010"
		pilot_rx_teo.im <= x"ffe";     -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"003";     -- d"0.187500" b"000000000011"
		pilot_rx_teo.im <= x"ffb";     -- d"-0.312500" b"111111111011"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ffc";     -- d"-0.250000" b"111111111100"
		pilot_rx_teo.im <= x"ffb";     -- d"-0.312500" b"111111111011"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"003";     -- d"0.187500" b"000000000011"
		pilot_rx_teo.im <= x"ffa";     -- d"-0.375000" b"111111111010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ff5";     -- d"-0.687500" b"111111110101"
		pilot_rx_teo.im <= x"ff9";     -- d"-0.437500" b"111111111001"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"011";     -- d"1.062500" b"000000010001"
		pilot_rx_teo.im <= x"ffc";     -- d"-0.250000" b"111111111100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"00f";     -- d"0.937500" b"000000001111"
		pilot_rx_teo.im <= x"ff4";     -- d"-0.750000" b"111111110100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"00e";     -- d"0.875000" b"000000001110"
		pilot_rx_teo.im <= x"fed";     -- d"-1.187500" b"111111101101"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"008";     -- d"0.500000" b"000000001000"
		pilot_rx_teo.im <= x"fe6";     -- d"-1.625000" b"111111100110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"009";     -- d"0.562500" b"000000001001"
		pilot_rx_teo.im <= x"020";     -- d"2.000000" b"000000100000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"00f";     -- d"0.937500" b"000000001111"
		pilot_rx_teo.im <= x"012";     -- d"1.125000" b"000000010010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ff3";     -- d"-0.812500" b"111111110011"
		pilot_rx_teo.im <= x"ff4";     -- d"-0.750000" b"111111110100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ff3";     -- d"-0.812500" b"111111110011"
		pilot_rx_teo.im <= x"ff3";     -- d"-0.812500" b"111111110011"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ff2";     -- d"-0.875000" b"111111110010"
		pilot_rx_teo.im <= x"ffb";     -- d"-0.312500" b"111111111011"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"006";     -- d"0.375000" b"000000000110"
		pilot_rx_teo.im <= x"004";     -- d"0.250000" b"000000000100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ffd";     -- d"-0.187500" b"111111111101"
		pilot_rx_teo.im <= x"ff2";     -- d"-0.875000" b"111111110010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"00e";     -- d"0.875000" b"000000001110"
		pilot_rx_teo.im <= x"016";     -- d"1.375000" b"000000010110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"018";     -- d"1.500000" b"000000011000"
		pilot_rx_teo.im <= x"00f";     -- d"0.937500" b"000000001111"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"018";     -- d"1.500000" b"000000011000"
		pilot_rx_teo.im <= x"00c";     -- d"0.750000" b"000000001100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"fe0";     -- d"-2.000000" b"111111100000"
		pilot_rx_teo.im <= x"ffa";     -- d"-0.375000" b"111111111010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"01d";     -- d"1.812500" b"000000011101"
		pilot_rx_teo.im <= x"ffa";     -- d"-0.375000" b"111111111010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"fef";     -- d"-1.062500" b"111111101111"
		pilot_rx_teo.im <= x"00c";     -- d"0.750000" b"000000001100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"00c";     -- d"0.750000" b"000000001100"
		pilot_rx_teo.im <= x"ffb";     -- d"-0.312500" b"111111111011"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"014";     -- d"1.250000" b"000000010100"
		pilot_rx_teo.im <= x"ffe";     -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"014";     -- d"1.250000" b"000000010100"
		pilot_rx_teo.im <= x"ff9";     -- d"-0.437500" b"111111111001"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"011";     -- d"1.062500" b"000000010001"
		pilot_rx_teo.im <= x"ff6";     -- d"-0.625000" b"111111110110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"016";     -- d"1.375000" b"000000010110"
		pilot_rx_teo.im <= x"ff5";     -- d"-0.687500" b"111111110101"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"014";     -- d"1.250000" b"000000010100"
		pilot_rx_teo.im <= x"ff0";     -- d"-1.000000" b"111111110000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"00b";     -- d"0.687500" b"000000001011"
		pilot_rx_teo.im <= x"ff1";     -- d"-0.937500" b"111111110001"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ff0";     -- d"-1.000000" b"111111110000"
		pilot_rx_teo.im <= x"00c";     -- d"0.750000" b"000000001100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"fe5";     -- d"-1.687500" b"111111100101"
		pilot_rx_teo.im <= x"015";     -- d"1.312500" b"000000010101"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"fe9";     -- d"-1.437500" b"111111101001"
		pilot_rx_teo.im <= x"027";     -- d"2.437500" b"000000100111"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"002";     -- d"0.125000" b"000000000010"
		pilot_rx_teo.im <= x"034";     -- d"3.250000" b"000000110100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"fec";     -- d"-1.250000" b"111111101100"
		pilot_rx_teo.im <= x"fd6";     -- d"-2.625000" b"111111010110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"fe2";     -- d"-1.875000" b"111111100010"
		pilot_rx_teo.im <= x"fdd";     -- d"-2.187500" b"111111011101"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"025";     -- d"2.312500" b"000000100101"
		pilot_rx_teo.im <= x"009";     -- d"0.562500" b"000000001001"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"fe4";     -- d"-1.750000" b"111111100100"
		pilot_rx_teo.im <= x"007";     -- d"0.437500" b"000000000111"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ff5";     -- d"-0.687500" b"111111110101"
		pilot_rx_teo.im <= x"004";     -- d"0.250000" b"000000000100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ff6";     -- d"-0.625000" b"111111110110"
		pilot_rx_teo.im <= x"ff6";     -- d"-0.625000" b"111111110110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"fea";     -- d"-1.375000" b"111111101010"
		pilot_rx_teo.im <= x"ff9";     -- d"-0.437500" b"111111111001"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"01a";     -- d"1.625000" b"000000011010"
		pilot_rx_teo.im <= x"fff";     -- d"-0.062500" b"111111111111"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"fe8";     -- d"-1.500000" b"111111101000"
		pilot_rx_teo.im <= x"004";     -- d"0.250000" b"000000000100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"fea";     -- d"-1.375000" b"111111101010"
		pilot_rx_teo.im <= x"00e";     -- d"0.875000" b"000000001110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"00d";     -- d"0.812500" b"000000001101"
		pilot_rx_teo.im <= x"fea";     -- d"-1.375000" b"111111101010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ff9";     -- d"-0.437500" b"111111111001"
		pilot_rx_teo.im <= x"00e";     -- d"0.875000" b"000000001110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"00c";     -- d"0.750000" b"000000001100"
		pilot_rx_teo.im <= x"ff2";     -- d"-0.875000" b"111111110010"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ff1";     -- d"-0.937500" b"111111110001"
		pilot_rx_teo.im <= x"018";     -- d"1.500000" b"000000011000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ffd";     -- d"-0.187500" b"111111111101"
		pilot_rx_teo.im <= x"fdc";     -- d"-2.250000" b"111111011100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"00d";     -- d"0.812500" b"000000001101"
		pilot_rx_teo.im <= x"019";     -- d"1.562500" b"000000011001"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"fee";     -- d"-1.125000" b"111111101110"
		pilot_rx_teo.im <= x"fee";     -- d"-1.125000" b"111111101110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"016";     -- d"1.375000" b"000000010110"
		pilot_rx_teo.im <= x"00c";     -- d"0.750000" b"000000001100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"feb";     -- d"-1.312500" b"111111101011"
		pilot_rx_teo.im <= x"ffd";     -- d"-0.187500" b"111111111101"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ff4";     -- d"-0.750000" b"111111110100"
		pilot_rx_teo.im <= x"000";     -- d"0.000000" b"000000000000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"00b";     -- d"0.687500" b"000000001011"
		pilot_rx_teo.im <= x"005";     -- d"0.312500" b"000000000101"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"015";     -- d"1.312500" b"000000010101"
		pilot_rx_teo.im <= x"005";     -- d"0.312500" b"000000000101"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"fec";     -- d"-1.250000" b"111111101100"
		pilot_rx_teo.im <= x"006";     -- d"0.375000" b"000000000110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ff4";     -- d"-0.750000" b"111111110100"
		pilot_rx_teo.im <= x"004";     -- d"0.250000" b"000000000100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"012";     -- d"1.125000" b"000000010010"
		pilot_rx_teo.im <= x"ffe";     -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"fe5";     -- d"-1.687500" b"111111100101"
		pilot_rx_teo.im <= x"00b";     -- d"0.687500" b"000000001011"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"014";     -- d"1.250000" b"000000010100"
		pilot_rx_teo.im <= x"fec";     -- d"-1.250000" b"111111101100"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"ff2";     -- d"-0.875000" b"111111110010"
		pilot_rx_teo.im <= x"021";     -- d"2.062500" b"000000100001"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ffd";     -- d"-0.187500" b"111111111101"
		pilot_rx_teo.im <= x"fd8";     -- d"-2.500000" b"111111011000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"016";     -- d"1.375000" b"000000010110"
		pilot_rx_teo.im <= x"023";     -- d"2.187500" b"000000100011"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"01e";     -- d"1.875000" b"000000011110"
		pilot_rx_teo.im <= x"00d";     -- d"0.812500" b"000000001101"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"012";     -- d"1.125000" b"000000010010"
		pilot_rx_teo.im <= x"ff8";     -- d"-0.500000" b"111111111000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '0'; 
		pilot_rx_teo.re <= x"001";     -- d"0.062500" b"000000000001"
		pilot_rx_teo.im <= x"ffd";     -- d"-0.187500" b"111111111101"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"fff";     -- d"-0.062500" b"111111111111"
		pilot_rx_teo.im <= x"ff8";     -- d"-0.500000" b"111111111000"

		wait for 10 ns;
		pilot_tx_signed_teo <= '1'; 
		pilot_rx_teo.re <= x"ff9";     -- d"-0.437500" b"111111111001"
		pilot_rx_teo.im <= x"ff6";     -- d"-0.625000" b"111111110110"
		
		wait;
	end process;
end;
