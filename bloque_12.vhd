library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.mi_paquete.all;

entity bloque_12 is
	port(
		clk : in std_logic;
		rst : in std_logic;
		ram_ready : in std_logic;
		data : in std_logic_vector(23 downto 0);
		addr : out std_logic_vector(7 downto 0);
		pilot_inf : out complex12;
		pilot_sup : out complex12;
		valid : out std_logic;
		interp_ready : in std_logic
	);
    
end bloque_12;
		
architecture behavioral of bloque_12 is

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

	-- FSM
	type b12_states is (idle, inf, sup, send);
	signal state, nstate : b12_states;	-- state, next state
		
	-- counter signals
	signal nenable : std_logic;
	signal enable : std_logic;
	signal ram_readed : std_logic;
	signal addr_cont: std_logic_vector(7 downto 0);
	
--	-- output signals
--	signal naddr : std_logic_vector(7 downto 0);
--	signal npilot_inf : complex12;
--	signal npilot_sup : complex12;
--	signal nvalid : std_logic;

		
	
begin
	
    -- proceso combinacional
    comb : process( state, ram_ready, interp_ready)
	begin
		-- FSM
		case state is
			when idle =>
				if (interp_ready = '1' and ram_ready = '1') then
					nstate <= inf;
					nenable <= '1';
				else
					nstate <= idle;
					nenable <= '0';
				end if;

			when inf => 
				-- reading pilot inf
				--addr <= addr_cont;
				--TODO: to complex12
				
				-- next state
				nstate <= sup;
				
			when sup => 
				-- reading pilot sup
				nenable <= '0';
				--addr <= addr_cont;
				--TODO: to complex12
				--TODO: data valid out
			
				-- next state
				if (interp_ready = '1' and ram_ready = '1') then
					nstate <= send;
				else
					nstate <= sup;
				end if;
							
			when send =>
				-- when sending data
				-- Wait till interp start processing the data
				if (interp_ready = '0' and ram_ready = '1') then
					nstate <= inf;
					nenable <= '1';
				else
					nstate <= send;
				end if;
				
			when others =>
				-- reset state and set everything to default
				nstate  <= idle;
			
		end case;    
	end process comb;
    
    -- proceso secuencial
    sync : process( clk, rst )
    begin
        if (rst = '1') then
			state <= idle;
			enable <= '0';
        elsif (rising_edge(clk)) then
			state <= nstate;
			enable <= nenable;
		end if;
    end process sync;
	
	-- Mapping of component
	cont_n : cont_N_i_M
		generic map( 
			N => 0,
			i => 1, 	-- counter step count
			M => 143  	-- counter end number
			)
		port map(
			clk => clk,
			rst => rst,
			enable => enable,
			counter => addr,
			cont_ended => ram_readed
			);
	
end;