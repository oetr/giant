-----------------------------------------------------------------
-- 
-- Component name: sc_controller
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 09:20 06.01.2011
--
-- Description: Interface to ISO 7816 smartcards
--
-- Notes:
-- none
--  
-- Dependencies:
-- shift_register
--
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- common stuff
library work;
use work.defaults.all;

-- for Xilinx primitives
library UNISIM;
use UNISIM.vcomponents.all;

entity sc_controller is
	generic(
		-- clock period in ns (of input clock clk)
		CLK_PERIOD : positive
	);
	port( 
		-- standard inputs
		clk : in std_logic;
		reset : in std_logic;

		-- inputs
		
		-- enable/disable toggle (edge triggered), default is powered off
		switch_power : in std_logic;
		
		-- start transmission
		transmit : in std_logic;
		
		-- command to send to sc
		data_in : in byte;
		-- write enable for data_in (edge triggered)
		data_in_we : in std_logic;
		-- number of bytes in input fifo
		data_in_count : out byte;
		
		-- data output (data sent back from SC)
		data_out : out byte;
		-- number of bytes in output fifo
		data_out_count : out byte;
		-- read enable for data_out (edge triggered)
		data_out_re : in std_logic;
		
		-- status output, following bits are currently used
		-- Bit 0: 1 if powered, 0 if not powered
		-- Bit 1: 1 during power up
		-- Bit 2: 1 while sending data
		-- Bit 3: 1 while waiting for response
		-- Bit 4: 1 while decoding a response
		status : out byte;
		
		-- trigger output, rising edge after last bit sent
		data_sent_trigger : out std_logic;
		-- trigger output, rising edge when first bit sent
		data_sending_trigger : out std_logic;

		-- electrical interface to smartcard
		sc_v_cc_en : out std_logic;
		sc_io : inout std_logic;
		sc_rst : out std_logic;
		sc_clk : out std_logic
	);
end sc_controller;

architecture behavioral of sc_controller is
	-- constants

	-- length of isp_clk cycle in ns (default to 2 MHz)
	constant PERIOD_SCCLK : positive := 250;
	
	-- converted to ticks at CLK_PERIOD
	constant PERIOD_SCCLK_VAL : positive := PERIOD_SCCLK/CLK_PERIOD;
	constant BITS_PERIOD_SCCLK : positive := log2_ceil(PERIOD_SCCLK_VAL);

	-- length of T_B in ns (reset => 1 after clk active)
	constant T_B : positive := 400*500;
	constant T_B_VAL : positive := T_B/CLK_PERIOD;
	constant BITS_T_B : positive := log2_ceil(T_B_VAL);

	-- default etu parameters
	constant F_d : positive := 372;
	constant D_d : positive := 1;
	
	
	-- exponent of divider for rxtx_clk derived from sc_clk
	-- (defaults to 2 MHz/4 = 500 kHz)
	constant RXTX_CLK_DIV : positive := 2;
	
	-- ETU in ticks of RXTX_CLK 
	constant etu_d : positive := (F_d/D_d)/(2**RXTX_CLK_DIV);
	constant BITS_etu_d : positive := log2_ceil(etu_d);
	
	-- default timeout in etu ticks
	constant TIMEOUT_d : positive := 1500;--9600;
	constant TIMEOUT_BYTE_d : positive := 960;
	constant BITS_TIMEOUT_d : positive := log2_ceil(TIMEOUT_d);
	
	-- width of RX/TX registers (max. 256)
	constant RX_TX_WIDTH : positive := 128;
	
	-- internal state machine states
	type state_type is (S_OFF, S_POWER_UP, S_IDLE, S_SEND, S_WAIT_RESPONSE, S_READ, S_POWER_DOWN);
	
	-- components
	component shift_register is
		generic(
			WIDTH : positive
		);
		port( 
			clk : in std_logic;
			reset : in std_logic;
			d_in : in byte;
			w_en : in std_logic;
			count : out unsigned(log2_ceil(WIDTH)-1 downto 0);
			d_out : out byte;
			r_en : in std_logic
		);
	end component;
	
	component sc_rx is
		generic(
			BITS_ETU : positive;
			BITS_TIMEOUT : positive
		);
		port( 
			clk : in std_logic;
			reset : in std_logic;
			rx_clk : in std_logic;
			en : in std_logic;
			etu : in unsigned(BITS_ETU-1 downto 0);
			timeout : in unsigned(BITS_TIMEOUT-1 downto 0);
			timeout_next_byte : in unsigned(BITS_TIMEOUT-1 downto 0);
			serial_in : in std_logic;
			byte_out : out byte;
			byte_complete : out std_logic;
			parity_error : out std_logic;
			timed_out : out std_logic;
			sampled_bit : out std_logic
		);
	end component;
	
	component sc_tx is
		generic(
			BITS_ETU : positive
		);
		port( 
			clk : in std_logic;
			reset : in std_logic;
			tx_clk : in std_logic;
			etu : in unsigned(BITS_ETU-1 downto 0);
			transmit : in std_logic;
			byte_in : in byte;
			serial_out : inout std_logic;
			byte_complete : out std_logic	
		);
	end component;

	-- signals

	-- edge detection
	signal switch_power_prev : std_logic;
	signal sc_io_prev : std_logic;
	signal transmit_prev : std_logic;
	
	-- ISP clock divider counter
	signal sc_clk_counter : unsigned(BITS_PERIOD_SCCLK - 1 downto 0);
	signal sc_clk_int : std_logic;

	-- output shift register for isp data + output enable
	signal fifo_out_reset, fifo_out_we, fifo_out_re : std_logic;
	signal fifo_out_in : byte;
	signal fifo_out_count : unsigned(log2_ceil(RX_TX_WIDTH)-1 downto 0);
	
	-- rx/tx clock
	signal rxtx_clk : std_logic;
	signal rxtx_counter : unsigned(RXTX_CLK_DIV-1 downto 0);
	
	-- rx signals
	signal rx_reset, rx_en : std_logic;
	signal rx_etu : unsigned(BITS_ETU_d-1 downto 0);
	signal rx_timeout, rx_timeout_next_byte : unsigned(BITS_TIMEOUT_d-1 downto 0);
	signal rx_parity_error : std_logic;
	signal rx_timed_out, rx_timed_out_prev : std_logic;
	signal rx_sampled_bit : std_logic;
	
	-- tx signals
	signal tx_reset : std_logic;
	signal tx_etu : unsigned(BITS_ETU_d-1 downto 0);
	signal tx_byte_in : byte;
	signal tx_out : std_logic;
	signal tx_transmit, tx_transmit_next : std_logic;
	signal tx_byte_complete, tx_byte_complete_prev : std_logic;
	
	-- input shift register for data from uc + input enable
	signal fifo_in_reset, fifo_in_we, fifo_in_re, fifo_in_re_next : std_logic;
	signal fifo_in_out : byte;
	signal fifo_in_count : unsigned(log2_ceil(RX_TX_WIDTH)-1 downto 0);
	
	-- Power up/down counter
	signal power_ud_count, power_ud_count_next : unsigned(BITS_T_B-1 downto 0);

	-- FSM state
	signal state, state_next : state_type;

	-- Status register
	signal status_buf, status_next : byte;
	signal data_sent_trigger_buf, data_sent_trigger_next : std_logic;
	signal data_sending_trigger_set, data_sending_trigger_set_next, data_sending_trigger_reset : std_logic; 
begin

	-- components
	SC_RX_inst : sc_rx
	generic map(
		BITS_ETU => BITS_etu_d,
		BITS_TIMEOUT => BITS_TIMEOUT_d
	)
	port map( 
		clk => clk,
		reset => rx_reset,
		rx_clk => rxtx_clk,
		en => rx_en,
		etu => rx_etu,
		timeout => rx_timeout,
		timeout_next_byte => rx_timeout_next_byte,
		serial_in => sc_io,
		byte_out => fifo_out_in,
		byte_complete => fifo_out_we,
		parity_error => rx_parity_error,
		timed_out => rx_timed_out,
		sampled_bit => rx_sampled_bit
	);
	
	--rx_reset <= reset;
	rx_etu <= to_unsigned(etu_d, rx_etu'length);
	rx_timeout <= to_unsigned(TIMEOUT_d, rx_timeout'length);
	rx_timeout_next_byte <= to_unsigned(TIMEOUT_BYTE_d, rx_timeout_next_byte'length);
	
	SC_TX_inst : sc_tx
	generic map(
		BITS_ETU => BITS_etu_d
	)
	port map( 
		clk => clk,
		reset => tx_reset,
		tx_clk => rxtx_clk,
		etu => tx_etu,
		transmit => tx_transmit,
		byte_in => tx_byte_in,
		serial_out => tx_out,
		byte_complete => tx_byte_complete
	);
	
	sc_io <= tx_out;
	tx_byte_in <= fifo_in_out;
	tx_reset <= reset;
	tx_etu <= to_unsigned(etu_d, tx_etu'length);
	
	FIFO_IN : shift_register 
	generic map(
		WIDTH => RX_TX_WIDTH
	)
	port map( 
		clk => clk,
		reset => fifo_in_reset,
		d_in => data_in,
		w_en => fifo_in_we,
		count => fifo_in_count,
		d_out => fifo_in_out,
		r_en => fifo_in_re
	);
	
	fifo_in_we <= data_in_we;
	
	FIFO_OUT : shift_register 
	generic map(
		WIDTH => RX_TX_WIDTH
	)
	port map( 
		clk => clk,
		reset => fifo_out_reset,
		d_in => fifo_out_in,
		w_en => fifo_out_we,
		count => fifo_out_count,
		d_out => data_out,
		r_en => data_out_re
	);
	
	

	-- signals
	status <= status_buf;
	data_sent_trigger <= data_sent_trigger_buf;
	
	-- processes
	
	-- CLK divider to generate sc clock
	SC_CLK_GEN : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				sc_clk_counter <= to_unsigned(PERIOD_SCCLK_VAL/2 - 1, sc_clk_counter'length);
				sc_clk_int <= '0';
			else
				if sc_clk_counter = 0 then
					sc_clk_counter <= to_unsigned(PERIOD_SCCLK_VAL/2 - 1, sc_clk_counter'length);
					sc_clk_int <= not sc_clk_int;
				else
					sc_clk_counter <= sc_clk_counter - 1;
				end if;
			end if;
		end if;
	end process;
	
	-- CLK divider to generate rx/tx clock
	RXTX_CLK_GEN : process(sc_clk_int)
	begin
		if rising_edge(sc_clk_int) then
			if reset = '1' then
				rxtx_counter <= (others => '0');
				rxtx_clk <= '0';
				data_sending_trigger <= '0';
				data_sending_trigger_reset <= '0';
			else
				rxtx_counter <= rxtx_counter + 1;
				rxtx_clk <= rxtx_counter(RXTX_CLK_DIV-1);
				
				if data_sending_trigger_set = '1' then
					data_sending_trigger_reset <= '1';
					data_sending_trigger <= '1';
				else
					data_sending_trigger_reset <= '0';
					data_sending_trigger <= '0';
				end if;
			end if;
		end if;
	end process;
	
	MAIN : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				state <= S_OFF;
				
				status_buf <= (others => '0');
				power_ud_count <= (others => '0');
				data_out_count <= (others => '0');
				data_in_count <= (others => '0');
				data_sent_trigger_buf <= '0';
				data_sending_trigger_set <= '0';
				
				fifo_in_re <= '0';
				tx_transmit <= '0';

				switch_power_prev <= '0';
				sc_io_prev <= '0';
				transmit_prev <= '0';
				rx_timed_out_prev <= '0';
				tx_byte_complete_prev <= '0';
			else
				state <= state_next;
				
				status_buf(4 downto 0) <= status_next(4 downto 0);
				status_buf(5) <= fifo_in_re;
				status_buf(6) <= tx_transmit;
				status_buf(7) <= rx_sampled_bit;
				
				data_out_count(log2_ceil(RX_TX_WIDTH)-1 downto 0) <= std_logic_vector(fifo_out_count);
				data_out_count(data_out_count'length - 1 downto log2_ceil(RX_TX_WIDTH)) <= (others => '0');
				
				data_in_count(log2_ceil(RX_TX_WIDTH)-1 downto 0) <= std_logic_vector(fifo_in_count);
				data_in_count(data_in_count'length - 1 downto log2_ceil(RX_TX_WIDTH)) <= (others => '0');

				power_ud_count <= power_ud_count_next;
				fifo_in_re <= fifo_in_re_next;
				tx_transmit <= tx_transmit_next;
				data_sent_trigger_buf <= data_sent_trigger_next;
				data_sending_trigger_set <= data_sending_trigger_set_next;
				
				-- edge detection
				switch_power_prev <= switch_power;
				sc_io_prev <= sc_io;
				transmit_prev <= transmit;
				rx_timed_out_prev <= rx_timed_out;
				tx_byte_complete_prev <= tx_byte_complete;
			end if;
		end if;
	end process;
	
	-- FSM next state decoding
	NEXT_STATE_DECODE : process(state, sc_clk_int, switch_power, switch_power_prev, power_ud_count,
		status_buf, sc_io, sc_io_prev, transmit, transmit_prev, rx_timed_out, rx_timed_out_prev,
		fifo_in_count, tx_byte_complete, tx_byte_complete_prev, tx_transmit, fifo_in_re,
		data_sent_trigger_buf, data_sending_trigger_set, data_sending_trigger_reset)
	begin
		-- default is to stay in current state
		state_next <= state;
		
		-- default values
		sc_clk <= '0';
		sc_rst <= '1';
		sc_v_cc_en <= '1';
		fifo_in_reset <= '0';
		fifo_out_reset <= '0';
		fifo_in_re_next <= fifo_in_re;
		tx_transmit_next <= tx_transmit;
		rx_reset <= '0';
		rx_en <= '1';
		
		status_next <= status_buf;
		power_ud_count_next <= power_ud_count;
		data_sent_trigger_next <= data_sent_trigger_buf;
		data_sending_trigger_set_next <= data_sending_trigger_set;
		
		if data_sending_trigger_reset = '1' then
			data_sending_trigger_set_next <= '0';
		end if;

		case state is
			
			when S_OFF =>
				sc_rst <= '0';
				sc_v_cc_en <= '0';
				
				fifo_in_reset <= '1';
				fifo_out_reset <= '1';
				
				rx_reset <= '1';
				
				-- go to S_POWER_UP on rising edge on trigger
				if switch_power = '1' and switch_power_prev = '0' then
					state_next <= S_POWER_UP;
					
					status_next(0) <= '1';
					status_next(1) <= '1';
					power_ud_count_next <= to_unsigned(T_B_VAL, power_ud_count_next'length);
					data_sent_trigger_next <= '0';
				end if;

			when S_POWER_UP =>
				-- power up
				sc_rst <= '0';
				sc_clk <= sc_clk_int;
				data_sent_trigger_next <= '0';
				
				-- wait for ATR after T_B
				if power_ud_count = 0 then
					state_next <= S_WAIT_RESPONSE;
					status_next(1) <= '0';
					status_next(3) <= '1';
				else
					power_ud_count_next <= power_ud_count - 1;
				end if;

				
			when S_IDLE =>
				-- go to S_POWER_DOWN on rising edge on trigger
				if switch_power = '1' and switch_power_prev = '0' then
					state_next <= S_POWER_DOWN;
					status_next(0) <= '0';
				-- start to transmit
				elsif transmit = '1' and transmit_prev = '0' then
					state_next <= S_SEND;
					tx_transmit_next <= '1';
					fifo_in_re_next <= '1';
					status_next(2) <= '1';
					data_sending_trigger_set_next <= '1';
				else
					tx_transmit_next <= '0';
					fifo_in_re_next <= '0';
				end if;

				-- no trigger
				data_sent_trigger_next <= '0';
				
				-- clock active
				sc_clk <= sc_clk_int;
				
			when S_SEND => 
				-- send command
				
				-- clock active
				sc_clk <= sc_clk_int;
				
				-- receive disable
				-- FIXME: rx_en <= '0';
				
				-- start read when finished
				if tx_byte_complete = '1' and tx_byte_complete_prev = '0' then
					-- read next byte to output
					fifo_in_re_next <= '1';

					-- go to wait state if final byte transmitted
					if fifo_in_count = to_unsigned(0, fifo_in_count'length) then
						status_next(2) <= '0';
						status_next(3) <= '1';
						tx_transmit_next <= '0';
						data_sent_trigger_next <= '1';
						state_next <= S_WAIT_RESPONSE;
					else
						-- start transmission of next byte
						tx_transmit_next <= '1';
					end if;
				else
					fifo_in_re_next <= '0';
					tx_transmit_next <= '0';
				end if;
				
				rx_reset <= '1';
			
			when S_WAIT_RESPONSE => 
				-- wait for response
				
				-- clock active
				sc_clk <= sc_clk_int;
				
				-- no trigger
				--data_sent_trigger_next <= '0';

				-- start to read on falling edge of sc_io
				if sc_io = '0' and sc_io_prev = '1' then
					status_next(3) <= '0';
					status_next(4) <= '1';
					state_next <= S_READ;		
				-- timeout?
				elsif rx_timed_out = '1' and rx_timed_out_prev = '0' then
					status_next(3) <= '0';
					status_next(4) <= '0';
					state_next <= S_IDLE;
				end if;
				
			when S_READ => 
				-- decode response
				rx_en <= '1';
				
				-- clock active
				sc_clk <= sc_clk_int;
				
				-- no trigger
				data_sent_trigger_next <= '0';
				
				-- go to idle when finished
				if rx_timed_out = '1' and rx_timed_out_prev = '0' then
					status_next(4) <= '0';
					state_next <= S_IDLE;
				end if;
	
			when S_POWER_DOWN =>
				-- Power down sequence:
				status_next(0) <= '0';
				state_next <= S_OFF;
				
				-- no trigger
				data_sent_trigger_next <= '0';
				
		end case;
	end process;
end behavioral;