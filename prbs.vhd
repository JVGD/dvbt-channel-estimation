library ieee;
use ieee.std_logic_1164.all;

entity prbs is

	port(
		clk      : in std_logic;    --clock
		reset    : in std_logic;	--reset
		Yout     : out std_logic	--randomized output
        );
        
end prbs;


architecture prbs_1 of prbs is

    signal prbs_reg : std_logic_vector(10 downto 0);
    signal p_prbs_reg : std_logic_vector(10 downto 0);
    signal s_in : std_logic;
    signal p_Yout : std_logic;

begin
    
    -- Combinational process
    comb: process (prbs_reg, s_in)
    begin
        --Combinational process
        s_in <= prbs_reg(2) xor prbs_reg(0);
        p_Yout <= prbs_reg(0);
        p_prbs_reg <= s_in & prbs_reg(10 downto 1);
    end process comb;
    
	--Sequential process
	sequential : process(reset, prbs_reg, clk, s_in)
	begin
		if (reset='1') then
			prbs_reg <= "11111111111";
            
		elsif (rising_edge(clk)) then
			prbs_reg <= p_prbs_reg;
            Yout <= p_Yout;
            
		end if;
        
	end process sequential;
	

	
end prbs_1;
