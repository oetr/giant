-----------------------------------------------------------------
-- 
-- Component name: shift_register_u8
-- Author: David Oswald <david.oswald@rub.de>
-- Date: 100902
--
-- Description: Bytewise shift register
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

entity shift_register_u8 is
	generic(
		-- input width in byte 
		WIDTH : positive
	);
	port( 
		-- standard inputs
		clk : in std_logic;
		ce : in std_logic;
		reset : in std_logic;
		
		-- inputs
		d_in : in u8;
		
		-- outputs	
		d_out : out u8_vector(WIDTH-1 downto 0)
	);
end shift_register_u8;

architecture behavioral of shift_register_u8 is
   -- constants
   
   -- components
   
   -- signals
   signal reg: u8_vector(WIDTH - 1 downto 0);
begin
	-- constants
	
	-- components
	
	-- signals

	MAIN : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				reg <= (others => (others => '0'));
			elsif ce = '1' then
				-- remove MSB and clock in new byte
				reg(reg'length - 1 downto 1) <= reg(reg'length - 2 downto 0) ;
				reg(0) <= d_in;
			end if;
		end if;
	end process;
	
	-- output complete register
	d_out <= reg;
end;
