library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity bloque_genera_sybm_pilot_tb is
end bloque_genera_sybm_pilot_tb;
 
architecture behavior of bloque_genera_sybm_pilot_tb is 
     
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
			pilot_ready : in std_logic
			);
        end component;
        
    component bloque_genera_symbOFDM
        port(
            clk         : out std_logic;
            rst         : out std_logic;
            addr_symb   : in  std_logic_vector(10 downto 0);
            data_symb   : out std_logic_vector(23 downto 0);
            symb_ready  : out std_logic
            );
        end component;
        
    component bloque_genera_pilots
        port(
            clk          : in std_logic;
            rst          : in std_logic;
            addr_pilots  : in  std_logic_vector(10 downto 0);
            data_pilots  : out std_logic_vector(23 downto 0);
            pilots_ready : out std_logic
            );
        end component;        
            
    signal s_clk : std_logic;
    signal s_rst : std_logic;

    signal s_addr_symb : std_logic_vector(10 downto 0) := (others=>'0');
    signal s_data_symb : std_logic_vector(23 downto 0) := (others=>'0');
    signal s_symb_ready : std_logic;

    signal s_addr_pilot : std_logic_vector(10 downto 0) := (others=>'0');
    signal s_data_pilot : std_logic_vector(23 downto 0) := (others=>'0');
    signal s_pilot_ready : std_logic;


begin
 
    -- instantiate the unit under test (uut)
    uut_bloque_8 : bloque_8 
        port map (
            clk => s_clk,
            rst => s_rst,
            addr_symb => s_addr_symb,
            data_symb => s_data_symb,
            symb_ready => s_symb_ready,
            addr_pilot => s_addr_pilot,
            data_pilot => s_data_pilot,
            pilot_ready => s_pilot_ready             
            );
            
     uut_genera_symb : bloque_genera_symbOFDM 
        port map (
            clk => s_clk,
            rst => s_rst,
            addr_symb => s_addr_symb,
            data_symb => s_data_symb,
            symb_ready => s_symb_ready 
            );
            
     uut_genera_pilots : bloque_genera_pilots 
        port map (
            clk => s_clk,
            rst => s_rst,
            addr_pilots => s_addr_pilot,
            data_pilots => s_data_pilot,
            pilots_ready => s_pilot_ready 
            );            

end;
