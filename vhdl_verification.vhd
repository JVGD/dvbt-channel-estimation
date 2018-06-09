-------------------------------------------------------------------------------
--! @file
--! @author Hipolito Guzman-Miranda
--! @brief Common datatypes and component declarations
-------------------------------------------------------------------------------

--! Use IEEE standard definitions library
library IEEE;
--! Use std_logic* signal types
use IEEE.STD_LOGIC_1164.all;

--! @brief Common datatypes and component declarations
--!
--! 
package vhdl_verification is

  --! @brief Output of datagen when \c valid='0'
  --!
  --! @detailed This data type has the same possible values that a \c std_logic
  --! can take, but adding the value
  --! \c keep, which means "maintain last valid value"
  type datagen_invalid_data is (
    keep,            -- Keep previous valid value
    uninitialized,   -- 'U'
    unknown,         -- 'X'
    zero,            -- '0'
    one,             -- '1'
    high_impedance,  -- 'Z'
    weak_unknown,    -- 'W'
    weak_zero,       -- 'L'
    weak_one,        -- 'H'
    dont_care);      -- '-'

  COMPONENT clkmanager
    generic (
      CLK_PERIOD       : time      := 10 ns;
      RST_ACTIVE_VALUE : std_logic := '0';
      RST_CYCLES       : integer   := 10
    );
    port (
      endsim : in  std_logic;
      clk    : out std_logic;
      rst    : out std_logic
    );
  END COMPONENT;

  COMPONENT datawrite
    generic (
      SIMULATION_LABEL         : string  := "datawrite";
      VERBOSE                  : boolean := false;
      DEBUG                    : boolean := false;
      OUTPUT_FILE              : string  := "./out/datawrite_test.txt";
      OUTPUT_NIBBLES           : integer := 2;
      DATA_WIDTH               : integer := 8
      );
    port (
      clk    : in std_logic;
      data   : in std_logic_vector (DATA_WIDTH-1 downto 0);
      valid  : in std_logic;
      endsim : in std_logic
      );
  END COMPONENT;

  COMPONENT datacompare
    generic (
      SIMULATION_LABEL         : string  := "datacompare";
      VERBOSE                  : boolean := false;
      DEBUG                    : boolean := false;
      GOLD_OUTPUT_FILE         : string  := "../test/datagen_test.txt";
      GOLD_OUTPUT_NIBBLES      : integer := 2;
      DATA_WIDTH               : integer := 8
      );
    port (
      clk    : in std_logic;
      data   : in std_logic_vector (DATA_WIDTH-1 downto 0);
      valid  : in std_logic;
      endsim : in std_logic
      );
  END COMPONENT;

  COMPONENT datagen
    generic (
      VERBOSE                  : boolean := false;
      DEBUG                    : boolean := false;
      STIMULI_FILE             : string  := "../test/datagen_test.txt";
      STIMULI_NIBBLES          : integer := 2;
      DATA_WIDTH               : integer := 8;
      THROUGHPUT               : integer := 0;
      INVALID_DATA             : datagen_invalid_data := unknown;
      CYCLES_AFTER_LAST_VECTOR : integer := 10
      );
    port (
      clk       : in std_logic;
      can_write : in std_logic;
      data      : out std_logic_vector (DATA_WIDTH-1 downto 0);
      valid     : out std_logic;
      endsim    : out std_logic
      );
  END COMPONENT;

  COMPONENT throughputchecker
    generic (
      SIMULATION_LABEL         : string  := "throughputchecker";
      DEBUG                    : boolean := false;
      THROUGHPUT               : integer := 0
      );
    PORT (
      clk : IN  std_logic;
      valid : IN  std_logic;
      endsim : IN  std_logic
      );
  END COMPONENT;
  
end vhdl_verification;

--! @brief Package body is empty since there are no function definitions here
package body vhdl_verification is

end vhdl_verification;

