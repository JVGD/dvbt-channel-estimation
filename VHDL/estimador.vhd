library ieee;
use ieee.std_logic_1164.all;
use work.mi_paquete.all;
use ieee.numeric_std.all;

entity estimador is

    port(
        clk      : in std_logic;
        rst      : in std_logic;
        data_in  : in std_logic_vector(23 downto 0);    -- [Re(23,12), Im(11,0)]
        valid_in : in std_logic;                        -- 1 if data_in is ready
		ch_est   : out complex12;
		ch_valid : out std_logic
        );

end estimador;

architecture behavioral of estimador is

    -- Block for writing the data
	-- into the Dual Port RAM
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
    
    -- Dual Port RAM where OFDM Symbol (input
	-- data) is stored
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
	
	-- Block implementing the PRBS
    component bloque_5
		port(
			clk   : in std_logic;       --clock
			rst : in std_logic;         --reset
			Yout  : out std_logic;      --randomized output
			valid : out std_logic;
			enable : in std_logic
			);     
		end component; 
 
    -- Block for generating pilots out of the results
	-- of the PRBS and storing it in DPRAM of Block 7
    component bloque_6
		port(
			clk_b6       : in std_logic;
			rst_b6       : in std_logic;
			prbs_b6      : in std_logic;
			valid_b6     : in std_logic;
			data_out_b6  : out std_logic_vector(23 downto 0);
			addr_out_b6  : out std_logic_vector(10 downto 0);
			write_en_b6  : out std_logic;
			write_fin_b6 : out std_logic
			);
		end component;
    
	-- Dual Port RAM with the pilots generated
	-- per symbol (pilots are only in positions 1:12:1705)
	component bloque_7
		port(
			clka : in  std_logic;
			wea : in  std_logic_vector(0 downto 0);
			addra : in  std_logic_vector(10 downto 0);
			dina : in  std_logic_vector(23 downto 0);
			clkb : in  std_logic;
			addrb : in  std_logic_vector(10 downto 0);
			doutb : out  std_logic_vector(23 downto 0)
			);
		end component; 

    -- When DPRAMs with symbols and pilots are ready
	-- bloque 8 reads it and return the pilot_rx and 
	-- pilot_tx, although from pilot_tx it only 
	-- returns if it is positive or negative since 
	-- pilots_tx can only be +4/3 or -4/3
    component bloque_8
		port(
			clk         : in std_logic;
			rst         : in std_logic;
			addr_symb   : out std_logic_vector(10 downto 0);
			data_symb   : in std_logic_vector(23 downto 0);
			symb_ready  : in std_logic;
			addr_pilot  : out std_logic_vector(10 downto 0);
			data_pilot  : in std_logic_vector(23 downto 0);
			pilot_ready : in std_logic;
			pilot_rx 	: out complex12;
			pilot_tx_signed : out std_logic;
			pilot_txrx_fin : out std_logic;
			valid : out std_logic
			);
        end component;
	
	-- It divides pilot_rx by +/- 4/3 = +/-0.75
	-- depending on the pilot_signed (pilot_tx sign)
	-- It returns the estimated pilot pilot_est
	component bloque_9
		port(
			pilot_signed : in std_logic;
			pilot_rx : in complex12;
			pilot_est : out complex12
			);
		end component;
	
	-- It stores the equalized pilots in a DPRAM before
	-- the interpolator, so later the interpolator can
	-- fetch them properly
	component bloque_10
		port(
			clk         : in std_logic;
			rst         : in std_logic; 
			pilot_eq 	: in complex12;
			pilot_eq_valid : in std_logic;
			pilot_addr  : out std_logic_vector(7 downto 0);
			pilot_data  : out std_logic_vector(23 downto 0);
			pilot_data_valid : out std_logic;
			pilot_write_fin : out std_logic
			);
		end component;
	
	-- DPRAM for storing equalized pilots for the interpolator
	component bloque_11
		port(
			clka : in  std_logic;
			wea : in  std_logic_vector(0 downto 0);
			addra : in  std_logic_vector(7 downto 0);
			dina : in  std_logic_vector(23 downto 0);
			clkb : in  std_logic;
			addrb : in  std_logic_vector(7downto 0);
			doutb : out  std_logic_vector(23 downto 0)
			);
		end component; 

	-- It takes pilot superior and inferior from the DPRAM
	-- and feeds them to the interpolator iteratively
    component bloque_12
		port(
			clk : in std_logic;
			rst : in std_logic;
			ram_ready : in std_logic;
			data : in std_logic_vector(23 downto 0);
			addr : out std_logic_vector(7 downto 0);
			pilot_inf : out complex12;
			pilot_sup : out complex12;
			valid : out std_logic;
			interp_ready : in std_logic
			);
		end component;

	-- Interpolation of the pilots channel and outputing
	-- the results of the interpolation, this would be the
	-- channel estimated, not the channel equalized
	component interpolador11
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
		end component;
    
	-- Block that writes the pilots and the interpolated
	-- data in order to produce the estimated channel
	component bloque_14
		port(
			clk : in std_logic;
			rst : in std_logic;
			pilot_inf : in complex12;
			pilot_sup : in complex12;
			pilot_valid : in std_logic;
			interp_estim : in complex12;
			interp_valid : in std_logic;
			interp_fin : in std_logic;
			ch_est : out complex12;
			ch_valid : out std_logic
			);
		end component;
		
    -- Signals Block 3 to Block 4
    signal data_b34 : std_logic_vector(23 downto 0);
	signal addr_b34 : std_logic_vector(10 downto 0);
    signal write_en_b34 : std_logic;
    
	-- Signals Block 3 to Block 8		
	signal ready_symb_b38 : std_logic;

	-- Signals Block 4 to Block 8	
	signal data_symb_b48 : std_logic_vector(23 downto 0);
	signal addr_symb_b48 : std_logic_vector(10 downto 0);
    
    -- Signals Block 5 to Block 6	
    signal prbs_b56 : std_logic;
    signal valid_b56: std_logic;
    
    -- Signals Block 6 to Block 7	
    signal data_b67 : std_logic_vector(23 downto 0);
    signal addr_b67 : std_logic_vector(10 downto 0);
    signal write_en_b67 : std_logic;
	
	-- Signals Block 6 to Block 8
	signal ready_pilots_b68 : std_logic;
	
	-- Signals Block 7 to Block 8	
	signal data_pilots_b78 : std_logic_vector(23 downto 0);
	signal addr_pilots_b78 : std_logic_vector(10 downto 0);
	
	-- Signals Block 8 to Block 9
	signal pilot_tx_signed_b89 : std_logic;
	signal pilot_rx_b89 : complex12;
	
	-- Singal Block 8 to Block 10
	signal pilots_txrx_fin_b810 : std_logic;		-- This signal is not used
	signal valid_b810 : std_logic;
	
	-- Signal Block 9 to Block 10
	signal pilot_est_b910 : complex12;
	
	-- Signal Block 10 to Block 11
	signal pilot_addr_b1011 : std_logic_vector(7 downto 0);
	signal pilot_data_b1011 : std_logic_vector(23 downto 0);
	signal write_en_b1011 : std_logic;
	
	-- Signal Block 10 to Block 12
	signal pilot_write_fin_b1012 : std_logic := '0';
	
	-- Signal Block 11 to 12
	signal pilot_addr_b1112 : std_logic_vector(7 downto 0);
	signal pilot_data_b1112 : std_logic_vector(23 downto 0);
	
	-- Signal Block 12 to 13 and 14
	signal pilot_inf_b121314 : complex12;
	signal pilot_sup_b121314 : complex12;
	signal valid_b121314 : std_logic;
	signal interp_fin_b121314 : std_logic;
	
	-- Signal Block 13 to 14
	signal interp_estim_b1314 : complex12;
	signal interp_valid_b1314 : std_logic;
	

begin
	
    uut_bloque_3 : bloque_3 
        port map (
            data_in_b3   => data_in,
            valid_in_b3  => valid_in,
            addr_out_b3  => addr_b34,
            data_out_b3  => data_b34,
            write_en_b3  => write_en_b34,
            clk_b3       => clk,
            rst_b3       => rst,
            write_fin_b3 => ready_symb_b38
            );

    uut_bloque_4 : bloque_4 
        port map (
            clka  => clk,
            wea(0) => write_en_b34,
            addra => addr_b34,
            dina  => data_b34,
            clkb  => clk,
            addrb => addr_symb_b48,
            doutb => data_symb_b48
            );
            
	uut_bloque_5 : bloque_5
        port map(
            clk   => clk,
            rst => rst,
            Yout  => prbs_b56,
            valid => valid_b56,
			enable => valid_in
			);
			
	uut_bloque_6 : bloque_6 
        port map (
            clk_b6  => clk,
            rst_b6  => rst,
            prbs_b6 => prbs_b56,
            valid_b6 => valid_b56,
            data_out_b6 => data_b67,
            addr_out_b6 => addr_b67,
            write_en_b6 => write_en_b67,
            write_fin_b6 => ready_pilots_b68
            );
			
	uut_bloque_7 : bloque_7 
        port map (
            clka => clk,
            dina => data_b67,
            addra => addr_b67,
            wea(0) => write_en_b67,
            clkb => clk,
            addrb => addr_pilots_b78,
            doutb => data_pilots_b78
            );
 
    uut_bloque_8 : bloque_8 
        port map (
            clk => clk,
            rst => rst,
            addr_symb => addr_symb_b48,
            data_symb => data_symb_b48,
            symb_ready => ready_symb_b38,
            addr_pilot => addr_pilots_b78,
            data_pilot => data_pilots_b78,
            pilot_ready => ready_pilots_b68,
			pilot_tx_signed => pilot_tx_signed_b89,
			pilot_rx => pilot_rx_b89,
			pilot_txrx_fin => pilots_txrx_fin_b810,
			valid => valid_b810
			);
			
	uut_bloque_9 : bloque_9
		port map(
			pilot_signed => pilot_tx_signed_b89,
			pilot_rx => pilot_rx_b89,
			pilot_est => pilot_est_b910
			);
	
	uut_bloque_10 : bloque_10
		port map(
			clk => clk,
			rst => rst,
			pilot_eq => pilot_est_b910,
			pilot_eq_valid => valid_b810,
			pilot_addr => pilot_addr_b1011,
			pilot_data => pilot_data_b1011,
			pilot_data_valid => write_en_b1011,
			pilot_write_fin => pilot_write_fin_b1012
			);
	
	uut_bloque_11 : bloque_11
		port map(
			clka => clk,
			wea(0) =>  write_en_b1011,
			addra => pilot_addr_b1011,
			dina => pilot_data_b1011,
			clkb => clk,
			addrb => pilot_addr_b1112,
			doutb => pilot_data_b1112
			);
			
	uut_bloque_12: bloque_12 
		port map (
			clk => clk,
			rst => rst,
			ram_ready => pilot_write_fin_b1012,
			data => pilot_data_b1112,
			addr => pilot_addr_b1112,
			pilot_inf => pilot_inf_b121314,
			pilot_sup => pilot_sup_b121314,
			valid => valid_b121314,
			interp_ready => interp_fin_b121314
			);
			
	uut_bloque_13 : interpolador11 
		port map (
			clk => clk,
			rst => rst,
			finished => interp_fin_b121314,
			sup => pilot_sup_b121314,
			inf => pilot_inf_b121314,
			valid => valid_b121314,
			estim => interp_estim_b1314,
			estim_valid => interp_valid_b1314
			);	
			
	uut_bloque_14 : bloque_14
		port map(
			clk => clk,
			rst => rst,
			pilot_inf => pilot_inf_b121314,
			pilot_sup => pilot_sup_b121314,
			pilot_valid => valid_b121314,
			interp_estim => interp_estim_b1314,
			interp_valid => interp_valid_b1314,
			interp_fin => interp_fin_b121314,
			ch_est => ch_est,
			ch_valid => ch_valid
			);

end behavioral;

