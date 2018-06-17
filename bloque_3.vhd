library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity bloque_3 is

    port(
        data_in_b3  : in std_logic_vector(23 downto 0);    -- [Re(23,12), Im(11,0)]
        valid_in_b3 : in std_logic;                        -- 1 if data_in is ready
        clk_b3      : in std_logic;
        rst_b3      : in std_logic;
        data_out_b3 : out std_logic_vector(23 downto 0);    -- [Re(23,12), Im(11,0)]
        addr_out_b3 : out std_logic_vector(10 downto 0);    -- 11b = 2^(11) = 2408 addrs
        write_en_b3 : out std_logic;
        write_fin_b3 : out std_logic
        );

end bloque_3;



architecture behavioral of bloque_3 is

    -- Signals for address counter
    signal addr   : std_logic_vector(10 downto 0) := (others=>'0');
    signal p_addr : std_logic_vector(10 downto 0) := (others=>'0');
    
    -- Out signals
    signal p_write_en : std_logic := '0';
    
    -- Signals for data
    signal p_data : std_logic_vector(23 downto 0) := (others=>'0');
    signal data   : std_logic_vector(23 downto 0) := (others=>'0');
    
    -- If firt time write on addr = 0x000000...
    signal is_first_time : std_logic := '1';
    
    -- To singaling end of memory writing
    signal p_end_cont : std_logic := '0';
    signal end_cont : std_logic := '0';

begin

    comb: process(valid_in_b3, addr, data_in_b3, end_cont)
    begin

        if ((valid_in_b3 = '1') and (end_cont = '0')) then
            -- Asserting we're doing things ok
            assert ( NOT( unsigned(addr) >= 1706 ) ) 
            report " bloque_2 : addr cont overflow, writting more than 1705 symbols in RAM?" 
            severity failure;
            
            -- Fetching data
            p_data <= data_in_b3;
            
            -- Increment addr to write
            if (is_first_time ='1') then    -- First time we write
                is_first_time <= '0';       -- in addr = 0
                p_addr <= addr;
                
            else
                p_addr <= std_logic_vector(unsigned(addr) + 1);
                
            end if;
            
            -- We'll write RAM on next clk cycle
            p_write_en <= '1';
        
        else
            -- Do not fetch data
            p_data <= data;
        
            -- Do not increment write address
            p_addr <= addr;
            
            -- Do not write (no valid data)
            p_write_en <= '0';
            
            
        end if;
        
        -- Controlling the end of the simulation
        -- If written one OFDM symbol
        if ( unsigned(addr) = 1704 ) then
            p_write_en <= '0';
            p_end_cont <= '1';
        end if;
    
    end process;
    
    
    sync : process(rst_b3, clk_b3)
    begin
    
        if (rst_b3 = '1') then
            addr_out_b3 <= (others=>'0');
            write_en_b3 <= '0';
            data_out_b3 <= (others=>'0');
            
        elsif (rising_edge(clk_b3)) then
            addr         <= p_addr;
            addr_out_b3  <= p_addr;
            data         <= p_data;
            data_out_b3  <= p_data;
            write_en_b3  <= p_write_en;
            end_cont     <= p_end_cont;
            write_fin_b3 <= p_end_cont;
            
            
        end if;
        
    end process;

end behavioral;

