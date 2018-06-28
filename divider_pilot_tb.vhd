library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mi_paquete.all;
 
entity divider_pilot_tb is
end divider_pilot_tb;
 
architecture behavior of divider_pilot_tb is 
 
    -- component declaration for the unit under test (uut)
 
	component divider_pilot
	port(
		pilot_signed : in std_logic;
		pilot_rx : in complex12;
		pilot_eq : out complex12
	);
	end component;

	--inputs
	signal pilot_signed : std_logic := '0';
	signal pilot_rx : complex12 := (re => (others=>'0'), im => (others=>'0'));
	signal pilot_eq_teo : complex12 := (re => (others=>'0'), im => (others=>'0'));

	--outputs
	signal pilot_eq : complex12 := (re => (others=>'0'), im => (others=>'0'));

	constant clk_period : time := 10 ns;
	signal clk : std_logic := '1';
 
begin
 
	-- instantiate the unit under test (uut)
   uut: divider_pilot port map (
          pilot_signed => pilot_signed,
          pilot_rx => pilot_rx,
          pilot_eq => pilot_eq
        );

   -- clock process definitions
  clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;
 

	-- stimulus process
	stim_proc: process
	begin		
		-- hold reset state for 100 ns.
		wait for 20 ns;	

		wait for 10 ns;
		pilot_signed <= '1'; 
		pilot_rx.re <= x"012";     -- d"1.125000" b"000000010010"
		pilot_rx.im <= x"ff2";     -- d"-0.875000" b"111111110010"
		pilot_eq_teo.re <= x"ff2"; -- d"-0.875000" b"111111110010"
		pilot_eq_teo.im <= x"00a"; -- d"0.625000" b"000000001010"

		wait for 10 ns;
		pilot_signed <= '0'; 
		pilot_rx.re <= x"ffa";     -- d"-0.375000" b"111111111010"
		pilot_rx.im <= x"011";     -- d"1.062500" b"000000010001"
		pilot_eq_teo.re <= x"ffc"; -- d"-0.250000" b"111111111100"
		pilot_eq_teo.im <= x"00d"; -- d"0.812500" b"000000001101"

		wait for 10 ns;
		pilot_signed <= '0'; 
		pilot_rx.re <= x"ffc";     -- d"-0.250000" b"111111111100"
		pilot_rx.im <= x"007";     -- d"0.437500" b"000000000111"
		pilot_eq_teo.re <= x"ffd"; -- d"-0.187500" b"111111111101"
		pilot_eq_teo.im <= x"005"; -- d"0.312500" b"000000000101"

		wait for 10 ns;
		pilot_signed <= '0'; 
		pilot_rx.re <= x"ff2";     -- d"-0.875000" b"111111110010"
		pilot_rx.im <= x"00a";     -- d"0.625000" b"000000001010"
		pilot_eq_teo.re <= x"ff5"; -- d"-0.687500" b"111111110101"
		pilot_eq_teo.im <= x"007"; -- d"0.437500" b"000000000111"

		wait for 10 ns;
		pilot_signed <= '1'; 
		pilot_rx.re <= x"00c";     -- d"0.750000" b"000000001100"
		pilot_rx.im <= x"fe4";     -- d"-1.750000" b"111111100100"
		pilot_eq_teo.re <= x"ff7"; -- d"-0.562500" b"111111110111"
		pilot_eq_teo.im <= x"015"; -- d"1.312500" b"000000010101"

		wait for 10 ns;
		pilot_signed <= '0'; 
		pilot_rx.re <= x"006";     -- d"0.375000" b"000000000110"
		pilot_rx.im <= x"024";     -- d"2.250000" b"000000100100"
		pilot_eq_teo.re <= x"005"; -- d"0.312500" b"000000000101"
		pilot_eq_teo.im <= x"01b"; -- d"1.687500" b"000000011011"

		wait for 10 ns;
		pilot_signed <= '0'; 
		pilot_rx.re <= x"019";     -- d"1.562500" b"000000011001"
		pilot_rx.im <= x"017";     -- d"1.437500" b"000000010111"
		pilot_eq_teo.re <= x"013"; -- d"1.187500" b"000000010011"
		pilot_eq_teo.im <= x"011"; -- d"1.062500" b"000000010001"

		wait for 10 ns;
		pilot_signed <= '1'; 
		pilot_rx.re <= x"fde";     -- d"-2.125000" b"111111011110"
		pilot_rx.im <= x"ffc";     -- d"-0.250000" b"111111111100"
		pilot_eq_teo.re <= x"01a"; -- d"1.625000" b"000000011010"
		pilot_eq_teo.im <= x"003"; -- d"0.187500" b"000000000011"

		wait for 10 ns;
		pilot_signed <= '1'; 
		pilot_rx.re <= x"fe3";     -- d"-1.812500" b"111111100011"
		pilot_rx.im <= x"00e";     -- d"0.875000" b"000000001110"
		pilot_eq_teo.re <= x"015"; -- d"1.312500" b"000000010101"
		pilot_eq_teo.im <= x"ff5"; -- d"-0.687500" b"111111110101"

		wait for 10 ns;
		pilot_signed <= '1'; 
		pilot_rx.re <= x"ff9";     -- d"-0.437500" b"111111111001"
		pilot_rx.im <= x"01e";     -- d"1.875000" b"000000011110"
		pilot_eq_teo.re <= x"005"; -- d"0.312500" b"000000000101"
		pilot_eq_teo.im <= x"fe9"; -- d"-1.437500" b"111111101001"

		wait;
	end process;

end;
