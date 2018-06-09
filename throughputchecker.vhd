-------------------------------------------------------------------------------
--! @file
--! @author Hipolito Guzman-Miranda
--! @brief Checks that a specific valid signal is active with expected data rate
-------------------------------------------------------------------------------

--! Use IEEE standard definitions library;
LIBRARY ieee;
--! Use std_logic* signal types
USE ieee.std_logic_1164.ALL;
--! Allows use of arithmetical operations between integers and vectors
USE ieee.std_logic_arith.ALL;
--! Allows writing strings to lines and lines to files
use STD.textio.all;
--! Allows converting std_logic_vector(s) to strings (BIN, HEX, OCT)
use work.image_pkg.all;
--! Allows writing std_logic_vector(s) to line(s) in BIN, HEX, OCT and reading BIN, HEX, OCT vector(s) from line(s)
use ieee.std_logic_textio.all;
--! For print() function
use work.txt_util.all;

--! @brief Checks that data is valid with a specific data rate
--!
--! @detailed Checks that \c valid is active once each \c THROUGHPUT cycles.
--! Assumes \c valid is active high. Also reports the total number of
--! valid data seen when \c endsim is asserted. Note that this entity does not
--! need to know the actual value of the
--! data, only the value of the accompanying \c valid signal
entity throughputchecker is
  generic(
    SIMULATION_LABEL         : string  := "throughputchecker"; --! To separate messages from different instances in simulation
    DEBUG                    : boolean := false;               --! Print debug info (developers)
    THROUGHPUT               : integer := 0                    --! Wait cycles between valid data
    );
  port(
    clk    : in std_logic;                                --! Input data is aligned to this clock
    valid  : in std_logic;                                --! Active high, indicates data is valid
    endsim : in std_logic                                 --! Active high, tells the process that last data from datagen was sent
    );
end throughputchecker;

--! @brief Architecture compares input data rate with expected data rate
--!
--! @detailed After first valid data is seen, internally counts from 0 to
--! THROUGHPUT - 1 and checks if \c valid is \c '1' when expected
architecture compare_with_expected of throughputchecker is

  signal cycle_count    : integer := THROUGHPUT - 1 ;           --! Cycles until next expected data
  signal valid_count    : integer := 0;                         --! Valid data seen
  signal expected_valid : std_logic := '1';                     --! Expected value for 'valid'
  
begin
  
  assert THROUGHPUT > 0
    report "throughputchecker(" & SIMULATION_LABEL & "): THROUGHPUT must be a positive non-zero integer"
    severity failure;
 
  --! @brief Computes expected value for valid and reports an error if actual value is different
  --!
  --! @detailed Manages this by waiting for first valid and keeping an internal
  --! count. When endsim is asserted, reports total valid data seen
  expecting_valid : process

  begin

    -- wait until the first valid to start counting down
    while (valid /= '1') loop
      wait until rising_edge(clk);
    end loop;

    while (endsim /= '1') loop
    
      assert (valid = '0' OR valid = '1')
        report "throughputchecker(" & SIMULATION_LABEL & "): invalid value for valid, should only have '0' or '1'! (got '" & image(valid) & "')"
        severity failure;    
    
      if (valid /= expected_valid) then
        if (valid = '1' and expected_valid = '0') then
          report "throughputchecker(" & SIMULATION_LABEL & "): ERROR: data valid " & image(cycle_count + 1) & " cycles before expected" severity error;
        end if;
      end if;
      
      if (valid = '1') then
        valid_count <= valid_count + 1;
        print (DEBUG, "seen valid, valid_count: " & image(valid_count + 1));
      end if;

      if (cycle_count = 0) then
        cycle_count <= THROUGHPUT - 1;
        expected_valid <= '1';
      else
        cycle_count <= cycle_count - 1;
        expected_valid <= '0';
      end if;

      -- Wait for next rising edge of clk
      -- if endsim is asserted, do not wait for the clk edge, because it will never come
      wait until rising_edge(clk) or (endsim = '1');
      
    end loop;
  
    report "throughputchecker(" & SIMULATION_LABEL & "): test end. valid_count: " & image(valid_count) severity note;
    
    wait;
    
  end process;

end compare_with_expected;

