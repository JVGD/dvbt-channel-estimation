library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divider_usigned is

	-- Divider 12 with format
	-- 8b integer
	-- 4b fractionary
	
	-- z = x/y

    port(
		rst : in std_logic;
		clk : in std_logic;
		valid_in : in std_logic;
		x : in std_logic_vector(11 downto 0);
		y : in std_logic_vector(11 downto 0);
		z : out std_logic_vector(11 downto 0);
		valid_out : out std_logic
		);

end divider_usigned;

architecture behavioral of divider_usigned is
 
    -- component declaration for the unit under test (uut)
    -- component declaration
    component div12_signed
        port(
            clk         : in std_logic;
            dividend    : in std_logic_vector(11 downto 0);
            divisor     : in std_logic_vector(11 downto 0);   
            quotient    : out std_logic_vector(11 downto 0);
            fractional  : out std_logic_vector(4 downto 0)
            );
        end component;
	
	component cont_21
		port(
			clk : in std_logic;
			rst : in std_logic;
			enable: in std_logic;
			counter : out std_logic_vector(10 downto 0);
			cont_ended : out std_logic
			);
		end component;
		
	component twos_compliment
		generic(
			N : integer := 12		-- Number inputs bits
			);
		port(
			number_in : in std_logic_vector(N-1 downto 0);
			number_out : out std_logic_vector(N-1 downto 0)
			);
		end component;
	    
	-- div12 signals
    signal quotient : std_logic_vector(11 downto 0);
    signal fractional : std_logic_vector(4 downto 0);
	
	-- cont21 signals
	signal enable: std_logic := '0';
	signal p_enable : std_logic := '0';
	signal counter : std_logic_vector(10 downto 0);
	signal cont_ended : std_logic := '0';
	
	-- tws compliment signals
	signal twosc_1_in : std_logic_vector(11 downto 0);
	signal twosc_1_out : std_logic_vector(11 downto 0);
	signal twosc_2_in : std_logic_vector(11 downto 0);
	signal twosc_2_out : std_logic_vector(11 downto 0);
	
	-- for inputs and outputs
	signal sx : std_logic_vector(11 downto 0);
	signal sy : std_logic_vector(11 downto 0);
	signal sz : std_logic_vector(11 downto 0);
	signal issigned : std_logic;
	
begin
 
    -- instantiate the unit under test (uut)
    uut_div12_signed : div12_signed 
        port map (
            clk        => clk,
            dividend   => sx,
            divisor    => sy,
            quotient   => quotient,
            fractional => fractional
            );
			
	uut_cont_21 : cont_21
		port map(
			clk => clk,
			rst => rst,
			enable => enable,
			counter => counter,
			cont_ended => cont_ended
			);
	
	twos_comp_1 : twos_compliment
		generic map(
			N => 12
			)
		port map(
			number_in => twosc_1_in,
			number_out => twosc_1_out
			);
	
	twos_comp_2 : twos_compliment
		generic map(
			N => 12
			)
		port map(
			number_in => twosc_2_in,
			number_out => twosc_2_out
			);
	
	-- concurrent
	-- fractional(4) is the sign bit
	sz <= quotient(7 downto 0) & fractional(3 downto 0);
	valid_out <= cont_ended;
	
	-- wiring stuff
	twosc_1_in <= x;
	twosc_2_in <= sz;
	sy <= y;
	
	-- removing sign before divider
	--- and adding it after
	issigned <= x(11) xor y(11);
	with issigned select sx <= x when '0', twosc_1_out when '1';
	with issigned select z <= sz when '0', twosc_2_out when '1';
		
	
	-- comb
	comb : process(rst, quotient, fractional, valid_in, cont_ended)
    begin
        if (rst = '0') then
			if (valid_in = '1') then
				p_enable <= '1';
			end if;

			if (cont_ended = '1') then
				p_enable <= '0';			
			end if;
			
		end if;
    end process comb;   
	
	-- sync
	sync : process(rst, clk)
    begin
		if ((rising_edge(clk)) and (rst = '0')) then
			enable <= p_enable;
		end if;
    end process sync;
end;