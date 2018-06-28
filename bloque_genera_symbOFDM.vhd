library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity bloque_genera_symbOFDM is
    
    port(
        clk         : out std_logic;
        rst         : out std_logic;
        addr_symb   : in  std_logic_vector(10 downto 0);
        data_symb   : out std_logic_vector(23 downto 0);
        symb_ready  : out std_logic
        );

end bloque_genera_symbOFDM;
 
architecture behavior of bloque_genera_symbOFDM is 
 
     -- component declaration
    component bloque_2
        port(
            data_b2     : out std_logic_vector(23 downto 0);    -- [Re(23,12), Im(11,0)]
            valid_b2    : out std_logic;                        -- 1 if data_in is ready
            clk_b2      : out std_logic;
            rst_b2      : out std_logic
            );
        end component;
 
    -- component declaration for the unit under test (uut)
    component bloque_3
        port(
            data_in_b3  : in std_logic_vector(23 downto 0);    -- [Re(23,12), Im(11,0)]
            valid_in_b3 : in std_logic;                        -- 1 if data_in is ready
            clk_b3      : in std_logic;
            rst_b3      : in std_logic;
            data_out_b3 : out std_logic_vector(23 downto 0);    -- [Re(23,12), Im(11,0)]
            addr_out_b3 : out std_logic_vector(10 downto 0);    -- 11b = 2^(11) = 2408 addrs
            write_en_b3 : out std_logic;
            write_fin_b3 : out std_logic
            );
        end component;
    
    -- component declaration for the unit under test (uut)
    component bloque_4
    port(
        clka  : in  std_logic;
        wea   : in  std_logic_vector(0 downto 0);
        addra : in  std_logic_vector(10 downto 0);
        dina  : in  std_logic_vector(23 downto 0);
        clkb  : in  std_logic;
        addrb : in  std_logic_vector(10 downto 0);
        doutb : out  std_logic_vector(23 downto 0)
        );
    end component;
    
    -- Signals for Clock Manager
    -- We do not initializa rst
    -- and clk because they are out
    signal s_rst : std_logic;
    signal s_clk : std_logic;
    
    --inputs
    signal valid_b23 : std_logic := '0';
    signal data_b23 : std_logic_vector(23 downto 0);

    --outputs
    signal addr_b34 : std_logic_vector(10 downto 0);
    signal write_en_b34 : std_logic;
    signal data_b34 : std_logic_vector(23 downto 0);
    
begin
 
    -- instantiate the unit under test (uut)
    uut: bloque_4 
        port map (
            clka  => s_clk,
            wea(0) => write_en_b34,
            addra => addr_b34,
            dina  => data_b34,
            clkb  => s_clk,
            addrb => addr_symb,
            doutb => data_symb
            );
 
    -- instantiate the unit under test (uut)
    uut_bloque_3: bloque_3 
        port map (
            data_in_b3   => data_b23,
            valid_in_b3  => valid_b23,
            addr_out_b3  => addr_b34,
            data_out_b3  => data_b34,
            write_en_b3  => write_en_b34,
            clk_b3       => s_clk,
            rst_b3       => s_rst,
            write_fin_b3 => symb_ready
            );

    -- instantiate the unit under test (uut)
    uut_bloque_2 : bloque_2
        port map(
            data_b2     => data_b23,
            valid_b2    => valid_b23,
            clk_b2      => s_clk,
            rst_b2      => s_rst
            );
            
    -- Concurrent sequences
    rst <= s_rst;
    clk <= s_clk;


end;