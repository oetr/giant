--*****************************************************************************
-- (c) Copyright 2009 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
--*****************************************************************************
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : 3.8
--  \   \        Application        : MIG
--  /   /        Filename           : sim_tb_top.vhd
-- /___/   /\    Date Last Modified : $Date: 2011/05/27 15:50:36 $
-- \   \  /  \   Date Created       : Jul 03 2009
--  \___\/\___\
--
-- Device      : Spartan-6
-- Design Name : DDR/DDR2/DDR3/LPDDR
-- Purpose     : This is the simulation testbench which is used to verify the
--               design. The basic clocks and resets to the interface are
--               generated here. This also connects the memory interface to the
--               memory model.
--*****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity sim_tb_top is

end entity sim_tb_top;

architecture arch of sim_tb_top is



-- ========================================================================== --
-- Parameters                                                                 --
-- ========================================================================== --
   constant DEBUG_EN             : integer :=0;
   
   constant C3_HW_TESTING      : string := "FALSE";
 
function c3_sim_hw (val1:std_logic_vector( 31 downto 0); val2: std_logic_vector( 31 downto 0) )  return  std_logic_vector is
   begin
   if (C3_HW_TESTING = "FALSE") then
     return val1;
   else
     return val2;
   end if;
   end function;		

   constant  C3_MEMCLK_PERIOD : integer    := 5000;
   constant C3_RST_ACT_LOW : integer := 0;
   constant C3_INPUT_CLK_TYPE : string := "SINGLE_ENDED";
   constant C3_CLK_PERIOD_NS   : real := 5000.0 / 1000.0;
   constant C3_TCYC_SYS        : real := C3_CLK_PERIOD_NS/2.0;
   constant C3_TCYC_SYS_DIV2   : time := C3_TCYC_SYS * 1 ns;
   constant C3_NUM_DQ_PINS        : integer := 16;
   constant C3_MEM_ADDR_WIDTH     : integer := 13;
   constant C3_MEM_BANKADDR_WIDTH : integer := 2;
   constant C3_MEM_ADDR_ORDER     : string := "ROW_BANK_COLUMN"; 
      constant C3_P0_MASK_SIZE : integer      := 4;
   constant C3_P0_DATA_PORT_SIZE : integer := 32;  
   constant C3_P1_MASK_SIZE   : integer    := 4;
   constant C3_P1_DATA_PORT_SIZE  : integer := 32;
   constant C3_CALIB_SOFT_IP      : string := "TRUE";
   constant C3_SIMULATION      : string := "TRUE";
   

-- ========================================================================== --
-- Component Declarations
-- ========================================================================== --


component example_top is
generic 
(
            C3_P0_MASK_SIZE         : integer;
    C3_P0_DATA_PORT_SIZE    : integer;
    C3_P1_MASK_SIZE         : integer;
    C3_P1_DATA_PORT_SIZE    : integer;
    
    C3_MEMCLK_PERIOD        : integer; 
    C3_RST_ACT_LOW          : integer;
    C3_INPUT_CLK_TYPE       : string;
    DEBUG_EN                : integer;

    C3_CALIB_SOFT_IP        : string;
    C3_SIMULATION           : string;
    C3_HW_TESTING           : string;
    C3_MEM_ADDR_ORDER       : string;
    C3_NUM_DQ_PINS          : integer; 
    C3_MEM_ADDR_WIDTH       : integer; 
    C3_MEM_BANKADDR_WIDTH   : integer
);  
  port
  (
       calib_done                    : out std_logic;
   error                                 : out std_logic;
		mcb3_dram_dq                            : inout  std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);
   mcb3_dram_a                             : out std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
   mcb3_dram_ba                            : out std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);
   mcb3_dram_ras_n                         : out std_logic;
   mcb3_dram_cas_n                         : out std_logic;
   mcb3_dram_we_n                          : out std_logic;
   mcb3_dram_cke                           : out std_logic;
   mcb3_dram_dm                            : out std_logic;
      mcb3_rzq    				   : inout  std_logic;
        
   
        c3_sys_clk                            : in  std_logic;
   c3_sys_rst_i                            : in  std_logic;
	
   mcb3_dram_dqs                           : inout  std_logic;
   mcb3_dram_ck                            : out std_logic;
         mcb3_dram_udqs                           : inout  std_logic;
   mcb3_dram_udm                            : out std_logic;
   mcb3_dram_ck_n                          : out std_logic
  );
end component;


        component ddr_model_c3 is
    port (
      Clk     : in    std_logic;
      Clk_n   : in    std_logic;
      Cke     : in    std_logic;
      Cs_n    : in    std_logic;
      Ras_n   : in    std_logic;
      Cas_n   : in    std_logic;
      We_n    : in    std_logic;
      Dm      : inout std_logic_vector((C3_NUM_DQ_PINS/16) downto 0);
      Ba      : in    std_logic_vector((C3_MEM_BANKADDR_WIDTH - 1) downto 0);
      Addr    : in    std_logic_vector((C3_MEM_ADDR_WIDTH  - 1) downto 0);
      Dq      : inout std_logic_vector((C3_NUM_DQ_PINS - 1) downto 0);
      Dqs     : inout std_logic_vector((C3_NUM_DQ_PINS/16) downto 0)
      );
  end component;

-- ========================================================================== --
-- Signal Declarations                                                        --
-- ========================================================================== --

 			-- Clocks
   signal  c3_sys_clk     : std_logic := '0';
   signal  c3_sys_clk_p   : std_logic;
   signal  c3_sys_clk_n   : std_logic;
-- System Reset
   signal  c3_sys_rst   : std_logic := '0';
   signal  c3_sys_rst_i     : std_logic;



-- Design-Top Port Map   
   signal mcb3_dram_a : std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
   signal mcb3_dram_ba : std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);  
   signal  mcb3_dram_ck : std_logic;  
   signal  mcb3_dram_ck_n : std_logic;  
   signal  mcb3_dram_dq : std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);   
   signal  mcb3_dram_dqs   : std_logic;    
   signal  mcb3_dram_dm    : std_logic;   
   signal  mcb3_dram_ras_n : std_logic;   
   signal  mcb3_dram_cas_n : std_logic;   
   signal  mcb3_dram_we_n  : std_logic;    
   signal  mcb3_dram_cke   : std_logic;   
       signal  calib_done                        : std_logic;  
   signal  error                             : std_logic;  

      signal  mcb3_dram_udqs   : std_logic;
   signal mcb3_dram_dqs_vector : std_logic_vector(1 downto 0);
      signal   mcb3_dram_udm :std_logic;     -- for X16 parts
   signal mcb3_dram_dm_vector : std_logic_vector(1 downto 0);
   
   
   signal mcb3_command               : std_logic_vector(2 downto 0);
   signal mcb3_enable1                : std_logic;
   signal mcb3_enable2              : std_logic;

   

   signal  rzq3     : std_logic;
      



function vector (asi:std_logic) return std_logic_vector is
  variable v : std_logic_vector(0 downto 0) ; 
begin
  v(0) := asi;
  return(v); 
end function vector; 

begin
-- ========================================================================== --
-- Clocks Generation                                                          --
-- ========================================================================== --


  process
  begin
    c3_sys_clk <= not c3_sys_clk;
    wait for (C3_TCYC_SYS_DIV2);
  end process;

  c3_sys_clk_p <= c3_sys_clk;
  c3_sys_clk_n <= not c3_sys_clk;

-- ========================================================================== --
-- Reset Generation                                                           --
-- ========================================================================== --
 
 process
  begin
    c3_sys_rst <= '0';
    wait for 200 ns;
    c3_sys_rst <= '1';
    wait;
  end process;

    c3_sys_rst_i <= c3_sys_rst when (C3_RST_ACT_LOW = 1) else (not c3_sys_rst);





   


   rzq_pulldown3 : PULLDOWN port map(O => rzq3);
      

-- ========================================================================== --
-- DESIGN TOP INSTANTIATION                                                    --
-- ========================================================================== --

design_top : example_top generic map
(
  
C3_P0_MASK_SIZE  =>     C3_P0_MASK_SIZE,
C3_P0_DATA_PORT_SIZE  => C3_P0_DATA_PORT_SIZE,
C3_P1_MASK_SIZE       => C3_P1_MASK_SIZE,
C3_P1_DATA_PORT_SIZE  => C3_P1_DATA_PORT_SIZE, 
	C3_MEMCLK_PERIOD  =>       C3_MEMCLK_PERIOD,
C3_RST_ACT_LOW    =>     C3_RST_ACT_LOW,
C3_INPUT_CLK_TYPE =>     C3_INPUT_CLK_TYPE, 
DEBUG_EN        => DEBUG_EN,

C3_MEM_ADDR_ORDER     => C3_MEM_ADDR_ORDER,
C3_NUM_DQ_PINS        => C3_NUM_DQ_PINS,
C3_MEM_ADDR_WIDTH     => C3_MEM_ADDR_WIDTH,
C3_MEM_BANKADDR_WIDTH => C3_MEM_BANKADDR_WIDTH,

C3_HW_TESTING   =>      C3_HW_TESTING,
C3_SIMULATION   =>      C3_SIMULATION,

C3_CALIB_SOFT_IP      => C3_CALIB_SOFT_IP
) 
port map ( 

  calib_done         =>                      calib_done,
  error                          =>           error,
  c3_sys_clk  =>         c3_sys_clk,
  c3_sys_rst_i    =>       c3_sys_rst_i,                        

  mcb3_dram_dq     =>      mcb3_dram_dq,  
  mcb3_dram_a      =>      mcb3_dram_a,  
  mcb3_dram_ba     =>      mcb3_dram_ba,
  mcb3_dram_ras_n  =>      mcb3_dram_ras_n,                        
  mcb3_dram_cas_n  =>      mcb3_dram_cas_n,                        
  mcb3_dram_we_n   =>      mcb3_dram_we_n,                          
  mcb3_dram_cke    =>      mcb3_dram_cke,                          
  mcb3_dram_ck     =>      mcb3_dram_ck,                          
  mcb3_dram_ck_n   =>      mcb3_dram_ck_n,       
  mcb3_dram_udqs  =>       mcb3_dram_udqs,    -- for X16 parts           
		mcb3_dram_udm  =>        mcb3_dram_udm,     -- for X16 parts
  mcb3_dram_dm  =>       mcb3_dram_dm,
     mcb3_rzq         =>            rzq3,
        
  
  mcb3_dram_dqs    =>      mcb3_dram_dqs
);      



-- ========================================================================== --
-- Memory model instances                                                     -- 
-- ========================================================================== --

    mcb3_command <= (mcb3_dram_ras_n & mcb3_dram_cas_n & mcb3_dram_we_n);

    process(mcb3_dram_ck)
    begin
      if (rising_edge(mcb3_dram_ck)) then
        if (c3_sys_rst = '0') then
          mcb3_enable1   <= '0';
          mcb3_enable2 <= '0';
        elsif (mcb3_command = "100") then
          mcb3_enable2 <= '0';
        elsif (mcb3_command = "101") then
          mcb3_enable2 <= '1';
        else
          mcb3_enable2 <= mcb3_enable2;
        end if;
        mcb3_enable1     <= mcb3_enable2;
      end if;
    end process;

-----------------------------------------------------------------------------
--read
-----------------------------------------------------------------------------
    mcb3_dram_dqs_vector(1 downto 0)               <= (mcb3_dram_udqs & mcb3_dram_dqs)
                                                           when (mcb3_enable2 = '0' and mcb3_enable1 = '0')
							   else "ZZ";
    
-----------------------------------------------------------------------------
--write
-----------------------------------------------------------------------------
    mcb3_dram_dqs          <= mcb3_dram_dqs_vector(0)
                              when ( mcb3_enable1 = '1') else 'Z';

    mcb3_dram_udqs          <= mcb3_dram_dqs_vector(1)
                              when (mcb3_enable1 = '1') else 'Z';


   
   
mcb3_dram_dm_vector <= (mcb3_dram_udm & mcb3_dram_dm);

     u_mem_c3 : ddr_model_c3 port map(
        Clk       => mcb3_dram_ck,
        Clk_n     => mcb3_dram_ck_n,
        Cke       => mcb3_dram_cke,
        Cs_n      => '0',
        Ras_n     => mcb3_dram_ras_n,
        Cas_n     => mcb3_dram_cas_n,
        We_n      => mcb3_dram_we_n,
        Dm        => mcb3_dram_dm_vector ,
        Ba        => mcb3_dram_ba,
        Addr      => mcb3_dram_a,
        Dq        => mcb3_dram_dq,
        Dqs       => mcb3_dram_dqs_vector
      );


-----------------------------------------------------------------------------     
-- Reporting the test case status 
-----------------------------------------------------------------------------
   Logging: process 
   begin
      wait for 200 us;
      if (calib_done = '1') then
         if (error = '0') then
   	    report ("****TEST PASSED****");
         else
            report ("****TEST FAILED: DATA ERROR****");
         end if;
      else
         report ("****TEST FAILED: INITIALIZATION DID NOT COMPLETE****");
      end if;
   end process;   

end architecture;
