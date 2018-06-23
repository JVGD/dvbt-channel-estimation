library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cont_0_12_1704 is

    port(
        clk : in std_logic;
        rst : in std_logic;
        enable: in std_logic;
        counter : out std_logic_vector(10 downto 0);
        cont_ended : out std_logic
        );

end cont_0_12_1704;

architecture behavioral of cont_0_12_1704 is
    
    signal cont : std_logic_vector(10 downto 0) := (others => '0');
    signal p_cont : std_logic_vector(10 downto 0) := (others => '0');
    signal p_cont_ended : std_logic := '0';
    
begin

    comb : process(cont, rst, enable)
    begin
        if ((rst = '0') and (enable = '1')) then
            p_cont <= std_logic_vector(unsigned(cont) + 12);            
            if (unsigned(cont) = 1704) then
                p_cont_ended <= '1';
            end if;
            
        end if;
        
    end process comb;


    sync : process(rst, clk)
    begin
        
        if (rst = '1') then
            cont <= (others=>'0');
            
        elsif (rising_edge(clk)) then
            cont <= p_cont;
            counter <= p_cont;
            cont_ended <= p_cont_ended;
        
        end if;
    
    end process sync;

end behavioral;

