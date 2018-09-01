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
    signal p_cont_ended : std_logic := '0';
    signal s_cont_ended : std_logic := '0';
    signal stop_count : std_logic := '0';
    signal p_stop_count : std_logic := '0';
    
begin   

    comb : process(cont, rst, enable)
    begin
        if ((rst = '0') and (enable = '1')) then
            if (stop_count = '0') then
                p_cont <= std_logic_vector(unsigned(cont) + i);            
            end if;
            
            if (unsigned(cont) = M-i) then
                p_stop_count <= '1';
            end if;
            
            if (unsigned(cont) >= M) then
                p_cont_ended <= '1';
            end if;
        
		elsif (rst = '1') then
			p_cont <= std_logic_vector(to_unsigned(N, p_cont'length));
        end if;
        
    end process comb;


    sync : process(rst, clk)
    begin
        
        if (rst = '1') then
            cont <= std_logic_vector(to_unsigned(N, cont'length));
			counter <= (others=>'0');
			cont_ended <= '0';
        elsif (rising_edge(clk)) then
            cont <= p_cont;
            counter <= p_cont;
            cont_ended <= p_cont_ended;
            s_cont_ended <= p_cont_ended;
            stop_count <= p_stop_count;
        
        end if;
    
    end process sync;

end behavioral;

