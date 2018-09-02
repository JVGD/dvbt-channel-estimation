-------------------------------------------------------------------------------
--! @file
--! @author Hipolito Guzman-Miranda
--! @brief Generates stimuli from a file
-------------------------------------------------------------------------------

--! Use IEEE standard definitions library
library ieee;
--! Use std_logic* signal types
use ieee.std_logic_1164.ALL;
--! Allows use of arithmetical operations between integers and vectors
use ieee.std_logic_arith.ALL;
--! Allows converting std_logic_vector(s) to strings (BIN, HEX, OCT)
use work.image_pkg.all;
--! Allows writing strings to lines and lines to files
use STD.textio.all;
--! Allows writing std_logic_vector(s) to line(s) in BIN, HEX, OCT and reading BIN, HEX, OCT vector(s) from line(s)
use ieee.std_logic_textio.all;
--! For print() function
use work.txt_util.all;
--! For datagen_invalid_data definition
use work.vhdl_verification.all;

--! @brief Reads stimuli from file and outputs it with specified format
--!
--! @detailed Reads file at STIMULI_FILE, expecting STIMULI_NIBBLES chars in
--! each line. Data is expected in hex format: 4 bits per character (nibble).
--! Reads the data and outputs it with a width of DATA_WIDTH bits, asserting
--! valid='1' when a new data is available. Outputs a new data each THROUGHPUT
--! cycles, unless can_write='0'. When valid='0', output bits are set to
--! INVALID_DATA. After last data in STIMULI_FILE has been output, waits for
--! CYCLES_AFTER_LAST_VECTOR clk cycles and afterwards asserts endsim.
entity datagen is
  generic(
    VERBOSE                  : boolean := false;                      --! Print more internal details
    DEBUG                    : boolean := false;                      --! Print debug info (developers only)
    STIMULI_FILE             : string  := "../test/datagen_test.txt"; --! File where data is stored
    STIMULI_NIBBLES          : integer := 2;                          --! Maximum hex chars for each input data 
    DATA_WIDTH               : integer := 8;                          --! Width of generated data
    THROUGHPUT               : integer := 0;                          --! Output 1 valid data each THROUGHPUT cycles
    INVALID_DATA             : datagen_invalid_data := unknown;       --! Output value when data is not valid
    CYCLES_AFTER_LAST_VECTOR : integer := 10                          --! Number of cycles between last data and assertion of endsim
    );
  port(
    clk       : in std_logic;                                 --! Align generated data to this clock
    can_write : in std_logic;                                 --! Active high, tells datagen it can assert valid. Use for control-flow
    data      : out std_logic_vector (DATA_WIDTH-1 downto 0); --! Generated data
    valid     : out std_logic;                                --! Active high, indicates data is valid
    endsim    : out std_logic                                 --! Active high, tells the other simulation processes to close their open files
    );
end datagen;

--! Architecture reads file lines and slices it into chunks of size \c DATA_WIDTH
architecture data_generation of datagen is

  constant NUM_CHUNKS : integer := 4*STIMULI_NIBBLES / DATA_WIDTH;   --! Each line in input file equals to NUM_CHUNK data of DATA_WIDTH
  
  signal cycle_count     : integer := 0;                             --! Cycle counter
  signal sent_data       : integer := 0;                             --! Data sent to output
  signal last_valid_data : std_logic_vector (DATA_WIDTH-1 downto 0); --! Last data when valid was '1'
  signal invalid_output  : std_logic_vector (DATA_WIDTH-1 downto 0); --! Output value when data_valid = '0' 
 
begin

  print ("CYCLES_AFTER_LAST_VECTOR: " & image(CYCLES_AFTER_LAST_VECTOR));
  
  assert STIMULI_NIBBLES > 0
    report "datagen: STIMULI_NIBBLES must be a positive non-zero integer"
    severity failure;  
  
  assert DATA_WIDTH > 0
    report "datagen: DATA_WIDTH must be a positive non-zero integer"
    severity failure;
  
  assert THROUGHPUT > 0
    report "datagen: THROUGHPUT must be a positive non-zero integer"
    severity failure;	 
  
  assert 4*STIMULI_NIBBLES >= DATA_WIDTH
    report "datagen: DATA_WIDTH (" & image(DATA_WIDTH) & ") bits must fit into STIMULI_NIBBLES nibbles (4*" & image(STIMULI_NIBBLES) & ") bits"
    severity failure;
  
  assert (4*STIMULI_NIBBLES) mod DATA_WIDTH = 0
    report "datagen: An exact multiple of DATA_WIDTH (" & image(DATA_WIDTH) & ") must fit into STIMULI_NIBBLES nibbles (4*" & image(STIMULI_NIBBLES) & ") bits."
    severity failure;

  assert sent_data >= 0
    report "datagen: sent_data is negative (" & image(sent_data) & "). Aborting."
    severity failure;

  --! @brief Manage data generation from data in STIMULI_FILE
  datagen_read : process
    
    file file_pointer         : text;                                            --! File pointer
    variable current_line     : line;                                            --! Last line read from file
    variable current_hex_data : std_logic_vector (STIMULI_NIBBLES*4-1 downto 0); --! Last line read, converted to hex data
    variable chunk_idx        : integer range 0 to NUM_CHUNKS := 0;              --! Points to current data chunk in line
    variable cycles_to_wait   : integer := THROUGHPUT - 1;                       --! Cycles to wait before outputting next data

  begin
    
    assert cycles_to_wait >= 0
      report "datagen: cycles_to_wait is negative (" & image(cycles_to_wait) &  "). Aborting."
      severity failure;
    
    endsim <= '0';
    print ("datagen: NUM_CHUNKS: " & image(NUM_CHUNKS));
    print ("datagen: opening input file" & STIMULI_FILE);
    file_open(file_pointer, STIMULI_FILE, READ_MODE);
    
	-- Before doing nothing everything is set
	-- to 0 and data not valid
	data <= (others=>'0');
	last_valid_data <= (others=>'0');
	valid <= '0';
    wait until rising_edge(clk); -- do nothing until first valid clock event
    
    while (not endfile(file_pointer)) loop
      
      print (DEBUG,  "datagen: reading line");
      readline (file_pointer, current_line);         -- Read the whole line from the file

      -- Before converting line to std_logic_vector, assert that number of nibbles read matches expected
      -- Since a line is a pointer (technically an "access", in VHDL) to a string,
      -- current_line.all is a string, so check its length
      assert current_line.all'LENGTH = STIMULI_NIBBLES
        report "datagen: unexpected number of nibbles in stimuli file, got " & image(current_line.all'LENGTH) & ", expected " & image(STIMULI_NIBBLES)
        severity failure;

      hread (current_line, current_hex_data);        -- Interpret the line as hex data and put it in a std_logic_vector
      
      while (chunk_idx < NUM_CHUNKS) loop
        print (DEBUG,  "datagen: chunk_idx: " & image(chunk_idx));
        
        while (cycles_to_wait > 0) loop
          print (DEBUG,  "datagen: cycles_to_wait: " & image(cycles_to_wait));
          cycles_to_wait := cycles_to_wait - 1;
          data <= invalid_output;                   -- by default, data is NOT valid
          valid <= '0';
          cycle_count <= cycle_count + 1;
          wait until rising_edge(clk);
        end loop;
      
        if (can_write /= '1') then
          wait until can_write = '1';
        end if;

        cycles_to_wait := THROUGHPUT - 1;			 
        data <= current_hex_data(DATA_WIDTH*(chunk_idx+1)-1 downto DATA_WIDTH*chunk_idx); --Get DATA_WIDTH bits from current_hex_data into data
        last_valid_data <= current_hex_data(DATA_WIDTH*(chunk_idx+1)-1 downto DATA_WIDTH*chunk_idx); --Store also, for the case where we have to output last_valid_data when valid='0'
        valid <= '1';
        cycle_count <= cycle_count + 1;
        sent_data <= sent_data + 1;
        chunk_idx := chunk_idx + 1;		 
        wait until rising_edge(clk);

      end loop;
      chunk_idx := 0;
    end loop;	  
    
    print ("datagen: " & image(sent_data) & " data sent, closing input file");
    file_close(file_pointer);

    cycles_to_wait := CYCLES_AFTER_LAST_VECTOR;
    while (cycles_to_wait > 0) loop
      cycles_to_wait := cycles_to_wait - 1;
      data <= invalid_output;                      -- when finished, data is NOT valid
      valid <= '0';
      cycle_count <= cycle_count + 1;
      wait until rising_edge(clk);
    end loop;
    
    report "datagen: asserting endsim. cycle_count: " & image(cycle_count) severity note;
    endsim <= '1';
    wait;
    
  end process datagen_read;

  --! @brief Determine what will be the output when data_valid = '0'
  --!
  --! @details
  invalid_data_behavior: process (last_valid_data)
  begin

    case INVALID_DATA is
      when keep           => invalid_output <= last_valid_data;
      when uninitialized  => invalid_output <= (others => 'U');
      when unknown        => invalid_output <= (others => 'X');
      when zero           => invalid_output <= (others => '0');
      when one            => invalid_output <= (others => '1');
      when high_impedance => invalid_output <= (others => 'Z');
      when weak_unknown   => invalid_output <= (others => 'W');
      when weak_zero      => invalid_output <= (others => 'L');
      when weak_one       => invalid_output <= (others => 'H');
      when dont_care      => invalid_output <= (others => '-');
    end case;

  end process invalid_data_behavior;

end data_generation;

