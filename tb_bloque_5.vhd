library ieee;
use ieee.std_logic_1164.all;

entity tb_bloque_5 is
end tb_bloque_5;

architecture tb_bloque_5_1 of tb_bloque_5 is

    -- Declaramos componente
    component bloque_5
        port(
            clk   : in std_logic;	--clock
            rst : in std_logic;	--reset
            Yout  : out std_logic;	--randomized output
            valid : out std_logic
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
        

    --seales
    signal Yout : std_logic_vector(0 downto 0);

    -- Signals for Clock Manager
    -- No inicializamos rst y clk porque son out
    signal rst : std_logic;
    signal clk : std_logic := '1';
    signal valid : std_logic;

begin
	--Instantiation of component
	prbs_bloque : bloque_5
        port map(
            clk   => clk,
            rst => rst,
            Yout  => Yout(0),
            valid => valid
        );
	
    -- Clock manager instance
    clk_mng : clkmanager
        generic map(
            clk_period => 10 ns,
            rst_active_value => '1',
            rst_cycles => 2)
        port map (
            endsim => '0',
            clk => clk,
            rst => rst
            );

end tb_bloque_5_1;