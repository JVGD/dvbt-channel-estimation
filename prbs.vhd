library ieee;
use ieee.std_logic_1164.all;

entity prbs is

	port(
		clk   : in std_logic;   --clock
		rst : in std_logic;	--reset
		Yout  : out std_logic;	--randomized output
        valid : out std_logic   
        );
        
end prbs;


architecture prbs_1 of prbs is

    signal prbs_reg : std_logic_vector(10 downto 0) := "11111111111";
    signal p_prbs_reg : std_logic_vector(10 downto 0):= "11111111111";
    signal s_in : std_logic;
    signal p_Yout : std_logic;
    signal p_valid : std_logic := '0';
begin
    
    -- Combinational process
    comb: process (prbs_reg, s_in, rst)
    begin
        if (rst = '0') then
            --Combinational process
            s_in <= prbs_reg(2) xor prbs_reg(0);
            p_Yout <= prbs_reg(0);
            p_prbs_reg <= s_in & prbs_reg(10 downto 1);
            p_valid <= '1';
        end if;
    end process comb;
    
	--Sequential process
	sequential : process(rst, prbs_reg, clk, s_in)
	begin
		if ((rst = '0') and rising_edge(clk)) then
			prbs_reg <= p_prbs_reg;
            Yout <= p_Yout;
            valid <= p_valid;
            
		end if;
        
	end process sequential;
	

	
end prbs_1;
