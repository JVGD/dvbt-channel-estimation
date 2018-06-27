library ieee;
use ieee.std_logic_1164.all;

entity tb_divN is
end tb_divN;

architecture foo of tb_divN is
    
    component divN
        generic(
            N : integer := 12
            );
        port(
            y : in std_logic_vector(N-1 downto 0);
            x : in std_logic_vector(N-1 downto 0);
            z : out std_logic_vector(N-1 downto 0)
            );
    end component;


    signal N: integer := 6;
    signal x: std_logic_vector(N-1 downto 0);
    signal y: std_logic_vector(N-1 downto 0);
    signal z: std_logic_vector(N-1 downto 0);
    
begin


    uut_divN : divN
        generic map(
            N => 6
            )
        port map (
            y => y,
            x => x,
            z => z
        );

    stim : process 
    begin
        wait for 10 ns;
        y <= "011000";
        x <= "010000";
        wait for 10 ns;
        wait;      
    end process;

end architecture;
