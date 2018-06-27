library ieee;
use ieee.std_logic_1164.all;

entity tb_multcomplex_12 is
end tb_multcomplex_12;

architecture behavior of tb_multcomplex_12 is 

    component multcomplex_12
        port(
            aclk : in  std_logic;
            s_axis_a_tvalid : in  std_logic;
            s_axis_a_tdata : in  std_logic_vector(31 downto 0);
            s_axis_b_tvalid : in  std_logic;
            s_axis_b_tdata : in  std_logic_vector(31 downto 0);
            m_axis_dout_tvalid : out  std_logic;
            m_axis_dout_tdata : out  std_logic_vector(63 downto 0)
            );
    end component;


    --inputs
    signal aclk : std_logic := '0';
    signal s_axis_a_tvalid : std_logic := '0';
    signal s_axis_a_tdata : std_logic_vector(31 downto 0) := (others => '0');
    signal s_axis_b_tvalid : std_logic := '0';
    signal s_axis_b_tdata : std_logic_vector(31 downto 0) := (others => '0');

    --outputs
    signal m_axis_dout_tvalid : std_logic;
    signal m_axis_dout_tdata : std_logic_vector(63 downto 0);

    -- clock period definitions
    constant aclk_period : time := 10 ns;

begin

    -- instantiate the unit under test (uut)
    uut: multcomplex_12 
        port map (
            aclk => aclk,
            s_axis_a_tvalid => s_axis_a_tvalid,
            s_axis_a_tdata => s_axis_a_tdata,
            s_axis_b_tvalid => s_axis_b_tvalid,
            s_axis_b_tdata => s_axis_b_tdata,
            m_axis_dout_tvalid => m_axis_dout_tvalid,
            m_axis_dout_tdata => m_axis_dout_tdata
            );

    -- clock process definitions
    aclk_process :process
    begin
    aclk <= '0';
    wait for aclk_period/2;
    aclk <= '1';
    wait for aclk_period/2;
    end process;


    -- stimulus process
    stim_proc: process
    begin		
        -- hold reset state for 100 ns.
        wait for 100 ns;	

        wait for aclk_period*10;

        -- insert stimulus here 

        wait;
    end process;

end;
