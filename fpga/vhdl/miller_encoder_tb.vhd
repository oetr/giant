--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:07:50 10/06/2009
-- Design Name:   
-- Module Name:   D:/SVN/da/fpga/rfid/miller_encoder_tb.vhd
-- Project Name:  rfid
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: miller_encoder
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY miller_encoder_tb IS
END miller_encoder_tb;
 
ARCHITECTURE behavior OF miller_encoder_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT miller_encoder
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         w_en : IN  std_logic;
         data : IN  std_logic_vector(7 downto 0);
         transmit : IN  std_logic;
			send_count : in std_logic_vector(7 downto 0);
         encoded : OUT  unsigned(7 downto 0);
         transmitting : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal w_en : std_logic := '0';
   signal data : std_logic_vector(7 downto 0) := (others => '0');
	signal send_count : std_logic_vector(7 downto 0) := (others => '0');
   signal transmit : std_logic := '0';

 	--Outputs
   signal encoded : unsigned(7 downto 0);
   signal transmitting : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: miller_encoder PORT MAP (
          clk => clk,
          reset => reset,
          w_en => w_en,
          data => data,
			 send_count => send_count,
          transmit => transmit,
          encoded => encoded,
          transmitting => transmitting
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		reset <= '1';
		w_en <= '0';
		data <= "00000000";
		send_count <= "00001000";
		transmit <= '0';
		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		
		reset <= '0';
      wait for clk_period*10;
		
		w_en <= '1';
		data <= "10011010";
      wait for clk_period*1;
		
		w_en <= '0';
      wait for clk_period*1;
      
    w_en <= '1';
		data <= "10011010";
      wait for clk_period*1;
		
		w_en <= '0';
      wait for clk_period*1;
		
		transmit <= '1';
		wait for clk_period*1;
		
		transmit <= '0';
		wait for clk_period*1;
      wait;
   end process;

END;
