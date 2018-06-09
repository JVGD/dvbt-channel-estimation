library ieee;
use ieee.std_logic_1164.all;

entity cont1705 is
    port(
        valid_in : in std_logic;                        -- 1 if data_in is ready
        clk      : in std_logic;
        rst      : in std_logic;
        addr_out : out std_logic_vector(10 downto 0);    -- 11b = 2^(11) = 2408 addrs
        write_en : out std_logic
        );

end cont1705;

architecture behavioral of cont1705 is

begin

    comb : process(valid_in)
    begin
        if (rst = '1') then
            -- en reset ponemos todo a 0
            estado  <= reposo;
        elsif (rising_edge(clk)) then
            estado <= p_estado;
        end if;
    end process comb;

    sinc : process(rst, clk, p_estado, p_saddr, p_estim)
    begin
        if (rst = '1') then
            -- en reset ponemos todo a 0
            estado  <= reposo;
        elsif (rising_edge(clk)) then
            estado <= p_estado;
        end if;
    end process sinc;

end behavioral;

