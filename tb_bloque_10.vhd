library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.mi_paquete.all;


entity tb_bloque_10 is
end tb_bloque_10;

architecture behavioral of tb_bloque_10 is

    -- clkmanager component
    component clkmanager is
        generic (
            clk_period       : time      := 10 ns;  --! period of generated clock
            rst_active_value : std_logic := '0';    --! reset polarity
            rst_cycles       : integer   := 10      --! number of cycles that reset will be asserted at the beginning of the simulation
            );
        port (
            endsim : in  std_logic;  --! \c clk stops changing when endsim='1', which effectively stops the simulation
            clk    : out std_logic;  --! Generated clock
            rst    : out std_logic   --! Generated reset
            );
        end component;
		
	-- cont
	component bloque_10 is
		port(
			clk         : in std_logic;
			rst         : in std_logic; 
			pilot_eq 	: in complex12;
			pilot_eq_valid : in std_logic;
			pilot_addr  : out std_logic_vector(7 downto 0);
			pilot_data  : out std_logic_vector(23 downto 0);
			pilot_write_fin : out std_logic
			);
		end component;
		
		--signals for clk manager
		signal clk: std_logic;
		signal rst: std_logic;
		
		-- signals for counter
		signal pilot_eq : complex12;
		signal pilot_eq_valid : std_logic;
		signal pilot_addr  : std_logic_vector(7 downto 0);
		signal pilot_data  : std_logic_vector(23 downto 0);
		signal pilot_write_fin : std_logic;
		

begin

	-- Clock manager instance
    uut_clkmanager : clkmanager
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
	
	uut_bloque_10 : bloque_10
		port map(
			clk => clk,
			rst => rst,
			pilot_eq => pilot_eq,
			pilot_eq_valid => pilot_eq_valid,
			pilot_addr  => pilot_addr,
			pilot_data  => pilot_data,
			pilot_write_fin => pilot_write_fin
			);
	
	-- stimulus process
	stim_proc: process
	begin
		wait for 50 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"019"; -- d"1.562500" b"000000011001"
		pilot_eq.im <= x"ffa"; -- d"-0.375000" b"111111111010"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"012"; -- d"1.125000" b"000000010010"
		pilot_eq.im <= x"ff1"; -- d"-0.937500" b"111111110001"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"00b"; -- d"0.687500" b"000000001011"
		pilot_eq.im <= x"ff4"; -- d"-0.750000" b"111111110100"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"010"; -- d"1.000000" b"000000010000"
		pilot_eq.im <= x"ff3"; -- d"-0.812500" b"111111110011"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"010"; -- d"1.000000" b"000000010000"
		pilot_eq.im <= x"fe6"; -- d"-1.625000" b"111111100110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"006"; -- d"0.375000" b"000000000110"
		pilot_eq.im <= x"fde"; -- d"-2.125000" b"111111011110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff7"; -- d"-0.562500" b"111111110111"
		pilot_eq.im <= x"fe3"; -- d"-1.812500" b"111111100011"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"fee"; -- d"-1.125000" b"111111101110"
		pilot_eq.im <= x"fe9"; -- d"-1.437500" b"111111101001"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"feb"; -- d"-1.312500" b"111111101011"
		pilot_eq.im <= x"ff1"; -- d"-0.937500" b"111111110001"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"feb"; -- d"-1.312500" b"111111101011"
		pilot_eq.im <= x"ffe"; -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff2"; -- d"-0.875000" b"111111110010"
		pilot_eq.im <= x"000"; -- d"0.000000" b"000000000000"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff4"; -- d"-0.750000" b"111111110100"
		pilot_eq.im <= x"ffe"; -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"fee"; -- d"-1.125000" b"111111101110"
		pilot_eq.im <= x"002"; -- d"0.125000" b"000000000010"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff5"; -- d"-0.687500" b"111111110101"
		pilot_eq.im <= x"00d"; -- d"0.812500" b"000000001101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"001"; -- d"0.062500" b"000000000001"
		pilot_eq.im <= x"00c"; -- d"0.750000" b"000000001100"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"004"; -- d"0.250000" b"000000000100"
		pilot_eq.im <= x"004"; -- d"0.250000" b"000000000100"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"000"; -- d"0.000000" b"000000000000"
		pilot_eq.im <= x"fff"; -- d"-0.062500" b"111111111111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ffb"; -- d"-0.312500" b"111111111011"
		pilot_eq.im <= x"ffe"; -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff4"; -- d"-0.750000" b"111111110100"
		pilot_eq.im <= x"003"; -- d"0.187500" b"000000000011"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff4"; -- d"-0.750000" b"111111110100"
		pilot_eq.im <= x"012"; -- d"1.125000" b"000000010010"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"003"; -- d"0.187500" b"000000000011"
		pilot_eq.im <= x"01b"; -- d"1.687500" b"000000011011"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"018"; -- d"1.500000" b"000000011000"
		pilot_eq.im <= x"00f"; -- d"0.937500" b"000000001111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"015"; -- d"1.312500" b"000000010101"
		pilot_eq.im <= x"fff"; -- d"-0.062500" b"111111111111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"00c"; -- d"0.750000" b"000000001100"
		pilot_eq.im <= x"ff9"; -- d"-0.437500" b"111111111001"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"006"; -- d"0.375000" b"000000000110"
		pilot_eq.im <= x"ff9"; -- d"-0.437500" b"111111111001"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"002"; -- d"0.125000" b"000000000010"
		pilot_eq.im <= x"fff"; -- d"-0.062500" b"111111111111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"004"; -- d"0.250000" b"000000000100"
		pilot_eq.im <= x"006"; -- d"0.375000" b"000000000110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"010"; -- d"1.000000" b"000000010000"
		pilot_eq.im <= x"004"; -- d"0.250000" b"000000000100"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"010"; -- d"1.000000" b"000000010000"
		pilot_eq.im <= x"ff6"; -- d"-0.625000" b"111111110110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"006"; -- d"0.375000" b"000000000110"
		pilot_eq.im <= x"ff3"; -- d"-0.812500" b"111111110011"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"fff"; -- d"-0.062500" b"111111111111"
		pilot_eq.im <= x"ffa"; -- d"-0.375000" b"111111111010"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"004"; -- d"0.250000" b"000000000100"
		pilot_eq.im <= x"000"; -- d"0.000000" b"000000000000"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"009"; -- d"0.562500" b"000000001001"
		pilot_eq.im <= x"ffe"; -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"00d"; -- d"0.812500" b"000000001101"
		pilot_eq.im <= x"ffa"; -- d"-0.375000" b"111111111010"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"00c"; -- d"0.750000" b"000000001100"
		pilot_eq.im <= x"ff4"; -- d"-0.750000" b"111111110100"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"004"; -- d"0.250000" b"000000000100"
		pilot_eq.im <= x"fed"; -- d"-1.187500" b"111111101101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff7"; -- d"-0.562500" b"111111110111"
		pilot_eq.im <= x"ff2"; -- d"-0.875000" b"111111110010"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff6"; -- d"-0.625000" b"111111110110"
		pilot_eq.im <= x"000"; -- d"0.000000" b"000000000000"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"001"; -- d"0.062500" b"000000000001"
		pilot_eq.im <= x"004"; -- d"0.250000" b"000000000100"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"006"; -- d"0.375000" b"000000000110"
		pilot_eq.im <= x"000"; -- d"0.000000" b"000000000000"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"008"; -- d"0.500000" b"000000001000"
		pilot_eq.im <= x"ffe"; -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"00d"; -- d"0.812500" b"000000001101"
		pilot_eq.im <= x"ffb"; -- d"-0.312500" b"111111111011"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"00e"; -- d"0.875000" b"000000001110"
		pilot_eq.im <= x"ff2"; -- d"-0.875000" b"111111110010"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"005"; -- d"0.312500" b"000000000101"
		pilot_eq.im <= x"fee"; -- d"-1.125000" b"111111101110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"002"; -- d"0.125000" b"000000000010"
		pilot_eq.im <= x"fee"; -- d"-1.125000" b"111111101110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ffe"; -- d"-0.125000" b"111111111110"
		pilot_eq.im <= x"fea"; -- d"-1.375000" b"111111101010"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff2"; -- d"-0.875000" b"111111110010"
		pilot_eq.im <= x"feb"; -- d"-1.312500" b"111111101011"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"fed"; -- d"-1.187500" b"111111101101"
		pilot_eq.im <= x"ff8"; -- d"-0.500000" b"111111111000"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff5"; -- d"-0.687500" b"111111110101"
		pilot_eq.im <= x"001"; -- d"0.062500" b"000000000001"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ffd"; -- d"-0.187500" b"111111111101"
		pilot_eq.im <= x"ffe"; -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ffd"; -- d"-0.187500" b"111111111101"
		pilot_eq.im <= x"ffb"; -- d"-0.312500" b"111111111011"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ffe"; -- d"-0.125000" b"111111111110"
		pilot_eq.im <= x"ffb"; -- d"-0.312500" b"111111111011"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ffd"; -- d"-0.187500" b"111111111101"
		pilot_eq.im <= x"ff7"; -- d"-0.562500" b"111111110111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff8"; -- d"-0.500000" b"111111111000"
		pilot_eq.im <= x"ff9"; -- d"-0.437500" b"111111111001"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ffa"; -- d"-0.375000" b"111111111010"
		pilot_eq.im <= x"000"; -- d"0.000000" b"000000000000"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"002"; -- d"0.125000" b"000000000010"
		pilot_eq.im <= x"ffe"; -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"001"; -- d"0.062500" b"000000000001"
		pilot_eq.im <= x"ff4"; -- d"-0.750000" b"111111110100"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff6"; -- d"-0.625000" b"111111110110"
		pilot_eq.im <= x"ff5"; -- d"-0.687500" b"111111110101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff3"; -- d"-0.812500" b"111111110011"
		pilot_eq.im <= x"ffc"; -- d"-0.250000" b"111111111100"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff6"; -- d"-0.625000" b"111111110110"
		pilot_eq.im <= x"000"; -- d"0.000000" b"000000000000"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff9"; -- d"-0.437500" b"111111111001"
		pilot_eq.im <= x"003"; -- d"0.187500" b"000000000011"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"002"; -- d"0.125000" b"000000000010"
		pilot_eq.im <= x"004"; -- d"0.250000" b"000000000100"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"007"; -- d"0.437500" b"000000000111"
		pilot_eq.im <= x"ffa"; -- d"-0.375000" b"111111111010"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ffc"; -- d"-0.250000" b"111111111100"
		pilot_eq.im <= x"fee"; -- d"-1.125000" b"111111101110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"fed"; -- d"-1.187500" b"111111101101"
		pilot_eq.im <= x"ff3"; -- d"-0.812500" b"111111110011"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"feb"; -- d"-1.312500" b"111111101011"
		pilot_eq.im <= x"002"; -- d"0.125000" b"000000000010"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff0"; -- d"-1.000000" b"111111110000"
		pilot_eq.im <= x"009"; -- d"0.562500" b"000000001001"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff8"; -- d"-0.500000" b"111111111000"
		pilot_eq.im <= x"00f"; -- d"0.937500" b"000000001111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"003"; -- d"0.187500" b"000000000011"
		pilot_eq.im <= x"00f"; -- d"0.937500" b"000000001111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"00a"; -- d"0.625000" b"000000001010"
		pilot_eq.im <= x"006"; -- d"0.375000" b"000000000110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"006"; -- d"0.375000" b"000000000110"
		pilot_eq.im <= x"ffd"; -- d"-0.187500" b"111111111101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"000"; -- d"0.000000" b"000000000000"
		pilot_eq.im <= x"fff"; -- d"-0.062500" b"111111111111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"003"; -- d"0.187500" b"000000000011"
		pilot_eq.im <= x"002"; -- d"0.125000" b"000000000010"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"005"; -- d"0.312500" b"000000000101"
		pilot_eq.im <= x"ffe"; -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"001"; -- d"0.062500" b"000000000001"
		pilot_eq.im <= x"ffc"; -- d"-0.250000" b"111111111100"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"002"; -- d"0.125000" b"000000000010"
		pilot_eq.im <= x"ffe"; -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"002"; -- d"0.125000" b"000000000010"
		pilot_eq.im <= x"ffc"; -- d"-0.250000" b"111111111100"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ffd"; -- d"-0.187500" b"111111111101"
		pilot_eq.im <= x"ffc"; -- d"-0.250000" b"111111111100"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ffe"; -- d"-0.125000" b"111111111110"
		pilot_eq.im <= x"004"; -- d"0.250000" b"000000000100"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"008"; -- d"0.500000" b"000000001000"
		pilot_eq.im <= x"005"; -- d"0.312500" b"000000000101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"00d"; -- d"0.812500" b"000000001101"
		pilot_eq.im <= x"ffd"; -- d"-0.187500" b"111111111101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"00b"; -- d"0.687500" b"000000001011"
		pilot_eq.im <= x"ff7"; -- d"-0.562500" b"111111110111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"00a"; -- d"0.625000" b"000000001010"
		pilot_eq.im <= x"ff2"; -- d"-0.875000" b"111111110010"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"006"; -- d"0.375000" b"000000000110"
		pilot_eq.im <= x"fed"; -- d"-1.187500" b"111111101101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff9"; -- d"-0.437500" b"111111111001"
		pilot_eq.im <= x"fe8"; -- d"-1.500000" b"111111101000"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff5"; -- d"-0.687500" b"111111110101"
		pilot_eq.im <= x"ff3"; -- d"-0.812500" b"111111110011"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff7"; -- d"-0.562500" b"111111110111"
		pilot_eq.im <= x"ff7"; -- d"-0.562500" b"111111110111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff6"; -- d"-0.625000" b"111111110110"
		pilot_eq.im <= x"ff7"; -- d"-0.562500" b"111111110111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff5"; -- d"-0.687500" b"111111110101"
		pilot_eq.im <= x"ffc"; -- d"-0.250000" b"111111111100"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ffb"; -- d"-0.312500" b"111111111011"
		pilot_eq.im <= x"ffd"; -- d"-0.187500" b"111111111101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ffe"; -- d"-0.125000" b"111111111110"
		pilot_eq.im <= x"ff5"; -- d"-0.687500" b"111111110101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff6"; -- d"-0.625000" b"111111110110"
		pilot_eq.im <= x"fef"; -- d"-1.062500" b"111111101111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"fee"; -- d"-1.125000" b"111111101110"
		pilot_eq.im <= x"ff5"; -- d"-0.687500" b"111111110101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"fee"; -- d"-1.125000" b"111111101110"
		pilot_eq.im <= x"ff7"; -- d"-0.562500" b"111111110111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"fe8"; -- d"-1.500000" b"111111101000"
		pilot_eq.im <= x"ffc"; -- d"-0.250000" b"111111111100"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"fea"; -- d"-1.375000" b"111111101010"
		pilot_eq.im <= x"005"; -- d"0.312500" b"000000000101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff3"; -- d"-0.812500" b"111111110011"
		pilot_eq.im <= x"009"; -- d"0.562500" b"000000001001"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff7"; -- d"-0.562500" b"111111110111"
		pilot_eq.im <= x"004"; -- d"0.250000" b"000000000100"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff1"; -- d"-0.937500" b"111111110001"
		pilot_eq.im <= x"002"; -- d"0.125000" b"000000000010"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff1"; -- d"-0.937500" b"111111110001"
		pilot_eq.im <= x"006"; -- d"0.375000" b"000000000110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff3"; -- d"-0.812500" b"111111110011"
		pilot_eq.im <= x"008"; -- d"0.500000" b"000000001000"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff0"; -- d"-1.000000" b"111111110000"
		pilot_eq.im <= x"008"; -- d"0.500000" b"000000001000"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff1"; -- d"-0.937500" b"111111110001"
		pilot_eq.im <= x"00c"; -- d"0.750000" b"000000001100"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff8"; -- d"-0.500000" b"111111111000"
		pilot_eq.im <= x"00b"; -- d"0.687500" b"000000001011"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff4"; -- d"-0.750000" b"111111110100"
		pilot_eq.im <= x"009"; -- d"0.562500" b"000000001001"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"fec"; -- d"-1.250000" b"111111101100"
		pilot_eq.im <= x"010"; -- d"1.000000" b"000000010000"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"fef"; -- d"-1.062500" b"111111101111"
		pilot_eq.im <= x"01d"; -- d"1.812500" b"000000011101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"002"; -- d"0.125000" b"000000000010"
		pilot_eq.im <= x"027"; -- d"2.437500" b"000000100111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"00f"; -- d"0.937500" b"000000001111"
		pilot_eq.im <= x"01f"; -- d"1.937500" b"000000011111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"017"; -- d"1.437500" b"000000010111"
		pilot_eq.im <= x"01a"; -- d"1.625000" b"000000011010"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"01b"; -- d"1.687500" b"000000011011"
		pilot_eq.im <= x"006"; -- d"0.375000" b"000000000110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"015"; -- d"1.312500" b"000000010101"
		pilot_eq.im <= x"ffb"; -- d"-0.312500" b"111111111011"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"008"; -- d"0.500000" b"000000001000"
		pilot_eq.im <= x"ffd"; -- d"-0.187500" b"111111111101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"008"; -- d"0.500000" b"000000001000"
		pilot_eq.im <= x"007"; -- d"0.437500" b"000000000111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"010"; -- d"1.000000" b"000000010000"
		pilot_eq.im <= x"005"; -- d"0.312500" b"000000000101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"013"; -- d"1.187500" b"000000010011"
		pilot_eq.im <= x"fff"; -- d"-0.062500" b"111111111111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"012"; -- d"1.125000" b"000000010010"
		pilot_eq.im <= x"ffd"; -- d"-0.187500" b"111111111101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"011"; -- d"1.062500" b"000000010001"
		pilot_eq.im <= x"ff5"; -- d"-0.687500" b"111111110101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"00a"; -- d"0.625000" b"000000001010"
		pilot_eq.im <= x"fef"; -- d"-1.062500" b"111111101111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"005"; -- d"0.312500" b"000000000101"
		pilot_eq.im <= x"ff5"; -- d"-0.687500" b"111111110101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"009"; -- d"0.562500" b"000000001001"
		pilot_eq.im <= x"ff6"; -- d"-0.625000" b"111111110110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"00b"; -- d"0.687500" b"000000001011"
		pilot_eq.im <= x"fee"; -- d"-1.125000" b"111111101110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ffe"; -- d"-0.125000" b"111111111110"
		pilot_eq.im <= x"fe5"; -- d"-1.687500" b"111111100101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff6"; -- d"-0.625000" b"111111110110"
		pilot_eq.im <= x"fed"; -- d"-1.187500" b"111111101101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff2"; -- d"-0.875000" b"111111110010"
		pilot_eq.im <= x"ff3"; -- d"-0.812500" b"111111110011"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff0"; -- d"-1.000000" b"111111110000"
		pilot_eq.im <= x"ff7"; -- d"-0.562500" b"111111110111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff0"; -- d"-1.000000" b"111111110000"
		pilot_eq.im <= x"ffe"; -- d"-0.125000" b"111111111110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff7"; -- d"-0.562500" b"111111110111"
		pilot_eq.im <= x"000"; -- d"0.000000" b"000000000000"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff8"; -- d"-0.500000" b"111111111000"
		pilot_eq.im <= x"ffc"; -- d"-0.250000" b"111111111100"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff0"; -- d"-1.000000" b"111111110000"
		pilot_eq.im <= x"ffc"; -- d"-0.250000" b"111111111100"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff1"; -- d"-0.937500" b"111111110001"
		pilot_eq.im <= x"005"; -- d"0.312500" b"000000000101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff7"; -- d"-0.562500" b"111111110111"
		pilot_eq.im <= x"003"; -- d"0.187500" b"000000000011"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff3"; -- d"-0.812500" b"111111110011"
		pilot_eq.im <= x"002"; -- d"0.125000" b"000000000010"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"fec"; -- d"-1.250000" b"111111101100"
		pilot_eq.im <= x"008"; -- d"0.500000" b"000000001000"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff1"; -- d"-0.937500" b"111111110001"
		pilot_eq.im <= x"00f"; -- d"0.937500" b"000000001111"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"ff6"; -- d"-0.625000" b"111111110110"
		pilot_eq.im <= x"019"; -- d"1.562500" b"000000011001"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"002"; -- d"0.125000" b"000000000010"
		pilot_eq.im <= x"01e"; -- d"1.875000" b"000000011110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"011"; -- d"1.062500" b"000000010001"
		pilot_eq.im <= x"01a"; -- d"1.625000" b"000000011010"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"017"; -- d"1.437500" b"000000010111"
		pilot_eq.im <= x"00a"; -- d"0.625000" b"000000001010"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"00e"; -- d"0.875000" b"000000001110"
		pilot_eq.im <= x"ffa"; -- d"-0.375000" b"111111111010"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"001"; -- d"0.062500" b"000000000001"
		pilot_eq.im <= x"ffd"; -- d"-0.187500" b"111111111101"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"001"; -- d"0.062500" b"000000000001"
		pilot_eq.im <= x"006"; -- d"0.375000" b"000000000110"

		wait for 10 ns;
		pilot_eq_valid <= '1'; 
		pilot_eq.re <= x"005"; -- d"0.312500" b"000000000101"
		pilot_eq.im <= x"008"; -- d"0.500000" b"000000001000"
		wait;
	end process;
	
end behavioral;