library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bloque_8 is

    port(
        clk         : in std_logic;
        rst         : in std_logic;
        addr_symb   : out std_logic_vector(10 downto 0);
        data_symb   : in std_logic_vector(23 downto 0);
        symb_ready  : in std_logic
        );

end bloque_8;

architecture behavioral of bloque_8 is

    component cont_0_12_1704 is
        port(
            clk : in std_logic;
            rst : in std_logic;
            enable: in std_logic;
            counter : out std_logic_vector(10 downto 0);
            cont_ended : out std_logic
            );
    end component;    
    
    signal p_cont_ena   : std_logic := '0';
    signal cont_ena     : std_logic := '0';
    signal symb_readed  : std_logic := '0';
--    signal p_valid      : std_logic := '0';
--    signal valid        : std_logic :='0';
        
begin

    -- UUT
    counter_0_12_1704 : cont_0_12_1704
        port map(
            clk => clk,
            rst => rst,
            enable => cont_ena,
            counter => addr_symb,
            cont_ended => symb_readed
            );

    comb : process(rst, symb_ready)
    begin
        if ((rst = '0') and (symb_ready = '1')) then
            p_cont_ena <= '1';
        end if;
        
    end process comb;


    sync : process(rst, clk)
    begin
        
        if (rst = '1') then
            cont_ena <= '0';
            
        elsif (rising_edge(clk)) then
            cont_ena <= p_cont_ena;
            
        end if;
    
    end process sync;

end behavioral;