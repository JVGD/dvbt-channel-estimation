library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity bloque_3 is

    port(
        data_in_b3  : in std_logic_vector(23 downto 0);    -- [Re(23,12), Im(11,0)]
        valid_in_b3 : in std_logic;                        -- 1 if data_in is ready
        clk_b3      : in std_logic;
        rst_b3      : in std_logic;
        data_out_b3 : out std_logic_vector(23 downto 0);    -- [Re(23,12), Im(11,0)]
        addr_out_b3 : out std_logic_vector(10 downto 0);    -- 11b = 2^(11) = 2408 addrs
        write_en_b3 : out std_logic;						-- write enable for b4 memory
        write_fin_b3 : out std_logic						-- write fin for b8
        );

end bloque_3;



architecture behavioral of bloque_3 is

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

	-- signals
	signal p_data_out_b3 : std_logic_vector(23 downto 0);
	signal p_write_en_b3 : std_logic;
	signal p_valid_in_b3 : std_logic;
	signal s_valid_in_b3 : std_logic;

begin

	uut_cont_N_i_M : cont_N_i_M
		generic map( 
			N => 0,
			i => 1, 	-- counter step count
			M => 1704  	-- counter end number
			)
		port map(
			clk => clk_b3,
			rst => rst_b3,
			enable => s_valid_in_b3,
			counter => addr_out_b3,
			cont_ended => write_fin_b3
			);

    comb: process(valid_in_b3, data_in_b3)
    begin
		-- Data always passthrough
		-- but valid only when it is signaled
		p_data_out_b3 <= data_in_b3;
		
		if (valid_in_b3 = '1') then
			p_valid_in_b3 <= '1';
		else
			p_valid_in_b3 <= '0';
		end if;
		
    end process;
    
    sync : process(rst_b3, clk_b3)
    begin
        if (rst_b3 = '1') then
            data_out_b3 <= (others=>'0');
			s_valid_in_b3 <= '0';
			write_en_b3 <= '1';
        elsif (rising_edge(clk_b3)) then
			data_out_b3 <= p_data_out_b3;
			s_valid_in_b3 <= p_valid_in_b3;
			write_en_b3   <= p_valid_in_b3;
        end if;
        
    end process;
	

end behavioral;

