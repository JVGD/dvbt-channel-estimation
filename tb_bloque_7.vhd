library ieee;
use ieee.std_logic_1164.all;
 
-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;
 
entity tb_bloque_7 is
end tb_bloque_7;
 
architecture behavior of tb_bloque_7 is 
 
    -- component declaration for the unit under test (uut)
 
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
    

   --inputs
   signal clka : std_logic := '0';
   signal wea : std_logic_vector(0 downto 0) := (others => '0');
   signal addra : std_logic_vector(10 downto 0) := (others => '0');
   signal dina : std_logic_vector(23 downto 0) := (others => '0');
   signal clkb : std_logic := '0';
   signal addrb : std_logic_vector(10 downto 0) := (others => '0');

 	--outputs
   signal doutb : std_logic_vector(23 downto 0);

   -- clock period definitions
   constant clka_period : time := 10 ns;
   constant clkb_period : time := 10 ns;
 
begin
 
	-- instantiate the unit under test (uut)
   uut: bloque_7 port map (
          clka => clka,
          wea => wea,
          addra => addra,
          dina => dina,
          clkb => clkb,
          addrb => addrb,
          doutb => doutb
        );

   -- clock process definitions
   clka_process :process
   begin
		clka <= '0';
		wait for clka_period/2;
		clka <= '1';
		wait for clka_period/2;
   end process;
 
   clkb_process :process
   begin
		clkb <= '0';
		wait for clkb_period/2;
		clkb <= '1';
		wait for clkb_period/2;
   end process;
 

   -- stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clka_period*10;

      -- insert stimulus here 

      wait;
   end process;

end;
