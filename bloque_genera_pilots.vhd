library ieee;
use ieee.std_logic_1164.all;
 
-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;
 
entity bloque_genera_pilots is

    port(
        clk          : in std_logic;
        rst          : in std_logic;
        addr_pilots  : in  std_logic_vector(10 downto 0);
        data_pilots  : out std_logic_vector(23 downto 0);
        pilots_ready : out std_logic
    );

end bloque_genera_pilots;
 
architecture behavior of bloque_genera_pilots is 

    component bloque_7
    port(
        clka : in  std_logic;
        wea : in  std_logic_vector(0 downto 0);
        addra : in  std_logic_vector(10 downto 0);
        dina : in  std_logic_vector(23 downto 0);
        clkb : in  std_logic;
        addrb : in  std_logic_vector(10 downto 0);
        doutb : out  std_logic_vector(23 downto 0)
        );
    end component; 
 
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
            clk   : in std_logic;	--clock
            rst : in std_logic;	    --reset
            Yout  : out std_logic;	--randomized output
            valid : out std_logic
            );
            
    end component; 
    
    -- Block 5 signals
    signal prbs_b5 : std_logic;
    signal valid_b5: std_logic;
    
    -- Block 6 signals
    signal data_b6 : std_logic_vector(23 downto 0);
    signal addr_b6 : std_logic_vector(10 downto 0);
    signal write_en_b6 : std_logic;
    
    
begin

    	-- instantiate the unit under test (uut)
    bloque_7_DPRAM: bloque_7 
        port map (
            clka => clk,
            dina => data_b6,
            addra => addr_b6,
            wea(0) => write_en_b6,
            clkb => clk,
            addrb => addr_pilots,
            doutb => data_pilots
            );
 
	-- instantiate the unit under test (uut)
    bloque_6_memwrite : bloque_6 
        port map (
            clk_b6  => clk,
            rst_b6  => rst,
            prbs_b6 => prbs_b5,
            valid_b6 => valid_b5,
            data_out_b6 => data_b6,
            addr_out_b6 => addr_b6,
            write_en_b6 => write_en_b6,
            write_fin_b6 => pilots_ready
            );
            
	--Instantiation of component
	bloque_5_prbs : bloque_5
        port map(
            clk   => clk,
            rst => rst,
            Yout  => prbs_b5,
            valid => valid_b5
        );       

end;
