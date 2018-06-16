library ieee;
use ieee.std_logic_1164.all;
  
entity tb_bloque_4 is
end tb_bloque_4;
 
architecture behavior of tb_bloque_4 is 
 
    -- component declaration for the unit under test (uut)
    component bloque_4
    port(
        clka    : in  std_logic;
        wea     : in  std_logic_vector(0 downto 0);
        addra   : in  std_logic_vector(10 downto 0);
        dina    : in  std_logic_vector(23 downto 0);
        clkb    : in  std_logic;
        addrb   : in  std_logic_vector(10 downto 0);
        doutb   : out  std_logic_vector(23 downto 0)
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
    signal clka : std_logic := '0';
    signal wea : std_logic_vector(0 downto 0) := (others => '0');
    signal addra : std_logic_vector(10 downto 0) := (others => '0');
    signal dina : std_logic_vector(23 downto 0) := (others => '0');
    signal clkb : std_logic := '0';
    signal addrb : std_logic_vector(10 downto 0) := (others => '0');

    --outputs
    signal doutb : std_logic_vector(23 downto 0);

    -- clock period definitions
    constant clka_period : time := 10 ns;
    constant clkb_period : time := 10 ns;

begin
 
    -- instantiate the unit under test (uut)
    uut: bloque_4 
        port map (
            clka => clka,
            wea => wea,
            addra => addra,
            dina => dina,
            clkb => clkb,
            addrb => addrb,
            doutb => doutb
            );
            
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


end;
