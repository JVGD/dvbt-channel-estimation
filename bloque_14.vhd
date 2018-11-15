library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.mi_paquete.all;

entity bloque_14 is
	port(
		clk : in std_logic;
		rst : in std_logic;
		pilot_inf : in complex12;
		pilot_sup : in complex12;
		pilot_valid : in std_logic;
		interp_estim : in complex12;
		interp_valid : in std_logic;
		interp_fin : in std_logic;
		ch_est : out complex12;
		ch_valid : out std_logic
	);
end bloque_14;

architecture behavioral of bloque_14 is

	-- counter
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

	-- FSM
	type b14_states is (idle, interp);
	signal state, nstate : b14_states;	-- state, next state

	-- outputs signals
	signal nch_est : complex12;
	signal nch_valid : std_logic;
	
	-- counter signals
	signal enable, nenable : std_logic;
	signal count_fin : std_logic;
	signal counter : std_logic_vector(7 downto 0);
	
begin

	comb : process(pilot_valid, interp_valid, pilot_sup, pilot_inf, interp_estim, interp_fin, counter, count_fin)
	begin
		-- FSM description
		case state is
			when idle =>
				if (pilot_valid = '1') then
					-- TODO: consider also first inf with a counter
					-- increment counter
					nenable <= '1';
					
					-- go to next state
					nstate <= interp;
					
					-- write pilot_sup as channel estimated
					nch_valid <= '1';
					nch_est <= pilot_inf;
				else					
					nstate <= idle;
					nenable <= '0';
					nch_valid <= '0';
					nch_est <= (re => (others=>'0'), im => (others=>'0'));
				
--					-- end condition: write last pilot
--					if (unsigned(counter) = 142) then
--						nenable <= '1';
--						nch_valid <= '1';
--						nch_est <= pilot_sup;
--					else
--						--if not, normal idle
--						nenable <= '0';
--						nch_valid <= '0';
--						nch_est <= (re => (others=>'0'), im => (others=>'0'));
--					end if;
					
				end if;
				
			when interp =>
				-- disable counter 
				nenable <= '0';
				
				-- while interpolation is not finished
				if (interp_fin = '0') then
					-- next state
					nstate <= interp;
					
					-- if valid write data
					if (interp_valid = '1') then
						nch_valid <= '1';
						nch_est <= interp_estim;
					else
						nch_valid <= '0';
					end if;
				-- if interpolation finished go to idle
				else
					nstate <= idle;
					
					-- end condition: write last pilot
					if (unsigned(counter) = 142) then
						nch_valid <= '1';
						nch_est <= pilot_sup;
					else
						nch_valid <= '0';
					end if;
					
					
				end if;
			
		end case;
	end process comb;
	
	-- sync process
	sync : process( clk, rst )
    begin
        if (rst = '1') then
			ch_valid <= '0';
			ch_est <= (re => (others=>'0'), im => (others=>'0'));
			state <= idle;
			enable <= '0';
        elsif (rising_edge(clk)) then
			ch_valid <= nch_valid;
			ch_est <= nch_est;
			state <= nstate;
			enable <= nenable;
		end if;
    end process sync;


	-- Mapping of component
	cont_n : cont_N_i_M
		generic map( 
			N => 0,
			i => 1, 	-- counter step count
			M => 142  	-- counter end number
			)
		port map(
			clk => clk,
			rst => rst,
			enable => enable,
			counter => counter,
			cont_ended => count_fin
			);

end behavioral;

