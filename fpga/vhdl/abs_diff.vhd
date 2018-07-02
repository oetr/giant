-----------------------------------------------------------------
-- 
-- Component name: abs_diff
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 100902
--
-- Description: Absolute difference
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

library work;
use work.defaults.all;

entity abs_diff is
	port( 
		-- standard inputs
		clk : in std_logic;
		ce : in std_logic;
		reset : in std_logic;
		
		-- inputs
		a : in u8;
		b : in u8;
		
		-- enable or disable (force output to zero)
		enable : in std_logic;
		
		-- output
		c : out u8
	);
end abs_diff;

architecture behavioral of abs_diff is
	-- types

   -- constants
   
   -- components
   
   -- signals
   signal op1, op2 : unsigned(7 downto 0);
begin
	-- constants
	
	-- components
	
	-- signals

	MAIN : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				op1 <= (others => '0');
				op2 <= (others => '0');
			elsif ce = '1' then
				if enable = '0' then
					op1 <= (others => '0');
					op2 <= (others => '0');
				elsif a >= b then
					op1 <= a;
					op2 <= b;
				else
					op1 <= b;
					op2 <= a;
				end if;
			end if;
		end if;
	end process;
	
	-- subtract
	c <= op1 - op2;
end;
