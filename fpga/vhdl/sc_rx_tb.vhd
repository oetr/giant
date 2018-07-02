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
-- Component name: sc_rx_tb
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 11:25 10.01.2011
--
-- Description: Testbench for SC RX UART
--
-- Notes:
-- none
--  
-- Dependencies:
-- sc_rx
-----------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.defaults.all;

entity sc_rx_tb is
end sc_rx_tb;

architecture behavioral of sc_rx_tb is
	-- constants
	
	-- Clock period definitions (2 MHz sc clock)
	constant CLK_PERIOD : time := 500 ns;
	
	constant F_d : positive := 372;
	constant D_d : positive := 1;
	
	
	-- exponent of divider for rxtx_clk derived from sc_clk
	-- (defaults to 2 MHz/4 = 500 kHz)
	constant RXTX_CLK_DIV : positive := 2;
	
	-- ETU in ticks of RXTX_CLK 
	constant etu_d : positive := (F_d/D_d)/(2**RXTX_CLK_DIV);
	constant BITS_etu_d : positive := log2_ceil(etu_d);
	
	-- default timeout in etu ticks
	constant TIMEOUT_d : positive := 9600;
	constant BITS_TIMEOUT_d : positive := log2_ceil(TIMEOUT_d);
	
	-- components
	component sc_rx is
		generic(
			BITS_ETU : positive;
			BITS_TIMEOUT : positive
		);
		port( 
			clk : in std_logic;
			reset : in std_logic;
			etu : in unsigned(BITS_ETU-1 downto 0);
			timeout : in unsigned(BITS_TIMEOUT-1 downto 0);
			serial_in : in std_logic;
			byte_out : out byte;
			byte_complete : out std_logic;
			parity_error : out std_logic;
			timed_out : out std_logic
			
		);
	end component;
	

	-- signals
	
	-- rx/tx clock
	signal rxtx_clk : std_logic;
	signal rxtx_counter : unsigned(RXTX_CLK_DIV-1 downto 0) := to_unsigned(0, RXTX_CLK_DIV);
	
	signal clk, reset : std_logic;
	signal etu : unsigned(BITS_ETU_d-1 downto 0);
	signal timeout : unsigned(BITS_TIMEOUT_d-1 downto 0);
	signal serial_in : std_logic;
	signal byte_out : byte;
	signal byte_complete : std_logic;
	signal parity_error : std_logic;
	signal timed_out : std_logic;
	signal sampled_bit : std_logic;
begin
	-- constants
	
	-- components
	
	-- DUT
	DUT : sc_rx generic map(
		BITS_ETU => BITS_ETU_d,
		BITS_TIMEOUT => BITS_TIMEOUT_d
	)
	port map(
		clk => rxtx_clk,
		reset => reset,
		etu => etu,
		timeout => timeout,
		serial_in => serial_in,
		byte_out => byte_out, 
		byte_complete => byte_complete,
		parity_error => parity_error,
		timed_out => timed_out,
		sampled_bit => sampled_bit
	);	
	
	etu <= to_unsigned(etu_d, etu'length);
	timeout <= to_unsigned(TIMEOUT_d, timeout'length);
	
	-- processes
	
	-- Generate clock
	RXTX_CLK_GEN : process(clk)
	begin
		if rising_edge(clk) then
			rxtx_counter <= rxtx_counter + 1;
			rxtx_clk <= rxtx_counter(RXTX_CLK_DIV-1);
		end if;
	end process;
	
	CLK_PROCESS :process
	begin
		clk <= '0';
		wait for CLK_PERIOD/2;
		clk <= '1';
		wait for CLK_PERIOD/2;
	end process;
 
	-- Stimulus process
	STIM_PROC: process
	begin
		-- hold reset state
		serial_in <= '1';
		reset <= '1';
		
		wait for CLK_PERIOD*10;
		
		reset <= '0';
		
		wait for CLK_PERIOD*10;
		
		
		-- start programming
		
		-- start bit
		serial_in <= '0';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- 1101 0101
		-- bit 2
		serial_in <= '1';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- bit 3
		serial_in <= '1';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- bit 4
		serial_in <= '0';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- bit 5
		serial_in <= '1';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- bit 6
		serial_in <= '0';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- bit 7
		serial_in <= '1';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- bit 8
		serial_in <= '0';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- bit 9
		serial_in <= '1';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- bit 10 (parity)
		serial_in <= '1';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- Pause (guard time)
		serial_in <= '1';
		wait for CLK_PERIOD*(F_d/D_d)*12;
		
		
		---- second bit ----
		-- start bit
		serial_in <= '0';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- 11110001
		-- bit 2
		serial_in <= '1';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- bit 3
		serial_in <= '1';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- bit 4
		serial_in <= '1';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- bit 5
		serial_in <= '1';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- bit 6
		serial_in <= '0';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- bit 7
		serial_in <= '0';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- bit 8
		serial_in <= '0';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- bit 9
		serial_in <= '1';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- bit 10 (parity)
		serial_in <= '1';
		wait for CLK_PERIOD*(F_d/D_d);
		
		-- Pause (guard time)
		serial_in <= '1';
		wait for CLK_PERIOD*(F_d/D_d);
		wait;
	end process;
	

end;
