library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mi_paquete.all;

entity bloque_8 is

    port(
        clk         : in std_logic;
        rst         : in std_logic;
        addr_symb   : out std_logic_vector(10 downto 0);
        data_symb   : in std_logic_vector(23 downto 0);
        symb_ready  : in std_logic;
        addr_pilot  : out std_logic_vector(10 downto 0);
        data_pilot  : in std_logic_vector(23 downto 0);
        pilot_ready : in std_logic;
		pilot_rx 	: out complex12;
		pilot_tx_signed : out std_logic
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
    
    signal addr_data : std_logic_vector(10 downto 0);
    signal data_readed  : std_logic := '0';
    
    signal p_data_valid : std_logic := '0'; 
    signal data_valid : std_logic := '0';
        
begin

	-- TODO: TEST THIS
	-- Wiring input pilot rx (data_symb) to pilot_rx_out
	pilot_rx.re <= data_symb(23 downto 12);
	pilot_rx.im <= data_symb(11 downto 0);
	
	-- Wiring as well the sign bit to the pilot_tx_signed
	pilot_tx_signed <= data_pilot(23);
	

    -- counter
    counter_0_12_1704 : cont_0_12_1704
        port map(
            clk => clk,
            rst => rst,
            enable => cont_ena,
            counter => addr_data,
            cont_ended => data_readed
            );

    comb : process(rst, symb_ready, pilot_ready, cont_ena, data_readed)
    begin
        if ((rst = '0') and (symb_ready = '1') and (pilot_ready = '1')) then
            p_cont_ena <= '1';
        end if;
        
        if((symb_ready = '1') and (pilot_ready = '1') and (cont_ena = '1')) then
            if (data_readed = '1') then
                p_data_valid <= '0';
                p_cont_ena <= '0';
            else
                p_data_valid <= '1';
            end if;
        end if;
        
        
        
    end process comb;

    sync : process(rst, clk)
    begin
        
        if (rst = '1') then
            cont_ena <= '0';
            
        elsif (rising_edge(clk)) then
            cont_ena <= p_cont_ena;
            data_valid <= p_data_valid;
            
        end if;
    
    end process sync;
    
    -- Concurrent
    addr_symb <= addr_data;
    addr_pilot <= addr_data;

end behavioral;