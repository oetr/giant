-----------------------------------------------------------------
-- This file is part of GIAnt, the Generic Implementation ANalysis Toolkit
--
-- Visit www.sourceforge.net/projects/giant/
--
-- Copyright (C) 2010 - 2011 David Oswald <david.oswald@rub.de>
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License version 3 as
-- published by the Free Software Foundation.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
-- General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, see http://www.gnu.org/licenses/.
-----------------------------------------------------------------

-----------------------------------------------------------------
-- 
-- Component name: io_controller
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 09:32 26.11.2010
--
-- Description: IO controller for register file
--
-- Notes:
-- none
--  
-- Dependencies:
--
--
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.defaults.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity io_controller is
	generic(
		WR_REG_COUNT : natural := 32;
		RD_REG_COUNT : natural := 32
	);
	port( 
		-- uC side clock
		clk_in : in std_logic;
		reset_in : in std_logic;
		
		-- FPGA side clock
		clk : in std_logic;
		reset : in std_logic;
			
		-- uC <-> FPGA interface
		uc_in_w_en : in std_logic;
		uc_out_r_en : in std_logic;
		uc_in_pin : in std_logic;
		uc_out_pin : out std_logic;
		
		-- register file
		register_file_readonly : in byte_vector(RD_REG_COUNT-1 downto 0);
		register_file_writable : out byte_vector(WR_REG_COUNT-1 downto 0);
		
		-- read/write event notification, generate rising edge, high for 
		-- 1 clk cycle when data has been written to/is read from the 
		-- respective register. Currently a one-hot encoding
		register_file_r : out std_logic_vector(RD_REG_COUNT+WR_REG_COUNT-1 downto 0);
		register_file_w : out std_logic_vector(RD_REG_COUNT+WR_REG_COUNT-1 downto 0)
	);
end io_controller;

architecture behavioral of io_controller is
	-- constants
	constant REG_FILE_LENGTH : integer := RD_REG_COUNT+WR_REG_COUNT;
	
	-- components
	component clock_domain_sync_1to8
		port (
			rst : in std_logic;
			wr_clk : in std_logic;
			rd_clk : in std_logic;
			din : in std_logic_vector(0 downto 0);
			wr_en : in std_logic;
			rd_en : in std_logic;
			dout : out std_logic_vector(7 downto 0);
			full : out std_logic;
			wr_ack : out std_logic;
			empty : out std_logic;
			valid : out std_logic
		);
	end component;
	
	component clock_domain_sync_8to1
		port (
			rst : in std_logic;
			wr_clk : in std_logic;
			rd_clk : in std_logic;
			din : in std_logic_vector(7 downto 0);
			wr_en : in std_logic;
			rd_en : in std_logic;
			dout : out std_logic_vector(0 downto 0);
			full : out std_logic;
			empty : out std_logic;
			valid : out std_logic
		);
	end component;
	
	-- Command byte
	signal command_byte : unsigned(7 downto 0);
	signal command_byte_next : unsigned(7 downto 0);
	alias command_rw : std_logic is command_byte(0);
	alias command_address: unsigned(6 downto 0) is command_byte(7 downto 1);
	
	-- clock sync FIFOs for i/o
	signal uc_in_data_synced : byte;
	signal uc_in_empty : std_logic;
	signal uc_in_empty_prev : std_logic;
	signal uc_in_valid : std_logic;
	signal uc_in_w_en_int : std_logic;
	signal uc_in_w_en_prev : std_logic;
	signal uc_in_r_en_int : std_logic;
	signal uc_out_data_synced : byte;
	signal uc_out_data_synced_next : byte;
	signal uc_out_empty : std_logic;
	signal uc_out_valid : std_logic;
	signal uc_out_w_en_int : std_logic;
	signal uc_out_w_en_int_next : std_logic;
	signal uc_out_r_en_int : std_logic;
	signal uc_out_r_en_prev : std_logic;
	
	-- state machine
	type state_type is (
		S_IDLE,
		S_COMMAND,
		S_READ,
		S_WRITE_GET_DATA,
		S_WRITE
	);
	
	signal state, state_next : state_type;
	
	signal register_file_writable_buf : byte_vector(WR_REG_COUNT-1 downto 0);
	signal register_file_writable_buf_next : byte_vector(WR_REG_COUNT-1 downto 0);
	signal register_file_w_buf : std_logic_vector(RD_REG_COUNT+WR_REG_COUNT-1 downto 0);
	signal register_file_w_buf_next : std_logic_vector(RD_REG_COUNT+WR_REG_COUNT-1 downto 0);
begin
	
	-- Input pin clock sync
	INPUT_CLOCK_SYNC_inst : clock_domain_sync_1to8
	port map (
		rst => reset_in,
		wr_clk => clk_in,
		rd_clk => clk,
		din(0) => uc_in_pin,
		wr_en => uc_in_w_en_int,
		rd_en => uc_in_r_en_int,
		dout => uc_in_data_synced,
		full => open,
		wr_ack => open,
		empty => uc_in_empty,
		valid => uc_in_valid
	);
	
	-- Output pin clock sync
	OUTPUT_CLOCK_SYNC_inst : clock_domain_sync_8to1
	port map (
		rst => reset,
		wr_clk => clk,
		rd_clk => clk_in,
		din => uc_out_data_synced,
		wr_en => uc_out_w_en_int,
		rd_en => uc_out_r_en_int,
		dout(0) => uc_out_pin,
		full => open,
		empty => uc_out_empty,
		valid => uc_out_valid
	);
	
	register_file_writable <= register_file_writable_buf;
	register_file_w <= register_file_w_buf;
	
	-- FSM next state decoding
	NEXT_STATE_DECODE : process(state, uc_in_empty, uc_in_empty_prev,
		command_byte, uc_in_data_synced, uc_in_valid, register_file_writable_buf,
		uc_out_data_synced, register_file_readonly)
	begin
		-- default is to stay in current state
		state_next <= state;
		
		-- default values
		uc_in_r_en_int <= '0';
		uc_out_w_en_int_next <= '0';
		command_byte_next <= command_byte;
		uc_out_data_synced_next <= uc_out_data_synced;
		register_file_writable_buf_next <= register_file_writable_buf;
		register_file_w_buf_next <= (others => '0');
		register_file_r <= (others => '0');
		
		case state is
			when S_IDLE =>
				-- Falling edge on input valid (incoming command byte)
				if uc_in_empty = '0' and uc_in_empty_prev = '1' then
					-- Read and interpret command byte
					uc_in_r_en_int <= '1';
					state_next <= S_COMMAND;
				end if;
				
			when S_COMMAND =>
				if uc_in_valid = '1' then
					command_byte_next <= unsigned(uc_in_data_synced);
					
					-- write operation
					if uc_in_data_synced(0) = '1' then
						state_next <= S_WRITE_GET_DATA;
					-- read operation
					else
						state_next <= S_READ;
					end if;
					
				end if;
				
			when S_READ =>
				if command_address < to_unsigned(RD_REG_COUNT, command_address'length) then
					uc_out_data_synced_next <= register_file_readonly(to_integer(command_address));
				else
					uc_out_data_synced_next <= register_file_writable_buf(to_integer(command_address) - RD_REG_COUNT);
				end if;
				
				uc_out_w_en_int_next <= '1';
				register_file_r(to_integer(command_address)) <= '1';
				
				state_next <= S_IDLE;
			
			when S_WRITE_GET_DATA =>
				if uc_in_empty = '0' then
					-- issue read, go to write state
					uc_in_r_en_int <= '1';
					state_next <= S_WRITE;
				end if;
				
			when S_WRITE =>
				if command_address >= to_unsigned(RD_REG_COUNT, command_address'length) then
					register_file_writable_buf_next(to_integer(command_address) - RD_REG_COUNT) <= uc_in_data_synced;
					register_file_w_buf_next(to_integer(command_address)) <= '1';
				end if;
				
				state_next <= S_IDLE;
				
		end case;
	end process;
	
	-- state register update
	STATE_REG: process (clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				state <= S_IDLE;
				
				uc_in_empty_prev <= '1';
				command_byte <= (others => '0');
				register_file_writable_buf <= (others => (others => '0'));
				register_file_w_buf <= (others => '0');
				uc_out_data_synced <= (others => '0');
				uc_out_w_en_int <= '0';
			else
				state <= state_next;
				
				register_file_writable_buf <= register_file_writable_buf_next;
				register_file_w_buf <= register_file_w_buf_next;
				uc_in_empty_prev <= uc_in_empty;
				command_byte <= command_byte_next;
				uc_out_data_synced <= uc_out_data_synced_next;
				uc_out_w_en_int <= uc_out_w_en_int_next;
			end if;
		end if;
	end process;
	
	-- Input FIFO interface (convert rising edge on w_en/r_en to
	-- single high cycle @ 48 MHz)
	PULSE_IO_READ_WRITE : process(clk_in)
	begin
		if rising_edge(clk_in) then
			if reset_in = '1' then
				uc_in_w_en_prev <= '0';
				uc_in_w_en_int <= '0';
				uc_out_r_en_prev <= '0';
				uc_out_r_en_int <= '0';
			else
				uc_in_w_en_prev <= uc_in_w_en;
				uc_out_r_en_prev <= uc_out_r_en;
				
				-- w_en_int goes high for exactly one clock cycle if 
				-- rising edge on external pin
				if uc_in_w_en = '1' and uc_in_w_en_prev = '0' then
					uc_in_w_en_int <= '1';
				else
					uc_in_w_en_int <= '0';
				end if;
				
				if uc_out_r_en = '1' and uc_out_r_en_prev = '0' then
					uc_out_r_en_int <= '1';
				else
					uc_out_r_en_int <= '0';
				end if;
			end if;
		end if;
	end process;
	
end behavioral;
