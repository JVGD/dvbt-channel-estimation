library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity div12_tb is
end div12_tb;
 
architecture behavior of div12_tb is 
 
    -- component declaration for the unit under test (uut)
     -- component declaration
    component div12
        port(
            clk         : in std_logic;
            dividend    : in std_logic_vector(11 downto 0);
            divisor     : in std_logic_vector(11 downto 0);   
            quotient    : out std_logic_vector(11 downto 0);
            fractional  : out std_logic_vector(4 downto 0)
            );
        end component;

    -- clkmanager component
    component clkmanager is
        generic (
            clk_period       : time      := 10 ns;  --! period of generated clock
            rst_active_value : std_logic := '0';    --! reset polarity
            rst_cycles       : integer   := 10      --! number of cycles that reset will be asserted at the beginning of the simulation
            );
        port (
            endsim : in  std_logic;  --! \c clk stops changing when endsim='1', which effectively stops the simulation
            clk    : out std_logic;  --! generated clock
            rst    : out std_logic   --! generated reset
            );
        end component;
    
    signal clk : std_logic;
    signal rst : std_logic;
    
    signal dividend    : std_logic_vector(11 downto 0);
    signal divisor     : std_logic_vector(11 downto 0);   
    signal quotient    : std_logic_vector(11 downto 0);
    signal fractional  : std_logic_vector(3 downto 0);
    signal ignore      : std_ulogic;
    
begin
 
    -- clock manager instance
    clk_mng : clkmanager
        generic map(
            clk_period => 10 ns,
            rst_active_value => '1',
            rst_cycles => 1)
        port map (
            endsim => '0',
            clk => clk,
            rst => rst
            );
 
    -- instantiate the unit under test (uut)
    uut_div12 : div12 
        port map (
            clk                     => clk,
            dividend                => dividend,
            divisor                 => divisor,
            quotient                => quotient,
            fractional(4)           => ignore,
            fractional(3 downto 0)  => fractional
            );
            
            
    -- stimulus process
    stim_proc: process
    begin		
        -- reset
        wait for 20 ns;
        dividend <= "000001010000";
        divisor  <= "000000100000";
        
        wait for 40*10 ns;
        dividend <= "000010011000";
        divisor  <= "000000110000";    
--        x: 9.500000, X: 9.500000 098 000010011000
--        y: 3.000000, Y: 3.000000 030 000000110000
--        r: 3.166667, R: 3.187500 033 00000011001100101        
        
        wait for 34000 ns;
        
    end process;

end;
