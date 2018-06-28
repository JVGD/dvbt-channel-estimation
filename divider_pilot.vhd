library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mi_paquete.all;

entity divider_pilot is
	port(
		pilot_signed : in std_logic;
		pilot_rx : in std_logic_vector(11 downto 0);
		pilot_eq : out std_logic_vector(11 downto 0)
	);
end divider_pilot;

architecture behavioral of divider_pilot is
	
	-- pilot / (4/3) = pilot * 3/4 = pilot * 0.75
	constant pilot_neg : std_logic_vector(11 downto 0):= "111111110100"; -- -0.75
	constant pilot_pos : std_logic_vector(11 downto 0):= "000000001100"; --  0.75
	signal result : std_logic_vector(23 downto 0):= (others=>'0');
	
begin
	comb: process(pilot_rx, pilot_signed)
	begin
		if(pilot_signed = '1') then -- if signed is negative pilot
			result <= std_logic_vector( signed(pilot_rx) * signed(pilot_neg) );
		elsif(pilot_signed = '0') then -- if not siged is positive pilot
			result <= std_logic_vector( signed(pilot_rx) * signed(pilot_pos) );
		end if;
	end process;
	
	pilot_eq <= result(15 downto 4); -- taking central part only
	
end behavioral;

