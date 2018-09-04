-------------------------------------------------------------------------------
--! @file
--! @author Hipolito Guzman-Miranda
--! @brief Writes circuit output to file
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

--! @brief Writes circuit output data to file
--!
--! @detailed Creates (overwriting if it exists) a file at \c OUTPUT_FILE,
--! writing \c OUTPUT_NIBBLES chars in each line. Data will be written in hex
--! format: 4 bits per character (nibble). Reads \c DATA_WIDTH - bit input \c data
--! and internally reorders it to form complete lines. \c data is only sampled
--! when \c valid is active.
entity datawrite is
  generic(
    SIMULATION_LABEL    : string  := "datawrite";                    --! Allow to separate messages from different instances in SIMULATION
    VERBOSE             : boolean := false;                          --! Print more internal details
    DEBUG               : boolean := false;                          --! Print debug info (developers only)        
    OUTPUT_FILE         : string  := "./output/datawrite_test.txt";  --! File where data will be stored
    OUTPUT_NIBBLES      : integer := 2;                              --! Hex chars on each output line 
    DATA_WIDTH          : integer := 8                               --! Width of input data
    );
  port(
    clk    : in std_logic;                                --! Will sample input on rising_edge of this clock
    data   : in std_logic_vector (DATA_WIDTH-1 downto 0); --! Data to write to file
    valid  : in std_logic;                                --! Active high, indicates data is valid
    endsim : in std_logic                                 --! Active high, tells the process to close its open files
    );
end datawrite;

--! @brief Architecture accumulates input data in a vector which will be written to the output file
architecture pack_lines_and_write of datawrite is

  constant NUM_CHUNKS : integer := 4*OUTPUT_NIBBLES / DATA_WIDTH; --! Each line in output file equals to NUM_CHUNKS data of DATA_WIDTH

  signal received_data : integer := 0;
  
begin
  
  assert OUTPUT_NIBBLES > 0
    report "datawrite(" & SIMULATION_LABEL & "): OUTPUT_NIBBLES must be a positive non-zero integer"
    severity failure;  
  
  assert DATA_WIDTH > 0
    report "datawrite(" & SIMULATION_LABEL & "): DATA_WIDTH must be a positive non-zero integer"
    severity failure;
  
  assert 4*OUTPUT_NIBBLES >= DATA_WIDTH
    report "datawrite(" & SIMULATION_LABEL & "): DATA_WIDTH (" & image(DATA_WIDTH) & ") bits must fit into OUTPUT_NIBBLES nibbles (4*" & image(OUTPUT_NIBBLES) & ") bits"
    severity failure;
  
  assert (4*OUTPUT_NIBBLES) mod DATA_WIDTH = 0
    report "datawrite(" & SIMULATION_LABEL & "): An exact multiple of DATA_WIDTH (" & image(DATA_WIDTH) & ") must fit into OUTPUT_NIBBLES nibbles (4*" & image(OUTPUT_NIBBLES) & ") bits."
    severity failure;
    
  --! @brief Accumulates data to form a line, when line is complete it gets written to the output file
  --!
  --! @detailed Also reports errors and checks for unexpected conditions
  datawrite_read : process
    
    file file_pointer    : text; 
    variable current_line     : line;
    variable expected_data    : std_logic_vector (OUTPUT_NIBBLES*4-1 downto 0);   -- Data read from file
    variable current_data     : std_logic_vector (OUTPUT_NIBBLES*4-1 downto 0);   -- Data read from input
    variable chunk_idx        : integer range 0 to NUM_CHUNKS := 0;               -- Points to current data chunk in line
    variable error_count      : integer := 0;                                     -- Store differences between received and expected data
    variable correct_count    : integer := 0;                                     -- Store number of correct data

  begin
   
    print ("datawrite(" & SIMULATION_LABEL & "): NUM_CHUNKS: " & image(NUM_CHUNKS));
    print ("datawrite(" & SIMULATION_LABEL & "): opening output file " & OUTPUT_FILE);
    file_open(file_pointer, OUTPUT_FILE, WRITE_MODE);

    while (endsim /= '1') loop  
    
      print (DEBUG, "datawrite(" & SIMULATION_LABEL & "): composing line");

      while (chunk_idx < NUM_CHUNKS and endsim /= '1') loop
        wait until (rising_edge(clk) or endsim = '1');
        if (valid = '1') then
          print (DEBUG,  "datawrite(" & SIMULATION_LABEL & "): chunk_idx: " & image(chunk_idx));
          current_data(DATA_WIDTH*(chunk_idx+1)-1 downto DATA_WIDTH*chunk_idx) := data; -- Put input data in the correct chunk           
          chunk_idx := chunk_idx + 1;
          received_data <= received_data + 1;
        end if;
      end loop;

      if (chunk_idx /= NUM_CHUNKS and chunk_idx /= 0) then
        print ("datawrite(" & SIMULATION_LABEL & "): warning: endsim received whilst line not completed. (chunk_idx = " & image(chunk_idx) & "). Some data may be lost" );
      end if;

      -- Avoid writing twice the last line
      if (endsim /= '1') then
        print ("datawrite(" & SIMULATION_LABEL & "): writing line");
        hwrite(current_line, current_data);
        writeline(file_pointer, current_line);
      end if;

      current_data := (others => 'U');
      chunk_idx := 0;
      
    end loop;
   
    print (VERBOSE,  "datawrite(" & SIMULATION_LABEL & "): " & image(received_data) & " data received");
    print (VERBOSE,  "datawrite(" & SIMULATION_LABEL & "): Closing output file");
 
    file_close(file_pointer);
     
    wait;
    
  end process datawrite_read;

end pack_lines_and_write;

