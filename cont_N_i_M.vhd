library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity cont_N_i_M is
	generic( 
		N : integer := 0; -- counter init number
		i : integer := 1; -- counter step count
		M : integer := 10 -- counter end number
		);
    port(
        clk : in std_logic;
        rst : in std_logic;
        enable: in std_logic;
        counter : out std_logic_vector(natural(ceil(log2(real(M+1))))-1 downto 0);
        cont_ended : out std_logic
        );

end cont_N_i_M;

architecture behavioral of cont_N_i_M is
    
    signal cont : std_logic_vector(natural(ceil(log2(real(M+1))))-1 downto 0);
    signal p_cont : std_logic_vector(natural(ceil(log2(real(M+1))))-1 downto 0);
    signal scont_ended :std_logic; -- cont_ended is not inout
	signal p_cont_ended : std_logic;
    
begin   

    comb : process(cont, rst, enable, cont)
    begin
        if (enable = '1') then
            p_cont <= std_logic_vector(unsigned(cont) + i);			
			if (unsigned(cont) = M) then
				p_cont_ended <= '1';
			end if;
		else
			p_cont <= cont;
			p_cont_ended <= scont_ended;
			p_cont_ended <= '0';
		end if;
        
    end process comb;


    sync : process(rst, clk)
    begin
        
        if (rst = '1') then
			-- Init counter to firt value given as a paramenter
			-- N i M = 10 1 30, first cont = 10
			counter <= (others=>'0');
			cont_ended <= '0';
			scont_ended <= '0';
            cont <= std_logic_vector(to_unsigned(N, cont'length));
			
        elsif (rising_edge(clk)) then
            cont <= p_cont;
            counter <= p_cont;
            cont_ended <= p_cont_ended;
			scont_ended <= p_cont_ended;
        
        end if;
    
    end process sync;

end behavioral;

