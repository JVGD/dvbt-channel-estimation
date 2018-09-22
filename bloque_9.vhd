library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mi_paquete.all;

entity bloque_9 is
	port(
		pilot_signed : in std_logic;
		pilot_rx : in complex12;
		pilot_est : out complex12
	);
end bloque_9;

architecture behavioral of bloque_9 is
	
	-- pilot / (4/3) = pilot * 3/4 = pilot * 0.75
	constant pilot_neg : std_logic_vector(11 downto 0):= "111111110100"; -- -0.75
	constant pilot_pos : std_logic_vector(11 downto 0):= "000000001100"; --  0.75
	
	signal result : complex24 := (re => (others=>'0'), im => (others=>'0'));
	
begin
	comb: process(pilot_rx, pilot_signed)
	begin
		if(pilot_signed = '1') then -- if signed is negative pilot
			result.re <= std_logic_vector( signed(pilot_rx.re) * signed(pilot_neg) );
			result.im <= std_logic_vector( signed(pilot_rx.im) * signed(pilot_neg) );
		
		elsif(pilot_signed = '0') then -- if not siged is positive pilot
			result.re <= std_logic_vector( signed(pilot_rx.re) * signed(pilot_pos) );
			result.im <= std_logic_vector( signed(pilot_rx.im) * signed(pilot_pos) );
		
		end if;
	end process;
	
	pilot_est.re <= result.re(15 downto 4); -- taking central part only
	pilot_est.im <= result.im(15 downto 4); -- taking central part only
	
end behavioral;

