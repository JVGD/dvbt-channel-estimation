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
		pilot_sup : inout complex12;
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
	type b12_states is (idle, enable_counter, wait_for_data, read_data, send_data);
	signal state, nstate : b12_states;	-- state, next state

	-- counter signals
	signal nenable : std_logic;
	signal enable : std_logic;
	signal ram_readed : std_logic;
	
	-- output signals
	signal npilot_inf : complex12;
	signal npilot_sup : complex12;
	signal pilot_sup_signal : complex12;
	signal nvalid : std_logic;

	-- control flow signals
	signal waited : std_logic;
	signal nwaited : std_logic;
		
	
begin
	
    -- proceso combinacional
    comb : process( state, ram_ready, interp_ready, waited, data, pilot_sup)
	begin
		-- FSM
		case state is
			when idle =>
				-- signal initialization
				nvalid <= '0';
				nenable <= '0';
				nwaited <= '0';
				
				-- reading pilot sup
				npilot_sup.re <= data(23 downto 12);
				npilot_sup.im <= data(11 downto 0);
				npilot_inf.re <= data(23 downto 12);
				npilot_inf.im <= data(11 downto 0);
				
				-- next state
				if (interp_ready = '1' and ram_ready = '1') then
					nstate <= enable_counter;	-- next state
				else
					nstate <= idle;
				end if;
				
			when enable_counter => 
				nenable <= '1';
				nstate <= wait_for_data;
				
			when wait_for_data => 
				-- disable counter
				nenable <= '0';
				
				-- for waiting 2 cycles
				if (waited = '0') then
					nwaited <= '1';
					nstate <= wait_for_data;
				else
					nwaited <= '0';
					nstate <= read_data;
				end if;
				
			when read_data => 
				-- next state
				if (interp_ready = '1' and ram_ready = '1') then
					-- updating pilot inf with previous pilot sup
					npilot_inf <= pilot_sup;
					
					-- reading pilot sup
					npilot_sup.re <= data(23 downto 12);
					npilot_sup.im <= data(11 downto 0);

					-- next state and valid
					nstate <= send_data;
					nvalid <= '1';
				else
					nstate <= read_data;
					nvalid <= '0';
				end if;
							
			when send_data =>
				-- when sending data
				-- Wait till interp start processing the data
				if (interp_ready = '0' and ram_ready = '1') then
					nstate <= enable_counter;
					nvalid <= '0';
				else
					nstate <= send_data;
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
			pilot_inf <= (re => (others=>'0'), im => (others=>'0'));
			pilot_sup <= (re => (others=>'0'), im => (others=>'0'));
			pilot_sup_signal <= (re => (others=>'0'), im => (others=>'0'));
			valid <= '0';
			waited <= '0';
        elsif (rising_edge(clk)) then
			state <= nstate;
			enable <= nenable;
			pilot_inf <= npilot_inf;
			pilot_sup <= npilot_sup;
			valid <= nvalid;
			waited <= nwaited;
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