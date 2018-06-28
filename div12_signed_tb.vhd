library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity div12_signed_tb is
end div12_signed_tb;
 
architecture behavior of div12_signed_tb is 
 
    -- component declaration for the unit under test (uut)
     -- component declaration
    component div12_signed
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
            clk_period       : time      := 10 ns;  
            rst_active_value : std_logic := '0'; 
            rst_cycles       : integer   := 10 
            );
        port (
            endsim : in  std_logic;
            clk    : out std_logic; 
            rst    : out std_logic 
            );
        end component;
    
    signal clk : std_logic;
    signal rst : std_logic;
    
    signal dividend    : std_logic_vector(11 downto 0):= (others=>'0');
    signal divisor     : std_logic_vector(11 downto 0):= (others=>'0');   
    signal quotient    : std_logic_vector(11 downto 0):= (others=>'0');
    signal fractional  : std_logic_vector(4 downto 0):= (others=>'0');
	
	signal experi_result : std_logic_vector(11 downto 0) := (others=>'0');
	signal teoric_result : std_logic_vector(11 downto 0) := (others=>'0');
    
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
    uut_div12_signed : div12_signed
        port map (
            clk => clk,
            dividend => dividend,
            divisor => divisor,
            quotient => quotient,
            fractional => fractional
            );
            
            
    -- stimulus process
    stim_proc: process
    begin		
        -- reset
        wait for 20 ns;

        wait for 30*10 ns;
		--	x: 2.750000, X: 2.750000 0x02c 0b000000101100
		--	y: 1.000000, Y: 1.000000 0x010 0b000000010000
		--	r: 2.750000, R: 2.750000 0x02c 0b000000101100
        dividend <= "000000101100";
        divisor  <= "000000010000";
		teoric_result <= "000000101100";

		
		wait for 30*10 ns;
		--	x: -2.000000, X: -2.000000 0xfe0 0b111111100000
		--	y: -1.000000, Y: -1.000000 0xff0 0b111111110000
		--	r: 2.000000, R: 2.000000 0x020 0b000000100000
        dividend <= "111111100000";
        divisor  <= "111111110000"; 
		teoric_result <= "000000100000";

		
		wait for 30*10 ns;
		--	x: -2.000000, X: -2.000000 0xfe0 0b111111100000
		--	y: 1.000000, Y: 1.000000 0x010 0b000000010000
		--	r: -2.000000, R: -2.000000 0xfe0 0b111111100000
        dividend <= "111111100000";
        divisor  <= "000000010000"; 
		teoric_result <= "111111100000";


		wait for 30*10 ns;
		--	x: 2.000000, X: 2.000000 0x020 0b000000100000
		--	y: -1.000000, Y: -1.000000 0xff0 0b111111110000
		--	r: -2.000000, R: -2.000000 0xfe0 0b111111100000
        dividend <= "000000100000";
        divisor  <= "111111110000"; 
		teoric_result <= "111111100000";
		
		wait for 30*10 ns;
		dividend <= "000001001100";
        divisor  <= "000000111110"; 
		teoric_result <= "000000010011";
		--x: 4.750000, X: 4.750000 0x 04c 0b 000001001100
		--y: 3.900000, Y: 3.875000 0x 03e 0b 000000111110
		--r: 1.217949, R: 1.187500 0x 013 0b 000000010011
		
		wait for 30*10 ns;
		dividend <= "111110110100";
        divisor  <= "111111000010"; 
		teoric_result <= "000000010011";
		--x: -4.750000, X: -4.750000 0x fb4 0b 111110110100
		--y: -3.900000, Y: -3.875000 0x fc2 0b 111111000010
		--r: 1.217949, R: 1.187500 0x 013 0b 000000010011
		
		wait for 30*10 ns;
		dividend <= "111110110100";
        divisor  <= "000000111110"; 
		teoric_result <= "111111101101";
		--x: -4.750000, X: -4.750000 0x fb4 0b 111110110100
		--y: 3.900000, Y: 3.875000 0x 03e 0b 000000111110
		--r: -1.217949, R: -1.187500 0x fed 0b 111111101101
		
		wait for 30*10 ns;
		dividend <= "000001001100";
        divisor  <= "111111000010"; 
		teoric_result <= "111111101101";
		--x: 4.750000, X: 4.750000 0x 04c 0b 000001001100
		--y: -3.900000, Y: -3.875000 0x fc2 0b 111111000010
		--r: -1.217949, R: -1.187500 0x fed 0b 111111101101        

        wait for 34000 ns;

        
    end process;

	experi_result <= quotient(7 downto 0) & fractional(3 downto 0);

end;