library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cont_21 is

    port(
        clk : in std_logic;
        rst : in std_logic;
        enable: in std_logic;
        counter : out std_logic_vector(10 downto 0);
        cont_ended : out std_logic
        );

end cont_21;

architecture behavioral of cont_21 is
    
    signal cont : std_logic_vector(10 downto 0) := (others => '0');
    signal p_cont : std_logic_vector(10 downto 0) := (others => '0');
	signal s_cont_ended : std_logic := '0';
    signal p_cont_ended : std_logic := '0';
    signal stop_count : std_logic := '0';
    signal p_stop_count : std_logic := '0';
    
begin   

    comb : process(cont, rst, enable, cont, s_cont_ended)
    begin
        if ((rst = '0') and (enable = '1')) then
            -- Count finished and reset counter
			if (s_cont_ended ='0') then
				if (unsigned(cont) = 19) then
					p_cont_ended <= '1';
					p_cont <= (others=>'0');
				else
					p_cont <= std_logic_vector(unsigned(cont) + 1);
					p_cont_ended <= '0';
				end if;
			else
				-- cont_ended is like valid
				-- should be active only 1 clk 
				-- cycle. so we set it down
				p_cont_ended <= '0'; 
			end if;

        end if;
        
    end process comb;


    sync : process(rst, clk)
    begin
        
        if (rst = '1') then
            cont <= (others=>'0');
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