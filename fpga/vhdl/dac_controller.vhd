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
-- Component name: dac_controller
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 110730
--
-- Description: Controller for DAC device
--
-- Notes:
-- none
--  
-- Dependencies:
-- none
--
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- for Xilinx primitives
library UNISIM;
use UNISIM.vcomponents.all;

entity dac_controller is
	port( 
		-- inputs
		clk : in std_logic;
		ce : in std_logic;
		reset : in std_logic;
		
		-- output test signal: full scale up ramp if pin = 1
		test_mode : in std_logic;
		
		-- DAC code for low voltage 
		voltage_low : in std_logic_vector(7 downto 0);
		-- DAC code for high voltage
		voltage_high : in std_logic_vector(7 downto 0);
		-- DAC code for off voltage
		voltage_off : in std_logic_vector(7 downto 0);
		-- select input (0 for low, 1 for high voltage)
		voltage_select : in std_logic;
		-- update output if pin = 1
		voltage_update : in std_logic;
		-- disable DAC and output off voltage
		off : in std_logic;
		
		-- outputs	
		
		-- DAC voltage code
		voltage_out : out std_logic_vector(7 downto 0);
		-- DAC sleep pin
		sleep : out std_logic;
		-- DAC clock pin
		clk_dac : out std_logic
	);
end dac_controller;

architecture behavioral of dac_controller is
   -- constants
   
   -- components
   
   -- signals
   signal clk_inv : std_logic;
	signal voltage_i : unsigned(7 downto 0);
   signal off_prev, voltage_select_prev, ce_of : std_logic;
begin
	-- assignments
	
	-- NOTE: could be necessary to buffer with BUFG
	-- clk_dac <= clk;
	voltage_out <= std_logic_vector(voltage_i);
	
	clk_inv <= not clk;
	
	
	ODDR2_inst : ODDR2
   generic map(
      DDR_ALIGNMENT => "NONE", 
      INIT => '0', 
      SRTYPE => "SYNC"
	) 
   port map (
      Q => clk_dac, -- 1-bit output data
      C0 => clk, -- 1-bit clock input
      C1 => clk_inv, -- 1-bit clock input
      CE => ce_of,  -- 1-bit clock enable input
      D0 => '1',   -- 1-bit data input (associated with C0)
      D1 => '0',   -- 1-bit data input (associated with C1)
      R => reset,    -- 1-bit reset input
      S => '0'     -- 1-bit set input
   );
	
	MAIN: process(clk)
	begin
		if rising_edge(clk) then
			if(reset = '1') then
				sleep <= '0';
				--clk_dac_i <= '0';
				voltage_i <= (others => '0');
				voltage_select_prev <= '0';
				ce_of <= '0';
				off_prev <= '0';
			elsif ce = '1' then
				sleep <= '0';
				voltage_select_prev <= voltage_select;
				off_prev <= off;
				
				if off = '1' then
					voltage_i <= unsigned(voltage_off);
				elsif test_mode = '1' then
					voltage_i <= voltage_i + 1;
					--voltage_i <= not voltage_i;
				elsif voltage_select = '1' then
					voltage_i <= unsigned(voltage_high);
				else
					voltage_i <= unsigned(voltage_low);
				end if;
				
				-- only clock on select change or in test mode
				if ((voltage_select xor voltage_select_prev) or test_mode or (off xor off_prev) or voltage_update) = '1' then
					ce_of <= '1';
				else
					ce_of <= '0';
				end if;
			end if;
		end if;
	end process MAIN;
	
	
end behavioral;

