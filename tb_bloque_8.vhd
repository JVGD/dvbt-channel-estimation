library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity tb_bloque_8 is
end tb_bloque_8;
 
architecture behavior of tb_bloque_8 is 
 
    -- component declaration for the unit under test (uut)
     -- component declaration
    component bloque_8
        port(
            clk         : in std_logic;
            rst         : in std_logic;
            addr_symb   : out std_logic_vector(10 downto 0);
            data_symb   : in std_logic_vector(23 downto 0);
            symb_ready  : in std_logic
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
    
    signal s_clk : std_logic;
    signal s_rst : std_logic;
    signal s_addr_symb : std_logic_vector(10 downto 0) := (others=>'0');
    signal s_data_symb : std_logic_vector(23 downto 0) := (others=>'0');
    signal s_symb_ready : std_logic := '0';
    
begin
 
    -- Clock manager instance
    clk_mng : clkmanager
        generic map(
            clk_period => 10 ns,
            rst_active_value => '1',
            rst_cycles => 1)
        port map (
            endsim => '0',
            clk => s_clk,
            rst => s_rst
            );
 
    -- instantiate the unit under test (uut)
    uut_bloque_8 : bloque_8 
        port map (
            clk => s_clk,
            rst => s_rst,
            addr_symb => s_addr_symb,
            data_symb => s_data_symb,
            symb_ready => s_symb_ready
            );
            
            
    -- stimulus process
    stim_proc: process
    begin		
        -- reset
        wait for 20 ns;
        
        s_symb_ready <= '1';
        
        wait for 34000 ns;
        
    end process;

end;
