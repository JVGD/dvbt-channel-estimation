library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;

entity bloque_6 is

    port(
        clk_b6       : in std_logic;
        rst_b6       : in std_logic;
        prbs_b6      : in std_logic;
        valid_b6     : in std_logic;
        data_out_b6  : out std_logic_vector(23 downto 0);
        addr_out_b6  : out std_logic_vector(10 downto 0);
        write_en_b6  : out std_logic;
        write_fin_b6 : out std_logic
        );

end bloque_6 ;

architecture behavioral of bloque_6 is

    -- If prbs > 0 - the DVBT pilot is -4/3
    -- If prbs < 0 - the DVBT pilot is +4/3
    -- This is coded as 
    --      word: [8b integer, 4b fractionary]
    --      number: [12b real, 12b imaginary]
    signal pilot_pos : std_logic_vector(23 downto 0) := "000000010101000000000000";
    signal pilot_neg : std_logic_vector(23 downto 0) := "111111101011000000000000";
    signal data : std_logic_vector(23 downto 0);
    signal addr : std_logic_vector(10 downto 0) := (others => '0');
    signal p_addr : std_logic_vector(10 downto 0) := (others => '0');
    signal delay : std_logic := '1';
    signal p_delay : std_logic := '1';
    signal p_write_en : std_logic := '0';
    signal p_end_cont : std_logic := '0';
    signal end_cont : std_logic := '0';

begin

    comb: process(prbs_b6, rst_b6, addr, clk_b6, delay, valid_b6, end_cont)
    begin
    
        if ((rst_b6 = '0') and (valid_b6 = '1') and (end_cont = '0')) then
        
            -- There will be data on next clk
            p_write_en <= '1';
        
            -- Assigning pilot
            if ( prbs_b6 = '0' ) then
                data <= pilot_pos;
            
            elsif ( prbs_b6 = '1' ) then
                data <= pilot_neg;
                
            end if;
            
            -- Addr counter
            if (delay = '0') then
                p_addr <= std_logic_vector(unsigned(addr) + 1);
                
                -- If written one OFDM symbol
                if ( unsigned(addr) = 1704 ) then
                    p_write_en <= '0';
                    p_end_cont <= '1';
                end if;
                
            elsif (delay = '1') then 
                -- We delay the count at the begining
                p_addr <= (others => '0');
                p_delay <= '0';
                
            end if;
        elsif (valid_b6 = '0') then    
            p_write_en <= '0';
        end if;
    
    end process;


    sync : process(rst_b6, clk_b6)
    begin
    
        if (rst_b6 = '1') then
            write_en_b6 <= '0';
            addr_out_b6 <= (others => '0');
              
        elsif (rising_edge(clk_b6) and (rst_b6 = '0')) then
            data_out_b6 <= data;
            addr_out_b6 <= p_addr;
            addr <= p_addr;
            delay <= p_delay;
            write_en_b6 <= p_write_en;
            end_cont <= p_end_cont;
            write_fin_b6 <= p_end_cont;
            
        end if;
        
    end process;

end behavioral;

