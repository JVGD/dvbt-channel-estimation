library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mi_paquete.all;

-- Interpolador que desde que se le da la seal
-- de datos validos a la entrada, tarda 3 ciclos
-- de reloj en sacar datos y los saca cada dos
-- ciclos
-- Latencia: 3
-- Trougput: 1dato/2clk

entity interpolador11 is
    port(
        clk         : in std_logic;
        rst         : in std_logic;
		finished	: out std_logic;
        sup         : in complex12;
        inf         : in complex12;
        valid       : in std_logic;
        estim       : out complex12; 
        estim_valid : out std_logic
		);
end interpolador11;

architecture Behavioral of interpolador11 is
    -- senales e inicializamos a 0
    -- seal estado y proximo estado para la FSM
    signal estado   : FSM_estado := reposo;
    signal p_estado : FSM_estado := reposo;
    
    -- seal direccion y p_direccion para la ROM
    signal saddr    : std_logic_vector(3 downto 0) := (others=>'0');
    signal p_saddr  : std_logic_vector(3 downto 0) := (others=>'0');
    
    -- seal de datos tomados de la ROM
    signal sdata    : std_logic_vector(7 downto 0) := (others=>'0');
    
    -- seal piloto superior y proximos piloto
    signal ssup     : complex12 := (re => (others=>'0'), im => (others=>'0'));
    signal p_ssup   : complex12 := (re => (others=>'0'), im => (others=>'0'));
    
    -- seal piloto inferior y proximos piloto
    signal sinf     : complex12 := (re => (others=>'0'), im => (others=>'0'));
    signal p_sinf   : complex12 := (re => (others=>'0'), im => (others=>'0'));
    
    -- seal p_estim resultado de la interpolacion
    signal p_estim  : complex12 := (re => (others=>'0'), im => (others=>'0'));
    
    -- Se declara sestim porque estim se necesita y no es inout
    signal sestim   : complex12 := (re => (others=>'0'), im => (others=>'0'));
	
	-- Seal para indicar si acepta nuevos datos (ha terminado la interpolacion) o no
    signal p_finished : std_logic := '1';
    
    -- componentes
    component miROM
    port(	
        clk : in std_logic;
        addr : in std_logic_vector(3 downto 0);
        data : out std_logic_vector(7 downto 0) );
    end component;
    
begin
    -- instanciacion del componente
    interpolador_ROM: miROM 
    port map(
        clk => clk,
        addr => saddr,
        data => sdata
    );
    
    -- proceso combinacional
    comb : process(estado, valid, ssup, sinf, sdata, saddr, inf, sup, p_estim, sestim)
    begin
        case estado is
            when reposo =>			
                -- si valid guardas seales y empezar FSM
                if (valid ='1') then
                    p_sinf <= inf;
                    p_ssup <= sup;
                    p_estado <= espera;
                    p_saddr <=(others=>'0');
					p_finished <= '0';
                else
                    p_estado <= reposo;
                    p_sinf <= sinf;
                    p_ssup <= ssup;
                    p_saddr <= saddr;
					p_finished <= '1';
                    -- no se puede inicializar a 0
                    -- porque sino nos cargamos el 
                    -- ultimo estim_valid porque coincidiria
                    -- con la condifion saddr /= 0 sin darse
                    -- la condicion de no haber interpolado
                end if;
                estim_valid <= '0'; 
                p_estim <= sestim;
                
            when espera =>
                p_estado <= interpola;
                p_saddr <= saddr;
                p_sinf <= sinf;
                p_ssup <= ssup;
                p_estim <= sestim;
                if (saddr /= "0000") then
                    -- prevenimos que se de un
                    -- valid en estado inicial
                    -- solo hacemos valid = 1
                    -- si ya hemos interpolado al
                    -- menos una vez
                    estim_valid <= '1';
                end if;
                
            when interpola =>
                -- multiplicamos & truncamos piloto sup e inf
                p_estim <= interpolar(sinf, ssup, sdata);
                if (saddr = "1011") then 
                    -- condicion para que no desborde
                    -- a addr en ROM que no tienen nada
                    p_estado <= reposo;
                    p_saddr <= (others=>'0'); 
                else
                    p_saddr <= std_logic_vector(unsigned(saddr) + 1);
                    p_estado <= espera;
                end if;
                estim_valid <= '0';
                p_sinf <= sinf;
                p_ssup <= ssup;
            
            when others =>
                p_estado <= reposo;
                p_saddr <= (others=>'0');
                p_estim.re<= (others=>'0');
                p_estim.im<= (others=>'0');
                p_sinf.re <= (others=>'0');
                p_sinf.im <= (others=>'0');
                p_ssup.re <= (others=>'0');
                p_ssup.im <= (others=>'0');
                
        end case;    
    end process comb;
    
    -- proceso secuencial
    sinc : process(rst, clk, p_estado, p_saddr, p_estim)
    begin
        if (rst = '1') then
            -- en reset ponemos todo a 0
            estado  <= reposo;
            saddr   <= (others=>'0');
            estim   <= (re => "000000000000", im => "000000000000"); 
            sestim  <= (re => "000000000000", im => "000000000000"); 
            sinf    <= (re => "000000000000", im => "000000000000"); 
            ssup    <= (re => "000000000000", im => "000000000000"); 
        elsif (rising_edge(clk)) then
            estado <= p_estado;
            saddr <= p_saddr;
            estim <= p_estim;
            sestim <= p_estim;
            sinf <= p_sinf;
            ssup <= p_ssup;
			finished <= p_finished;
        end if;
    end process sinc;

end Behavioral;

