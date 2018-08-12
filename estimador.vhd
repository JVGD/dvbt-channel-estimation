library ieee;
use ieee.std_logic_1164.all;
use work.mi_paquete.all;
use ieee.numeric_std.all;

entity estimador is
end estimador;

architecture behavioral of estimador is

     -- Block for reading data from file
	 -- and clock generation
    component bloque_2
        port(
            data_b2     : out std_logic_vector(23 downto 0);    -- [Re(23,12), Im(11,0)]
            valid_b2    : out std_logic;                        -- 1 if data_in is ready
            clk_b2      : out std_logic;
            rst_b2      : out std_logic
            );
        end component;
 
    -- Block for writing the generated data
	-- into the Dual Port RAM
    component bloque_3
        port(
            data_in_b3  : in std_logic_vector(23 downto 0);    -- [Re(23,12), Im(11,0)]
            valid_in_b3 : in std_logic;                        -- 1 if data_in is ready
            clk_b3      : in std_logic;
            rst_b3      : in std_logic;
            data_out_b3 : out std_logic_vector(23 downto 0);    -- [Re(23,12), Im(11,0)]
            addr_out_b3 : out std_logic_vector(10 downto 0);    -- 11b = 2^(11) = 2408 addrs
            write_en_b3 : out std_logic;
            write_fin_b3 : out std_logic
            );
        end component;
    
    -- Dual Port RAM where OFDM Symbol (input
	-- data) is stored
    component bloque_4
		port(
			clka  : in  std_logic;
			wea   : in  std_logic_vector(0 downto 0);
			addra : in  std_logic_vector(10 downto 0);
			dina  : in  std_logic_vector(23 downto 0);
			clkb  : in  std_logic;
			addrb : in  std_logic_vector(10 downto 0);
			doutb : out  std_logic_vector(23 downto 0)
			);
		end component;
	
	-- Block implementing the PRBS
    component bloque_5
        port(
            clk   : in std_logic;	--clock
            rst : in std_logic;	    --reset
            Yout  : out std_logic;	--randomized output
            valid : out std_logic
            );        
		end component; 
 
    -- Block for generating pilots out of the results
	-- of the PRBS and storing it in DPRAM of Block 7
    component bloque_6
		port(
			clk_b6       : in std_logic;
			rst_b6       : in std_logic;
			prbs_b6      : in std_logic;
			valid_b6     : in std_logic;
			data_out_b6  : out std_logic_vector(23 downto 0);
			addr_out_b6  : out std_logic_vector(10 downto 0);
			write_en_b6  : out std_logic;
			write_fin_b6 : out std_logic
			);
		end component;
    
	-- Dual Port RAM with the pilots generated
	-- per symbol (pilots are only in positions 1:12:1705)
	component bloque_7
		port(
			clka : in  std_logic;
			wea : in  std_logic_vector(0 downto 0);
			addra : in  std_logic_vector(10 downto 0);
			dina : in  std_logic_vector(23 downto 0);
			clkb : in  std_logic;
			addrb : in  std_logic_vector(10 downto 0);
			doutb : out  std_logic_vector(23 downto 0)
			);
		end component; 
	
    -- When DPRAMs with symbols and pilots are ready
	-- bloque 8 reads it and return the pilot_rx and 
	-- pilot_tx, although from pilot_tx it only 
	-- returns if it is positive or negative since 
	-- pilots_tx can only be +4/3 or -4/3
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
	
	-- It divides pilot_rx by +/- 4/3 = +/-0.75
	-- depending on the pilot_signed (pilot_tx sign)
	-- It returns the equalized pilot pilot_eq
	component bloque_9
		port(
			pilot_signed : in std_logic;
			pilot_rx : in complex12;
			pilot_eq : out complex12
			);
		end component;
    
    -- Signals of synchronism
    signal rst : std_logic;
    signal clk : std_logic;
    
    -- Signals Block 2 to Block 3
    signal valid_b23 : std_logic;
    signal data_b23 : std_logic_vector(23 downto 0);

    -- Signals Block 3 to Block 4
    signal data_b34 : std_logic_vector(23 downto 0);
	signal addr_b34 : std_logic_vector(10 downto 0);
    signal write_en_b34 : std_logic;
    
	-- Signals Block 3 to Block 8		
	signal ready_symb_b38 : std_logic;

	-- Signals Block 4 to Block 8	
	signal data_symb_b48 : std_logic_vector(23 downto 0);
	signal addr_symb_b48 : std_logic_vector(10 downto 0);
    
    -- Signals Block 5 to Block 6	
    signal prbs_b56 : std_logic;
    signal valid_b56: std_logic;
    
    -- Signals Block 6 to Block 7	
    signal data_b67 : std_logic_vector(23 downto 0);
    signal addr_b67 : std_logic_vector(10 downto 0);
    signal write_en_b67 : std_logic;
	
	-- Signals Block 6 to Block 8
	signal ready_pilots_b68 : std_logic;
	
	-- Signals Block 7 to Block 8	
	signal data_pilots_b78 : std_logic_vector(23 downto 0);
	signal addr_pilots_b78 : std_logic_vector(10 downto 0);
	
	-- Signals Block 8 to Block 9
	signal pilot_tx_signed_b89 : std_logic;
	signal pilot_rx_b89 : complex12;
	
	-- Singal Block 8 to Block 10
	signal ready_txrx_pilots_b810 : std_logic;
	signal valid_b810 : std_logic;
	
	-- Signal Block 9 to Block 10
	signal pilot_eq_b910 : complex12;
	
	-- For test bench
	signal pilot_rx_teo : complex12 := (re => (others=>'0'), im => (others=>'0'));
	signal pilot_tx_signed_teo : std_logic := '0';

begin
	
    uut_bloque_2 : bloque_2
        port map(
            data_b2     => data_b23,
            valid_b2    => valid_b23,
            clk_b2      => clk,
            rst_b2      => rst
            );

    uut_bloque_3: bloque_3 
        port map (
            data_in_b3   => data_b23,
            valid_in_b3  => valid_b23,
            addr_out_b3  => addr_b34,
            data_out_b3  => data_b34,
            write_en_b3  => write_en_b34,
            clk_b3       => clk,
            rst_b3       => rst,
            write_fin_b3 => ready_symb_b38
            );

    uut_bloque_4 : bloque_4 
        port map (
            clka  => clk,
            wea(0) => write_en_b34,
            addra => addr_b34,
            dina  => data_b34,
            clkb  => clk,
            addrb => addr_symb_b48,
            doutb => data_symb_b48
            );
            
	uut_bloque_5 : bloque_5
        port map(
            clk   => clk,
            rst => rst,
            Yout  => prbs_b56,
            valid => valid_b56
			);       
            
	uut_bloque_6 : bloque_6 
        port map (
            clk_b6  => clk,
            rst_b6  => rst,
            prbs_b6 => prbs_b56,
            valid_b6 => valid_b56,
            data_out_b6 => data_b67,
            addr_out_b6 => addr_b67,
            write_en_b6 => write_en_b67,
            write_fin_b6 => ready_pilots_b68
            );
			
	bloque_7_DPRAM: bloque_7 
        port map (
            clka => clk,
            dina => data_b67,
            addra => addr_b67,
            wea(0) => write_en_b67,
            clkb => clk,
            addrb => addr_pilots_b78,
            doutb => data_pilots_b78
            );
 
    uut_bloque_8 : bloque_8 
        port map (
            clk => clk,
            rst => rst,
            addr_symb => addr_symb_b48,
            data_symb => data_symb_b48,
            symb_ready => ready_symb_b38,
            addr_pilot => addr_pilots_b78,
            data_pilot => data_pilots_b78,
            pilot_ready => ready_pilots_b68,
			pilot_tx_signed => pilot_tx_signed_b89,
			pilot_rx => pilot_rx_b89,
			pilot_txrx_fin => ready_txrx_pilots_b810,
			valid => valid_b810
			);
			
	uut_bloque_9 : bloque_9
		port map(
			pilot_signed => pilot_tx_signed_b89,
			pilot_rx => pilot_rx_b89,
			pilot_eq => pilot_eq_b910
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


end behavioral;

