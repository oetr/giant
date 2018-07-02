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
-- Description: Controller for AD9283
--
-- Notes:
-- none
--  
-- Dependencies:
-- adc_fifo
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

entity adc_controller is
	port( 
		-- inputs
		clk : in std_logic;
		ce : in std_logic;
		reset : in std_logic;
		
		-- ADC input pins (from hardware)
		adc_in : in std_logic_vector(7 downto 0);

		-- ADC encode clock pin (to hardware)
		adc_encode : out std_logic;
		
		-- Last value read from ADC
		adc_value : out byte
	);
end adc_controller;

architecture behavioral of adc_controller is
   -- constants
	
   -- components
   
	-- signals
	signal clk_inv : std_logic;
	signal ce_of : std_logic;
	signal adc_in_buf : byte;
	signal adc_clk : std_logic;
	
begin
	-- assignments	
	clk_inv <= not clk;
	
	adc_encode <= adc_clk;
	
    ODDR2_inst : ODDR2
    generic map(
       DDR_ALIGNMENT => "C0", 
       INIT => '0', 
       SRTYPE => "ASYNC"
	 ) 
    port map (
       Q => adc_clk, -- 1-bit output data
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
				ce_of <= '0';
				adc_in_buf <= (others => '0');
				adc_value <= (others => '0');
			elsif ce = '1' then
				ce_of <= '1';
				adc_in_buf <= adc_in;
				adc_value <= adc_in_buf;
			end if;
		end if;
	end process MAIN;

	
	
end behavioral;

