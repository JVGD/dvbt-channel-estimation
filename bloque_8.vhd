library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mi_paquete.all;
use ieee.math_real.all;

entity bloque_8 is

    port(
        clk         : in std_logic;
        rst         : in std_logic;
        addr_symb   : out std_logic_vector(10 downto 0);
        data_symb   : in std_logic_vector(23 downto 0);
        symb_ready  : in std_logic;
        addr_pilot  : out std_logic_vector(10 downto 0);
        data_pilot  : in std_logic_vector(23 downto 0);
        pilot_ready : in std_logic;
		pilot_rx 	: out complex12;
		pilot_tx_signed : out std_logic;
		pilot_txrx_fin : out std_logic;
		valid : out std_logic
        );

end bloque_8;

architecture behavioral of bloque_8 is  

	-- cont
	component cont_N_i_M is
		generic( 
			N : integer := 0; -- counter init number
			i : integer := 12; -- counter step count
			M : integer := 1704 -- counter end number
			);
		port(
			clk : in std_logic;
			rst : in std_logic;
			enable: in std_logic;
			counter : out std_logic_vector(natural(ceil(log2(real(M+1))))-1 downto 0);
			cont_ended : out std_logic
			);
		end component; 
    
    signal enable	: std_logic := '0';
    signal addr 	: std_logic_vector(10 downto 0);
	signal p_addr 	: std_logic_vector(10 downto 0);
    signal p_valid	: std_logic := '0';
	signal p_pilot_txrx_fin : std_logic := '0';
	
    signal spilot_rx : complex12;
	signal p_pilot_rx : complex12;
	signal spilot_tx_signed : std_logic;
	signal p_pilot_tx_signed : std_logic;
	
begin

--	-- Wiring input pilot rx (data_symb) to pilot_rx_out
--	pilot_rx.re <= data_symb(23 downto 12);
--	pilot_rx.im <= data_symb(11 downto 0);
--	
--	-- Wiring as well the sign bit to the pilot_tx_signed
--	pilot_tx_signed <= data_pilot(23);

	uut_cont_N_i_M : cont_N_i_M
		generic map( 
			N => 0,
			i => 12, -- counter step count
			M => 1704  -- counter end number
			)
		port map(
			clk => clk,
			rst => rst,
			enable => enable,
			counter => p_addr,
			cont_ended => p_pilot_txrx_fin
			);

    comb : process(rst, enable, symb_ready, pilot_ready, p_pilot_txrx_fin, data_symb, data_pilot)
    begin
		-- Enable condition & p_valid condition
		if (symb_ready = '1') and (pilot_ready = '1') and (p_pilot_txrx_fin = '0') then
			-- Counter enable conditions
			enable <= '1';
			p_valid <= '1';
			-- Getting data for outputting
			p_pilot_rx.re <= data_symb(23 downto 12);
			p_pilot_rx.im <= data_symb(11 downto 0);
			p_pilot_tx_signed <= data_pilot(23);
		else
			enable <= '0';
			p_valid <= '0';
			p_pilot_rx.re <= spilot_rx.re;
			p_pilot_rx.im <= spilot_rx.im;
			p_pilot_tx_signed <= spilot_tx_signed ;
		end if;
		
    end process comb;

    sync : process(rst, clk)
    begin
        if (rst = '1') then
			addr <= (others=>'0');
			addr_symb <= (others=>'0');
			addr_pilot <= (others=>'0');
			valid <= '0';
			pilot_txrx_fin <= '0';
			pilot_rx.re <= (others=>'0');
			pilot_rx.im <= (others=>'0');
			pilot_tx_signed <= '0';
			spilot_rx.re <= (others=>'0');
			spilot_rx.im <= (others=>'0');
			spilot_tx_signed <= '0';
        elsif (rising_edge(clk)) then
			addr <= p_addr;
			addr_symb <= p_addr;
			addr_pilot <= p_addr;
			valid <= p_valid;
			pilot_txrx_fin <= p_pilot_txrx_fin;
			pilot_rx <= p_pilot_rx;
			spilot_rx<= p_pilot_rx;
			pilot_tx_signed <= p_pilot_tx_signed;
			spilot_tx_signed <= p_pilot_tx_signed;
        end if;
    end process sync;
    
end behavioral;