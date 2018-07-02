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
-- Component name: timing_controller_waveform_waveform
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 090412
--
-- Description: Controller unit for generating fault signal from
--              trigger with configurable output waveform, based on 
--              BRAM to create multiple pulses
--
-- Notes:
-- none
--  
-- Dependencies:
-- serial_to_parallel
-- parallel_to_serial
-- waveform_ram
--
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timing_controller_waveform is
	generic( 
	    -- width of internal registers for time counters in bit
		TIME_REGISTER_WIDTH : positive
	);
	port( 
		-- standard inputs
		clk : in std_logic;
		ce : in std_logic;
		reset : in std_logic;
		
		-- inputs
		arm : in std_logic;
		trigger : in std_logic;
		
		-- status outputs
		armed : out std_logic;
		ready : out std_logic;
		
		-- waveform output
		inject_fault : out std_logic;
		
		-- config data bus adress register
		addr : in std_logic_vector(9 downto 0);
		
		-- data bus control (write enable)
		w_en : in std_logic;
		
		-- config write data bus
		d_in : in std_logic_vector(7 downto 0);
		
		-- config read data bus
		d_out : out std_logic_vector(7 downto 0)
		
		
	);
end timing_controller_waveform;

architecture behavioral of timing_controller_waveform is
	-- constants & types
	
	-- internal state machine states
	type state_type is (IDLE, ARMING_LOAD_CONFIG,
		ARMING_LOAD_DELAY, ARM_DONE, TRIGGERED, 
		TRIGGERED_COUNTING, INJECTED, INJECTED_COUNTING);
	
	-- integer constants
	constant ZERO : unsigned(TIME_REGISTER_WIDTH-1 downto 0) := (others => '0');
	constant ONE : unsigned(TIME_REGISTER_WIDTH-1 downto 0) := (others => '0');
	
	-- width of internal timer registers in byte
	constant WIDTH_BYTES : positive := TIME_REGISTER_WIDTH/8;
	
	component waveform_ram
		port (
			clka: in std_logic;
			wea: in std_logic_vector(0 downto 0);
			addra: in std_logic_vector(7 downto 0);
			dina: in std_logic_vector(31 downto 0);
			douta: out std_logic_vector(31 downto 0);
			clkb: in std_logic;
			web: in std_logic_vector(0 downto 0);
			addrb: in std_logic_vector(9 downto 0);
			dinb: in std_logic_vector(7 downto 0);
			doutb: out std_logic_vector(7 downto 0)
		);
	end component;

	-- Synplicity black box declaration
	attribute syn_black_box : boolean;
	attribute syn_black_box of waveform_ram: component is true;
	
	-- signals
	
	signal arm_prev, trigger_prev : std_logic;
	-- FSM state
	signal state, next_state : state_type;
	
	-- Target for R/W operations
	signal a_reg : std_logic_vector(7 downto 0);
	signal in_data, out_data : std_logic_vector(31 downto 0);
	signal w_en_a : std_logic;
	
	-- instruction pointer in waveform_ram
	signal instr_pointer, instr_pointer_next, instr_count, instr_count_next : unsigned(7 downto 0);
	
	-- FSM counter
	signal count : unsigned(TIME_REGISTER_WIDTH-1 downto 0);
	signal count_reset : std_logic;
	
	-- Configuration registers
	signal pulse_delay_i, pulse_length_i, pulse_delay_i_next, pulse_length_i_next : unsigned(TIME_REGISTER_WIDTH-1 downto 0);
	signal polarity_i, polarity_i_next : std_logic := '0';
begin
	-- component mapping
	
	-- storage for pulse form, memory layout is:
	-- 0: 32 Bit Config:
	--  bit 0: 1 Bit pulse polarity: 0 for positive pulses (active high), 1 for negatives pulse
	--  15 Bit reserved
	--  bit 16 ... 23: 8 Bit end address of instructions, i.e., 4 for 1 pulse
	--  8 Bit reserved
	--
	-- 1: 32 Bit reserved
	-- 2: 32 Bit Delay Pulse 1
	-- 3: 32 Bit Length Pulse 1
	--- ...
	WAVE_RAM : waveform_ram
	port map (
		clka => clk,
		wea(0) => w_en_a,
		addra => a_reg,
		dina => in_data,
		douta => out_data,
		clkb => clk,
		web(0) => w_en,
		addrb => addr,
		dinb => d_in,
		doutb => d_out
	);
	
	w_en_a <= '0';
	
	-- signal mapping

	-- processes
	
	-- counter
	COUNTER : process(clk) 
	begin
		if rising_edge(clk) then
			if reset = '1' then
				count <= (others => '0');
			elsif ce = '1' then
				if count_reset = '1' then
					count <= ZERO;
				else
					count <= count+1;
				end if;
			end if;
		end if;
	end process;
	
	-- FSM synchronization and buffered signals
	SYNC : process(clk) 
	begin
		if rising_edge(clk) then
			if reset = '1' then
				state <= IDLE;
				pulse_delay_i <= (others => '0');
				pulse_length_i <= (others => '0');
				polarity_i <= '0';
				instr_pointer <= (others => '0');
				instr_count <= (others => '0');
				trigger_prev <= trigger;
				arm_prev <= arm;
			elsif ce = '1' then
				state <= next_state;
				pulse_delay_i <= pulse_delay_i_next;
				pulse_length_i <= pulse_length_i_next;
				polarity_i <= polarity_i_next;
				instr_pointer <= instr_pointer_next;
				instr_count <= instr_count_next;
				trigger_prev <= trigger;
				arm_prev <= arm;
			end if;
		end if;
	end process;
	
	-- FSM next state decoding
	NEXT_STATE_DECODE : process(state, arm, trigger, count, pulse_delay_i, pulse_length_i, polarity_i, 
		a_reg, in_data, instr_pointer, instr_count, out_data, arm_prev, trigger_prev)
	begin
		-- default is to stay in current state
		next_state <= state;
		
		-- default values
		pulse_delay_i_next <= pulse_delay_i;
		pulse_length_i_next <= pulse_length_i;
		polarity_i_next <= polarity_i;
		ready <= '1';
		armed <= '0';
		
		inject_fault <= polarity_i;
		count_reset <= '0';
		instr_pointer_next <= instr_pointer;
		instr_count_next <= instr_count;
		a_reg <= (others => '0');

		case state is
			when IDLE =>
				count_reset <= '1';
			    
			    if (arm = '1' and arm_prev = '0') then
					-- load config register
					a_reg <= (others => '0');
					-- prepare instruction pointer
					instr_pointer_next <= to_unsigned(3, instr_pointer'length);
					
					next_state <= ARMING_LOAD_CONFIG;
				end if;	
			when ARMING_LOAD_CONFIG =>
				-- store config register values
				polarity_i_next <= out_data(0);
				instr_count_next <= unsigned(out_data(23 downto 16));
				
				-- fetch delay value
				a_reg <= std_logic_vector(to_unsigned(2, instr_pointer'length));
				
				ready <= '0';
				next_state <= ARMING_LOAD_DELAY;
			when ARMING_LOAD_DELAY =>
				-- store delay register values
				pulse_delay_i_next <= unsigned(out_data);
				
				-- fetch width value
				a_reg <= std_logic_vector(to_unsigned(3, instr_pointer'length));
				
				ready <= '0';
				next_state <= ARM_DONE;
			when ARM_DONE =>
			    -- check for trigger becoming valid
				if (trigger = '1' and trigger_prev = '0') then
					next_state <= TRIGGERED;
				end if;
				
				-- fetch width value
				a_reg <= std_logic_vector(to_unsigned(3, instr_pointer'length));
				
				-- store length register values
				pulse_length_i_next <= unsigned(out_data);
				
				armed <= '1';
				ready <= '0';
			when TRIGGERED =>	
                -- wait until pulse delay reached	
				if count = pulse_delay_i then
					next_state <= INJECTED;
				else
					next_state <= TRIGGERED_COUNTING;
				end if;

				count_reset <= '1';
				ready <= '0';
				
				-- store length register values
				pulse_length_i_next <= unsigned(out_data);
				
				-- load next pulse delay value
				instr_pointer_next <= instr_pointer + to_unsigned(1, instr_pointer'length);
				a_reg <= std_logic_vector(instr_pointer + to_unsigned(1, instr_pointer'length));
				
			when TRIGGERED_COUNTING =>
			    -- wait until pulse delay reached
                if count = pulse_delay_i then
                    next_state <= INJECTED;
                
                    -- set next pulse delay value
                    pulse_delay_i_next <= unsigned(out_data);
                end if; 
				
				
				a_reg <= std_logic_vector(instr_pointer);
				ready <= '0';
			when INJECTED =>
				next_state <= INJECTED_COUNTING;
				ready <= '0';
				count_reset <= '1';
				
				instr_pointer_next <= instr_pointer + to_unsigned(1, instr_pointer'length);
				a_reg <= std_logic_vector(instr_pointer + to_unsigned(1, instr_pointer'length));	
			when INJECTED_COUNTING =>
				if count = pulse_length_i then
					-- check if at end of instruction memory
					if instr_pointer - to_unsigned(0, instr_pointer'length) > instr_count then
						next_state <= IDLE;
					else
						next_state <= TRIGGERED;
					end if;	
				end if;	

				a_reg <= std_logic_vector(instr_pointer);
				inject_fault <= not polarity_i;
				ready <= '0';
		end case;
	end process;
end;
