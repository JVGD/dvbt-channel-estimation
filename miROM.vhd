library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Memoria que tarda un CLK en sacar el dato
-- memoria para el interpolador

entity miROM is
port(	
    clk : in std_logic;
	addr : in std_logic_vector(3 downto 0);
	data : out std_logic_vector(7 downto 0)
);
end miROM ;

architecture behav_miROM of miROM  is
    type ROM_16 is array (0 to 15) of std_logic_vector(7 downto 0);
        constant memoria: ROM_16 := (
           0  => x"1f",  
           1  => x"3d",  
           2  => x"4c",  
           3  => x"5b",  
           4  => x"79",  
           5  => x"88",  
           6  => x"97",  
           7  => x"b5",  
           8  => x"c4",  
           9  => x"d3",  
           10 => x"f1",  
           11 => x"00", 
           12 => x"00", 
           13 => x"00", 
           14 => x"00", 
           15 => x"00",
           others => x"00"
	);       

begin
    
    -- Proceso secuencial
    sinc: process(clk, addr)
    begin
        if (rising_edge(clk)) then
            data <= memoria(to_integer(unsigned(addr)));
        end if;
    end process;
 end behav_miROM;
