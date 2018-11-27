library ieee;
use ieee.std_logic_1164.all;
 
-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;
 
entity tb_bloque_06 is
end tb_bloque_06;
 
architecture behavior of tb_bloque_06 is 
 
    -- component declaration for the unit under test (uut)
    component bloque_6
    port(
        clk_b6       : in std_logic;
        rst_b6       : in std_logic;
        prbs_b6      : in std_logic;
        valid_b6     : in std_logic;
        data_out_b6  : out std_logic_vector(23 downto 0);
        addr_out_b6  : out std_logic_vector(10 downto 0);
        write_en_b6  : out std_logic;
        write_fin_b6 : out std_logic
        );
    end component;
    
    -- PRBS
    component bloque_5
		port(
			clk   : in std_logic;   --clock
			rst : in std_logic;	--reset
			Yout  : out std_logic;	--randomized output
			valid : out std_logic;
			enable : in std_logic
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
    
    
    signal clk  : std_logic;
    signal rst  : std_logic;
    signal prbs_reg : std_logic;
    signal data : std_logic_vector(23 downto 0);
    signal write_en : std_logic;
    signal addr : std_logic_vector(10 downto 0);
    signal valid: std_logic;
    signal write_fin : std_logic;
	signal enable : std_logic;
    
begin
 
	-- instantiate the unit under test (uut)
    bloque_6_memwrite : bloque_6 
        port map (
            clk_b6  => clk,
            rst_b6  => rst,
            prbs_b6 => prbs_reg,
            valid_b6 => valid,
            data_out_b6 => data,
            addr_out_b6 => addr,
            write_en_b6 => write_en,
            write_fin_b6 => write_fin
            );
            
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
            
	--Instantiation of component
	bloque_5_prbs : bloque_5
        port map(
            clk   => clk,
            rst => rst,
            Yout  => prbs_reg,
            valid => valid,
			enable => enable
        );       


	stim : process
	begin
		enable <= '0';
		wait for 30 ns;
		enable <= '1';
		--wait for 17050 ns;
		wait for 17100 ns;
		enable <= '0';
		wait;
	end process;

end;
