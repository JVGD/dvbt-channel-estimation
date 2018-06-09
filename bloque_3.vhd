library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity bloque_3 is

    port(
        data_in  : in std_logic_vector(23 downto 0);    -- [Re(23,12), Im(11,0)]
        valid_in : in std_logic;                        -- 1 if data_in is ready
        clk      : in std_logic;
        rst      : in std_logic;
        data_out : out std_logic_vector(23 downto 0);    -- [Re(23,12), Im(11,0)]
        addr_out : out std_logic_vector(10 downto 0);    -- 11b = 2^(11) = 2408 addrs
        write_en : out std_logic
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

begin

    comb: process(valid_in, addr)
    begin

        if (valid_in = '1') then
            -- Asserting we're
            -- doing things ok
            assert ( NOT( unsigned(addr) >= 1706 ) ) 
            report " bloque_2 : addr cont overflow, writting more than 1705 symbols in RAM?" 
            severity failure;
            
            -- Fetching data
            p_data <= data_in;
            
            -- Increment addr
            -- to write
            if (is_first_time ='1') then    -- First time we write
                is_first_time <= '0';       -- in addr = 0
                p_addr <= addr;
            else
                p_addr <= std_logic_vector(unsigned(addr) + 1);
            end if;
            -- We'll write RAM
            -- on next clk cycle
            p_write_en <= '1';
        
        else
            -- Do not fetch data
            p_data <= data;
        
            -- Do not increment
            -- write address
            p_addr <= addr;
            
            -- Do not write (no
            -- valid data)
            p_write_en <= '0';
            
            
        end if;
    
    end process;
    
    
    sync : process(rst, clk)
    begin
    
        if (rst = '1') then
            addr_out <= (others=>'0');
            write_en <= '0';
            data_out <= (others=>'0');
            
        elsif (rising_edge(clk)) then
            addr     <= p_addr;
            addr_out <= p_addr;

            data     <= p_data;
            data_out <= p_data;
            
            write_en <= p_write_en;
            
        end if;
        
    end process;

end behavioral;

