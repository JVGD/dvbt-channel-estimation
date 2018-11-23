-------------------------------------------------------------------------------
--! @file
--! @author Hipolito Guzman-Miranda
--! @brief Compares signals with expected values in file
-------------------------------------------------------------------------------

--! Use IEEE standard definitions library
library ieee;
--! Use std_logic* signal types
use ieee.std_logic_1164.all;
--! Allows use of arithmetical operations between integers and vectors
use ieee.std_logic_arith.all;
-- Allows writing strings to lines and lines to files
use STD.textio.all; 
-- Allows converting std_logic_vector(s) to strings (BIN, HEX, OCT)
use work.image_pkg.all;
-- Allows writing std_logic_vector(s) to line(s) in BIN, HEX, OCT and reading BIN, HEX, OCT vector(s) from line(s)
use ieee.std_logic_textio.all;      
-- For print() function
use work.txt_util.all;               

--! @brief Compares input data with values in file and reports errors
--!
--! @detailed Reads file at \c GOLD_OUTPUT_FILE, expecting \c GOLD_OUTPUT_NIBBLES chars in
--! each line. Data is expected in hex format: 4 bits per character (nibble).
--! Reads input \c data and internally reorders it so it can compare
--! accumulated data with a complete line in \c GOLD_OUTPUT_FILE outputs it with a
--! width of DATA_WIDTH bits. \c data is only sampled when \c valid is active. If
--! \c VERBOSE is \c true, will report both correct (OK) data with erroneous
--! (ERROR) data 
entity datacompare is
  generic(
    SIMULATION_LABEL         : string  := "datacompare";                  --! Allow to separate messages from different instances in SIMULATION
    VERBOSE                  : boolean := false;                          --! Report correct data and not only erroneous data
    DEBUG                    : boolean := false;                          --! Print debug info (developers only)        
    GOLD_OUTPUT_FILE         : string  := "../test/datacompare_test.txt"; --! File where data is stored
    GOLD_OUTPUT_NIBBLES      : integer := 2;                              --! Maximum hex chars for each output data 
    DATA_WIDTH               : integer := 8                               --! Width of inout data
    );
  port(
    clk    : in std_logic;                                --! Expects input data aligned to this clock
    data   : in std_logic_vector (DATA_WIDTH-1 downto 0); --! Data to compare with data in file
    valid  : in std_logic;                                --! Active high, indicates data is valid
    endsim : in std_logic                                 --! Active high, tells the process to close its open files
    );
end datacompare;

--! @brief Architecture accumulates input data in a vector and compares with contents of file lines
architecture data_comparison of datacompare is

  constant NUM_CHUNKS : integer := 4*GOLD_OUTPUT_NIBBLES / DATA_WIDTH; --! Each line in output file equals to NUM_CHUNKS data of DATA_WIDTH

  signal received_data : integer := 0;
  
  --! Define this outside the process so we can check endfile(gold_file_pointer) in a concurrent assertion
  file gold_file_pointer    : text;
  shared variable gold_file_isopen : boolean := false;  -- It would be nice if file types had an 'isopen attribute :(
  
begin
  
  assert GOLD_OUTPUT_NIBBLES > 0
    report "datacompare(" & SIMULATION_LABEL & "): GOLD_OUTPUT_NIBBLES must be a positive non-zero integer"
    severity failure;  
  
  assert DATA_WIDTH > 0
    report "datacompare(" & SIMULATION_LABEL & "): DATA_WIDTH must be a positive non-zero integer"
    severity failure;
  
  assert 4*GOLD_OUTPUT_NIBBLES >= DATA_WIDTH
    report "datacompare(" & SIMULATION_LABEL & "): DATA_WIDTH (" & image(DATA_WIDTH) & ") bits must fit into GOLD_OUTPUT_NIBBLES nibbles (4*" & image(GOLD_OUTPUT_NIBBLES) & ") bits"
    severity failure;
  
  assert (4*GOLD_OUTPUT_NIBBLES) mod DATA_WIDTH = 0
    report "datacompare(" & SIMULATION_LABEL & "): An exact multiple of DATA_WIDTH (" & image(DATA_WIDTH) & ") must fit into GOLD_OUTPUT_NIBBLES nibbles (4*" & image(GOLD_OUTPUT_NIBBLES) & ") bits."
    severity failure;
    
  -- If endsim arrives while the file is still open something went wrong
  assert not (endsim = '1' and gold_file_isopen)
    report "datacompare(" & SIMULATION_LABEL & "): endsim asserted before expected, seen only " & image(received_data) & "valid data"
    severity failure; 
 
  --! @brief Reads the file line by line, accumulates data and compares
  --!
  --! @detailed Also reports errors and checks for unexpected conditions
  datacompare_read : process
    
    --file gold_file_pointer    : text; 
    variable current_line     : line;
    variable expected_data    : std_logic_vector (GOLD_OUTPUT_NIBBLES*4-1 downto 0); -- Data read from file
    variable current_data     : std_logic_vector (GOLD_OUTPUT_NIBBLES*4-1 downto 0); -- Data read from input
    variable chunk_idx        : integer range 0 to NUM_CHUNKS := 0;               -- Points to current data chunk in line
    variable error_count      : integer := 0;                                     -- Store differences between received and expected data
    variable correct_count    : integer := 0;                                     -- Store number of correct data

  begin
   
    print ("datacompare(" & SIMULATION_LABEL & "): NUM_CHUNKS: " & image(NUM_CHUNKS));
    print ("datacompare(" & SIMULATION_LABEL & "): opening gold_output file " & GOLD_OUTPUT_FILE);
    file_open(gold_file_pointer, GOLD_OUTPUT_FILE, READ_MODE);
    gold_file_isopen := true;

    while (not endfile(gold_file_pointer)) loop  
    
      print (DEBUG, "datacompare(" & SIMULATION_LABEL & "): reading line");
      readline (gold_file_pointer, current_line);         -- Read the whole line from the file

      -- Before converting line to std_logic_vector, assert that number of nibbles read matches expected
      -- Since a line is a pointer (technically an "access", in VHDL) to a string,
      -- current_line.all is a string, so check its length
      assert current_line.all'LENGTH = GOLD_OUTPUT_NIBBLES
        report "datagen: unexpected number of nibbles in gold output file, got " & image(current_line.all'LENGTH) & ", expected " & image(GOLD_OUTPUT_NIBBLES)
        severity failure;

      hread (current_line, expected_data);        -- Interpret the line as hex data and put it in a std_logic_vector
      
      while ((chunk_idx < NUM_CHUNKS)) loop
        wait until rising_edge(clk);
        if (valid = '1') then
          print (DEBUG,  "datacompare(" & SIMULATION_LABEL & "): chunk_idx: " & image(chunk_idx));
          current_data(DATA_WIDTH*(chunk_idx+1)-1 downto DATA_WIDTH*chunk_idx) := data; -- Put input data in the correct chunk           
          chunk_idx := chunk_idx + 1;
          received_data <= received_data + 1;
        end if;
      end loop;

      if (current_data /= expected_data) then
        report "datacompare(" & SIMULATION_LABEL & "): ERROR: received " & heximage (current_data) & ", expecting " & heximage (expected_data)
          severity error;
        error_count := error_count + 1;
      else
        if (VERBOSE = true) then
          report "datacompare(" & SIMULATION_LABEL & "): data OK, received " & heximage (current_data) & ", expecting " & heximage (expected_data) severity note;
        end if;
        correct_count := correct_count + 1;
      end if;
      
      chunk_idx := 0;
      
    end loop;
    
    file_close(gold_file_pointer);
    gold_file_isopen := false;
     
    wait until (falling_edge(clk) or (endsim='1'));
    
    print (VERBOSE,  "datacompare(" & SIMULATION_LABEL & "): " & image(received_data) & " data received");
    print (VERBOSE,  "datacompare(" & SIMULATION_LABEL & "): No more data in output file, closing it");
 
    wait until endsim='1';

    assert correct_count > 0
      report "datacompare(" & SIMULATION_LABEL & "): simulation finished but correct data is not > 0. correct data: " & image(correct_count) severity failure;

    report "datacompare(" & SIMULATION_LABEL & "): test end, errors: " & image(error_count) & "correct data: " & image(correct_count) severity note;

    wait;
    
  end process datacompare_read;

end data_comparison;

