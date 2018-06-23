library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;


entity tb_cont_0_12_1704 is
end tb_cont_0_12_1704;

architecture behavioral of tb_cont_0_12_1704 is

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
    
    component cont_0_12_1704 is
        port(
            clk : in std_logic;
            rst : in std_logic;
            enable: in std_logic;
            counter : out std_logic_vector(10 downto 0);
            cont_ended : out std_logic
            );
    end component;
    
    signal clk : std_logic;
    signal rst : std_logic;
    signal enable : std_logic;
    signal counter : std_logic_vector(10 downto 0);
    signal cont_ended : std_logic := '0';
    
begin

    -- Clock manager instance
    bloque_1_clk : clkmanager
        generic map(
            clk_period => 10 ns,
            rst_active_value => '1',
            rst_cycles => 1)
        port map (
            endsim => '0',
            clk => clk,
            rst => rst
            );

    -- UUT
    counter_0_12_1704 : cont_0_12_1704
        port map(
            clk => clk,
            rst => rst,
            enable => enable,
            counter => counter,
            cont_ended => cont_ended
            );
            
    stim_procc: process
    begin
        enable <= '0';

        wait for 20 ns;
        enable <= '1';

        wait for 50 ns;
        enable <= '1';
            
        wait for 100 ns;
        enable <= '0';
    end process;


end behavioral;

