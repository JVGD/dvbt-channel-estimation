library ieee;
use ieee.std_logic_1164.all;

entity bloque_5 is

	port(
		clk   : in std_logic;   --clock
		rst : in std_logic;	--reset
		Yout  : out std_logic;	--randomized output
        valid : out std_logic   
        );
        
end bloque_5;


architecture bloque_5_1 of bloque_5 is

	-- verification checker
	component datacompare is
		generic(
			SIMULATION_LABEL         : string  := "b2 datacompare";               --! Allow to separate messages from different instances in SIMULATION
			VERBOSE                  : boolean := false;                          --! Report correct data and not only erroneous data
			DEBUG                    : boolean := false;                          --! Print debug info (developers only)        
			GOLD_OUTPUT_FILE         : string  := "symbOFDM.txt"; 				  --! File where data is stored
			GOLD_OUTPUT_NIBBLES      : integer := 2;                              --! Maximum hex chars for each output data 
			DATA_WIDTH               : integer := 8                               --! Width of inout data
			);
		port(
			clk    : in std_logic;                                --! Expects input data aligned to this clock
			data   : in std_logic_vector (DATA_WIDTH-1 downto 0); --! Data to compare with data in file
			valid  : in std_logic;                                --! Active high, indicates data is valid
			endsim : in std_logic                                 --! Active high, tells the process to close its open files
			);
		end component;

    signal prbs_reg : std_logic_vector(10 downto 0);
    signal p_prbs_reg : std_logic_vector(10 downto 0);
    signal s_in : std_logic;
    signal p_Yout : std_logic;
	signal sYout : std_logic; -- for datacompare
    signal p_valid : std_logic := '0';
	
begin
    
	bloque_2_datacompare : datacompare
		generic map(
			SIMULATION_LABEL => "b5 datacompare",               	--! Allow to separate messages from different instances in SIMULATION
			VERBOSE => false,                          				--! Report correct data and not only erroneous data
			DEBUG => false,                          				--! Print debug info (developers only)        
			GOLD_OUTPUT_FILE => "prbs.txt",		 				  	--! File where data is stored
			GOLD_OUTPUT_NIBBLES => 1,                              	--! Maximum hex chars for each output data 
			DATA_WIDTH => 1                               			--! Width of inout data
			)
		port map(
			clk => clk,                                	--! Expects input data aligned to this clock
			data(0) => sYout, 							--! Data to compare with data in file
			valid => not(rst),                          --! Active high, indicates data is valid
			endsim => '0'                              	--! Active high, tells the process to close its open files
			);	

    -- Combinational process
    comb: process (prbs_reg, s_in, rst)
    begin
		--Combinational process
		s_in <= prbs_reg(2) xor prbs_reg(0);
		p_Yout <= prbs_reg(0);
		p_prbs_reg <= s_in & prbs_reg(10 downto 1);
		p_valid <= '1';
    end process comb;
    
	--Sequential process
	sequential : process(rst, prbs_reg, clk, s_in)
	begin
		if (rst = '1') then
			prbs_reg <= "11111111111";
			Yout <= '0';
			valid <= '0';
			sYout <= '0';
		elsif rising_edge(clk) then
			prbs_reg <= p_prbs_reg;
            Yout <= p_Yout;
			sYout <= p_Yout;
            valid <= p_valid;
            
		end if;
        
	end process sequential;
	

	
end bloque_5_1;
