library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity bloque_6 is

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

end bloque_6 ;

architecture behavioral of bloque_6 is
	
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

    -- If prbs > 0 - the DVBT pilot is -4/3
    -- If prbs < 0 - the DVBT pilot is +4/3
    -- This is coded as 
    --      word: [8b integer, 4b fractionary]
    --      number: [12b real, 12b imaginary]
    signal pilot_pos : std_logic_vector(23 downto 0) := "000000010101000000000000";
    signal pilot_neg : std_logic_vector(23 downto 0) := "111111101011000000000000";
    signal data : std_logic_vector(23 downto 0);
	signal p_data : std_logic_vector(23 downto 0);
	signal p_write_en : std_logic;
	signal p_addr : std_logic_vector(10 downto 0);
	signal p_write_fin : std_logic;
	
begin

	uut_cont_N_i_M : cont_N_i_M
		generic map( 
			N => 0,
			i => 1, -- counter step count
			M => 1704  -- counter end number
			)
		port map(
			clk => clk_b6,
			rst => rst_b6,
			enable => valid_b6,
			counter => p_addr,
			cont_ended => p_write_fin
			);

    comb: process(prbs_b6, rst_b6, clk_b6, valid_b6, p_write_fin)
    begin
		-- valid_b6 AND p_write_fin stops count in 1704
        if (valid_b6 = '1') and (p_write_fin = '0') then
			-- Write enable
			p_write_en <= '1';
            -- Assigning pilot
            if ( prbs_b6 = '0' ) then
                p_data <= pilot_pos;
            elsif ( prbs_b6 = '1' ) then
                p_data <= pilot_neg;
            end if;
		else
			p_data <= data;
			p_write_en <= '0';
		end if;
    end process;


    sync : process(rst_b6, clk_b6)
    begin
        if (rst_b6 = '1') then
			data <= (others=>'0');
			data_out_b6 <= (others=>'0');
			addr_out_b6 <= (others=>'0');
			write_en_b6 <= '1';
			write_fin_b6 <= '0';
        elsif rising_edge(clk_b6) then
            write_en_b6 <= p_write_en;
			data <= p_data;
			data_out_b6 <= p_data;
			addr_out_b6 <= p_addr;
			write_fin_b6 <= p_write_fin;
        end if;
    end process;

end behavioral;

