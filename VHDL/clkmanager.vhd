-------------------------------------------------------------------------------
--! @file
--! @author Hipolito Guzman-Miranda
--! @brief Generates reset and clock for simulation purposes.
-------------------------------------------------------------------------------

--! Use IEEE standard definitions library
LIBRARY ieee;
--! Use std_logic* signal types
USE ieee.std_logic_1164.ALL;

--! @brief Generates a clock and reset for simulation purposes
--!
--! @details Generates a clock, \c clk,  with period \c CLK_PERIOD, and also a \c reset pulse, which
--! takes the value \c RST_ACTIVE_VALUE during \c RST_CYCLES (of the generated clock), and
--! after that time switches to the opposite value
entity clkmanager is
  generic (
    CLK_PERIOD       : time      := 10 ns;  --! Period of generated clock
    RST_ACTIVE_VALUE : std_logic := '0';    --! Reset polarity
    RST_CYCLES       : integer   := 10      --! Number of cycles that reset will be asserted at the beginning of the simulation
  );
  port (
    endsim : in  std_logic;  --! \c clk stops changing when endsim='1', which effectively stops the simulation
    clk    : out std_logic;  --! Generated clock
    rst    : out std_logic   --! Generated reset
  );
end clkmanager;

--! @brief Architecture is based on two different non-synthesizable processes to manage \c clk and \c rst
--!
--! @detailed A process is dedicated to toggle \c clk while \c endsim is not \c '1', and another one manages \c rst
architecture two_simulation_processes of clkmanager is

begin

  -- CLK_PERIOD must be positive and non-zero
  assert CLK_PERIOD > 0 ns
    report "clkmanager: CLK_PERIOD must be positive and non-zero"
    severity failure;

  -- RST_ACTIVE_VALUE must be either '0' or '1' (no other values supported)
  assert RST_ACTIVE_VALUE = '0' or RST_ACTIVE_VALUE = '1'
    report "clkmanager: RST_ACTIVE_VALUE must be either '0' or '1'"
    severity failure;

  -- RST_CYCLES must be positive and non-zero
  assert RST_CYCLES > 0
    report "clkmanager: RST_CYCLES must be a positive non-zero integer"
    severity failure;

  --! @brief Manage clk
  --!
  --! @details To stop the simulation without a failure message,
  --! stop toggling the clk when endsim = '1',
  clk_process: process
  begin
    if(endsim /= '1') then
      clk <= '1';
      wait for CLK_PERIOD/2;
      clk <= '0';
      wait for CLK_PERIOD/2;
    else
      wait;
    end if;
  end process;

  --! @brief Manage reset
  --!
  --! @details Sets rst to RST_ACTIVE_VALUE for CLK_PERIOD*RST_CYCLES
  --! and toggles it to NOT RST_ACTIVE_VALUE after that time
  rst_process: process
  begin		
    rst <= RST_ACTIVE_VALUE;
    wait for CLK_PERIOD*RST_CYCLES;
    rst <= NOT RST_ACTIVE_VALUE;
    wait;
  end process;

end two_simulation_processes;
