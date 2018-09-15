library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.mi_paquete.all;

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
			symb_ready  : in std_logic;
			addr_pilot  : out std_logic_vector(10 downto 0);
			data_pilot  : in std_logic_vector(23 downto 0);
			pilot_ready : in std_logic;
			pilot_rx 	: out complex12;
			pilot_tx_signed : out std_logic;
			pilot_txrx_fin : out std_logic;
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


	signal clk         	: std_logic;
	signal rst         	: std_logic;
	signal addr_symb   	: std_logic_vector(10 downto 0);
	signal data_symb   	: std_logic_vector(23 downto 0) := (others=>'0');
	signal symb_ready  	: std_logic := '0';
	signal addr_pilot  	: std_logic_vector(10 downto 0);
	signal data_pilot  	: std_logic_vector(23 downto 0) := (others=>'0');
	signal pilot_ready 	: std_logic := '0';
	signal pilot_rx 	: complex12;
	signal pilot_tx_signed : std_logic;
	signal pilot_txrx_fin : std_logic;
	signal valid 		: std_logic;

        
begin
 
    -- Clock manager instance
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
    uut_bloque_8 : bloque_8 
        port map (
            clk => clk,
			rst => rst,
			addr_symb   => addr_symb,
			data_symb   => data_symb,
			symb_ready  => symb_ready,
			addr_pilot  => addr_pilot,
			data_pilot  => data_pilot,
			pilot_ready => pilot_ready,
			pilot_rx 	=> pilot_rx,
			pilot_tx_signed => pilot_tx_signed,
			pilot_txrx_fin => pilot_txrx_fin,
			valid => valid 
			);
            
    -- stimulus process
    stim_proc: process
    begin		
        -- reset
        wait for 40 ns;        
        symb_ready <= '1';
		pilot_ready <= '1';
        wait for 20 us;
        
    end process;

end;
