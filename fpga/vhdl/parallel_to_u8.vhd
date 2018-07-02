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
-- Component name: parallel_to_u8
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 090415
--
-- Description: Parallel to bytewise serial converter
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

-- common stuff
library work;
use work.defaults.all;

-- for Xilinx primitives
library UNISIM;
use UNISIM.vcomponents.all;

entity parallel_to_u8 is
	generic(
		-- input width in byte 
		WIDTH : positive
	);
	port( 
		-- standard inputs
		clk : in std_logic;
		reset : in std_logic;
		
		-- inputs
		d_in : in std_logic_vector(WIDTH*8-1 downto 0);
		-- rising-edge triggered write enable
		w_en : in std_logic;
		
		
		-- rising-edge read enable
		r_en : in std_logic;
		
		-- outputs	
		d_out : out byte;
		count : out unsigned(log2_ceil(WIDTH)-1 downto 0)
	);
end parallel_to_u8;

architecture behavioral of parallel_to_u8 is
	-- constants
	constant BITS_WIDTH : positive := log2_ceil(WIDTH);
   
	-- components

	-- signals
	signal reg : std_logic_vector(WIDTH*8 - 1 downto 0);
	signal count_i : unsigned(BITS_WIDTH-1 downto 0);
	signal d_out_buf : byte;
	signal r_en_prev, w_en_prev : std_logic;
begin
	-- constants
	
	-- components
	
	-- signals
	d_out <= reg(7 downto 0);

	MAIN : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				reg <= (others => '0');
				count_i <= (others => '0');
				--d_out_buf <= (others => '0');
				r_en_prev <= '0';
				w_en_prev <= '0';
			-- write (higher priority than read)
			elsif w_en = '1' then --and w_en_prev = '0' then
				count_i <= to_unsigned(WIDTH, BITS_WIDTH);
				reg <= d_in;
				
				r_en_prev <= r_en;
				w_en_prev <= w_en;
			-- read (lower priority than write)
			elsif r_en = '1' and r_en_prev = '0' then
				-- overwrite MSB with zero, i.e., shift to right
				reg(8*WIDTH-1 downto 8*(WIDTH-1)) <= (others => '0');
				
				for i in 1 to WIDTH-1 loop
					reg(8*i-1 downto 8*(i-1)) <= reg(8*(i + 1)-1 downto 8*i);
				end loop;

				if count_i > 0 then
					count_i <= count_i-1;
				end if;
				
				--d_out_buf <= ;
				
				r_en_prev <= r_en;
				w_en_prev <= w_en;
			else
				r_en_prev <= r_en;
				w_en_prev <= w_en;
			end if;
		end if;
	end process;
	
	-- output counter
	count <= count_i;
end;
