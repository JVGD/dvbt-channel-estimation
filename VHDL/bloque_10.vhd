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
		pilot_data_valid : out std_logic;
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
			enable : in std_logic;
			counter : out std_logic_vector(natural(ceil(log2(real(M+1))))-1 downto 0);
			cont_ended : out std_logic
			);
		end component; 

	signal enable : std_logic;
	signal p_enable : std_logic;
	signal p_pilot_data  : std_logic_vector(23 downto 0);
	signal p_pilot_data_valid : std_logic;

        
begin

	uut_cont_N_i_M : cont_N_i_M
		generic map( 
			N => 0,
			i => 1, 	-- counter step count
			M => 142  	-- counter end number
			)
		port map(
			clk => clk,
			rst => rst,
			enable => enable,
			counter => pilot_addr,
			cont_ended => pilot_write_fin
			);

    comb : process(rst, pilot_eq_valid, pilot_eq)
    begin
		-- Non conditional part
		p_enable <= pilot_eq_valid;
		p_pilot_data_valid <= pilot_eq_valid;
		p_pilot_data(23 downto 12) <= pilot_eq.re;
		p_pilot_data(11 downto 0) <= pilot_eq.im;
		
    end process comb;

    sync : process(rst, clk)
    begin
        if (rst = '1') then
            pilot_data <= (others=>'0');
			pilot_data_valid <= '1';
			enable <= '0';
        elsif (rising_edge(clk)) then
			pilot_data <= p_pilot_data;
			pilot_data_valid <= p_pilot_data_valid;
			enable <= p_enable;
        end if;
    end process sync;


end behavioral;