library ieee;
use ieee.std_logic_1164.all;

entity bloque_5 is

	port(
		clk   : in std_logic;   --clock
		rst : in std_logic;	--reset
		Yout  : out std_logic;	--randomized output
        valid : out std_logic;
		enable : in std_logic
        );
        
end bloque_5;


architecture bloque_5_1 of bloque_5 is

    signal prbs_reg : std_logic_vector(10 downto 0);
    signal p_prbs_reg : std_logic_vector(10 downto 0);
    signal s_in : std_logic;
    signal p_Yout : std_logic;
	signal sYout : std_logic; -- for datacompare
    signal p_valid : std_logic := '0';
	
begin


    -- Combinational process
    comb: process (prbs_reg, s_in, rst, enable)
    begin
		s_in <= prbs_reg(2) xor prbs_reg(0);
		if (enable = '1') then
			--Combinational process
			p_Yout <= prbs_reg(0);
			p_prbs_reg <= s_in & prbs_reg(10 downto 1);
			p_valid <= '1';
		else
			p_Yout <= '0';
			p_prbs_reg <= prbs_reg;
			p_valid <= '0';
		end if;
    end process comb;
    
	--Sequential process
	sequential : process(rst, prbs_reg, clk, s_in)
	begin
		if (rst = '1') then
			prbs_reg <= "11111111111";
			Yout <= '0';
			sYout <= '0';
			valid <= '0';
		elsif rising_edge(clk) then
			prbs_reg <= p_prbs_reg;
            Yout <= p_Yout;
			sYout <= p_Yout;
            valid <= p_valid;
            
		end if;
        
	end process sequential;
	

	
end bloque_5_1;
