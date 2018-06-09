library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity tb_bloque_3 is
end tb_bloque_3;
 
architecture behavior of tb_bloque_3 is 
 
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

    -- clkmanager component
    component clkmanager is
        generic (
            CLK_PERIOD       : time      := 10 ns;  --! Period of generated clock
            RST_ACTIVE_VALUE : std_logic := '0';    --! Reset polarity
            RST_CYCLES       : integer   := 10      --! Number of cycles that reset will be asserted at the beginning of the simulation
            );
        port (
            endsim : in  std_logic;  --! \c clk stops changing when endsim='1', which effectively stops the simulation
            clk    : out std_logic;  --! Generated clock
            rst    : out std_logic   --! Generated reset
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
 
    -- Clock manager instance
    clk_mng : clkmanager
        generic map(
            clk_period => clk_period,
            rst_active_value => '1',
            rst_cycles => 2)
        port map (
            endsim => endsim,
            clk => clk,
            rst => rst
            );
 
    -- instantiate the unit under test (uut)
    uut: bloque_3 
        port map (
            data_in  => data_in,
            data_out => data_out,
            valid_in => valid_in,
            clk => clk,
            rst => rst,
            addr_out => addr_out,
            write_en => write_en
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
