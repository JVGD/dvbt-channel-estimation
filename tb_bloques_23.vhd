library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity tb_bloques_23 is
end tb_bloques_23;
 
architecture behavior of tb_bloques_23 is 
 
    -- component declaration for the unit under test (uut)
    component bloque_3
        port(
            data_in     : in std_logic_vector(23 downto 0);
            valid_in    : in std_logic;
            clk         : in std_logic;
            rst         : in std_logic;
            data_out    : out std_logic_vector(23 downto 0);
            addr_out    : out std_logic_vector(10 downto 0);
            write_en    : out std_logic
            );
    end component;
    
    -- component declaration
    component bloque_2
        port(
            data_in : out std_logic_vector(23 downto 0);    -- [Re(23,12), Im(11,0)]
            valid   : out std_logic;                        -- 1 if data_in is ready
            clk     : out std_logic
            );
        end component;
    
    -- Signals for Clock Manager
    -- We do not initializa rst
    -- and clk because they are out
    constant clk_period : time := 10 ns;
    signal rst : std_logic;
    signal clk : std_logic;
    signal endsim : std_logic := '0';
    
    --inputs
    signal valid_in : std_logic := '0';
    signal data_in  : std_logic_vector(23 downto 0);

    --outputs
    signal addr_out : std_logic_vector(10 downto 0);
    signal write_en : std_logic;
    signal data_out : std_logic_vector(23 downto 0);



begin
 
    -- instantiate the unit under test (uut)
    uut_bloque_3: bloque_3 
        port map (
            data_in  => data_in,
            data_out => data_out,
            valid_in => valid_in,
            clk => clk,
            rst => rst,
            addr_out => addr_out,
            write_en => write_en
            );

    -- Clock manager instance
    uut_bloque_2 : bloque_2
        port map(
            data_in => data_in,
            valid   => valid,
            clk     => clk
            );
            
    -- stimulus process
    stim_proc: process
    begin		
        -- reset holded in clkmanager
        wait for clk_period*10;
        
        -- insert stimulus here 
        
        wait for clk_period;
        valid_in <= '1';
        data_in <= (others=>'0');
        
        wait for clk_period;
        valid_in <= '0';

        wait for clk_period;
        valid_in <= '0';

        wait for clk_period;
        valid_in <= '1';
        data_in <= std_logic_vector(unsigned(data_in) + 1);

        wait for clk_period;
        valid_in <= '0';

        wait for clk_period;
        valid_in <= '1';
        data_in <= std_logic_vector(unsigned(data_in) + 1);
        
        wait for clk_period;
        valid_in <= '0';

        wait for clk_period;
        valid_in <= '0';

        wait for clk_period;
        data_in <= std_logic_vector(unsigned(data_in) + 1);
        valid_in <= '1';

        wait for clk_period;
        data_in <= std_logic_vector(unsigned(data_in) + 1);
        wait for clk_period;
        data_in <= std_logic_vector(unsigned(data_in) + 1);
        wait for clk_period;
        data_in <= std_logic_vector(unsigned(data_in) + 1);
        wait for clk_period;
        data_in <= std_logic_vector(unsigned(data_in) + 1);
        wait for clk_period;
        data_in <= std_logic_vector(unsigned(data_in) + 1);
        wait for clk_period;
        data_in <= std_logic_vector(unsigned(data_in) + 1);
        wait for clk_period;
        data_in <= std_logic_vector(unsigned(data_in) + 1);
        wait for clk_period;
        data_in <= std_logic_vector(unsigned(data_in) + 1);
        wait for clk_period;
        data_in <= std_logic_vector(unsigned(data_in) + 1);



        wait;
    end process;

end;
