library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.mi_paquete.all;

-- It takes the equalized pilots and stores them
-- on a DPRAM before the interpolator

entity bloque_10 is

    port(
        clk         : in std_logic;
        rst         : in std_logic; 
		pilot_eq 	: in complex12;
        pilot_eq_valid : in std_logic;
		pilot_addr  : out std_logic_vector(7 downto 0);
        pilot_data  : out std_logic_vector(23 downto 0);
		pilot_write_fin : out std_logic
        );

end bloque_10;

architecture behavioral of bloque_10 is

	-- cont
	component cont_N_i_M is
		generic( 
			N : integer := 0; -- counter init number
			i : integer := 1; -- counter step count
			M : integer := 10 -- counter end number
			);
		port(
			clk : in std_logic;
			rst : in std_logic;
			enable: in std_logic;
			counter : out std_logic_vector(natural(ceil(log2(real(M+1))))-1 downto 0);
			cont_ended : out std_logic
			);
		end component; 
    
    signal p_enable : std_logic := '0';
    signal enable : std_logic := '0';
    	
	signal p_pilot_data : complex12 := (re => (others=>'0'), im => (others=>'0'));
	
	signal s_pilot_write_fin : std_logic := '0';
        
begin

	uut_cont_N_i_M : cont_N_i_M
		generic map( 
			N => 0,
			i => 1, -- counter step count
			M => 142  -- counter end number
			)
		port map(
			clk => clk,
			rst => rst,
			enable => enable,
			counter => pilot_addr,
			cont_ended => s_pilot_write_fin
			);

    comb : process(rst, pilot_eq_valid, enable, pilot_eq)
    begin
        if (rst = '0') and (pilot_eq_valid = '1') then
            p_enable <= '1';
			p_pilot_data <= pilot_eq;	
		elsif (rst = '0') and (pilot_eq_valid = '0') then
			p_enable <= '0';
        end if;
        
        if (rst = '0') and (enable = '1') then
            if (s_pilot_write_fin = '1') then
                p_enable <= '0';
            end if;
        end if;
		
    end process comb;

    sync : process(rst, clk)
    begin
        if (rst = '1') then
            enable <= '0';
			pilot_data <= (others=> '0');
            
        elsif (rising_edge(clk)) then
            enable <= p_enable;
			pilot_data(23 downto 12) <= p_pilot_data.re;
            pilot_data(11 downto 0) <= p_pilot_data.im;
        end if;
    end process sync;

	-- Concurrent
	pilot_write_fin <= s_pilot_write_fin;

end behavioral;