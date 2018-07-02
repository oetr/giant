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
   constant C3_MEM_BURST_LEN	  : integer := 4;
   constant C3_MEM_NUM_COL_BITS   : integer := 10;
   constant C3_SIMULATION      : string := "TRUE";
   constant C3_CALIB_SOFT_IP      : string := "TRUE";
   constant C3_p0_BEGIN_ADDRESS                   : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000100", x"01000000");
   constant C3_p0_DATA_MODE                       : std_logic_vector(3 downto 0)  := "0010";
   constant C3_p0_END_ADDRESS                     : std_logic_vector(31 downto 0)  := c3_sim_hw (x"000002ff", x"02ffffff");
   constant C3_p0_PRBS_EADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"fffffc00", x"fc000000");
   constant C3_p0_PRBS_SADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000100", x"01000000");
   constant C3_p1_BEGIN_ADDRESS                   : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000300", x"03000000");
   constant C3_p1_DATA_MODE                       : std_logic_vector(3 downto 0)  := "0010";
   constant C3_p1_END_ADDRESS                     : std_logic_vector(31 downto 0)  := c3_sim_hw (x"000004ff", x"04ffffff");
   constant C3_p1_PRBS_EADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"fffff800", x"f8000000");
   constant C3_p1_PRBS_SADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000300", x"03000000");
   constant C3_p2_BEGIN_ADDRESS                   : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000100", x"01000000");
   constant C3_p2_DATA_MODE                       : std_logic_vector(3 downto 0)  := "0010";
   constant C3_p2_END_ADDRESS                     : std_logic_vector(31 downto 0)  := c3_sim_hw (x"000002ff", x"02ffffff");
   constant C3_p2_PRBS_EADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"fffffc00", x"fc000000");
   constant C3_p2_PRBS_SADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000100", x"01000000");
   constant C3_p3_BEGIN_ADDRESS                   : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000100", x"01000000");
   constant C3_p3_DATA_MODE                       : std_logic_vector(3 downto 0)  := "0010";
   constant C3_p3_END_ADDRESS                     : std_logic_vector(31 downto 0)  := c3_sim_hw (x"000002ff", x"02ffffff");
   constant C3_p3_PRBS_EADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"fffffc00", x"fc000000");
   constant C3_p3_PRBS_SADDR_MASK_POS             : std_logic_vector(31 downto 0)  := c3_sim_hw (x"00000100", x"01000000");

-- ========================================================================== --
-- Component Declarations
-- ========================================================================== --


component memory_controller is
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
    C3_MEM_ADDR_ORDER       : string;
    C3_NUM_DQ_PINS          : integer; 
    C3_MEM_ADDR_WIDTH       : integer; 
    C3_MEM_BANKADDR_WIDTH   : integer
);  
  port
  (
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
	
   c3_calib_done                           : out std_logic;
        c3_clk0                                 : out std_logic;
   c3_rst0                                 : out std_logic;
 
   mcb3_dram_dqs                           : inout  std_logic;
   mcb3_dram_ck                            : out std_logic;
         mcb3_dram_udqs                           : inout  std_logic;
   mcb3_dram_udm                            : out std_logic;
   mcb3_dram_ck_n                          : out std_logic;   c3_p0_cmd_clk                           : in std_logic;
   c3_p0_cmd_en                            : in std_logic;
   c3_p0_cmd_instr                         : in std_logic_vector(2 downto 0);
   c3_p0_cmd_bl                            : in std_logic_vector(5 downto 0);
   c3_p0_cmd_byte_addr                     : in std_logic_vector(29 downto 0);
   c3_p0_cmd_empty                         : out std_logic;
   c3_p0_cmd_full                          : out std_logic;
   c3_p0_wr_clk                            : in std_logic;
   c3_p0_wr_en                             : in std_logic;
   c3_p0_wr_mask                           : in std_logic_vector(C3_P0_MASK_SIZE - 1 downto 0);
   c3_p0_wr_data                           : in std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
   c3_p0_wr_full                           : out std_logic;
   c3_p0_wr_empty                          : out std_logic;
   c3_p0_wr_count                          : out std_logic_vector(6 downto 0);
   c3_p0_wr_underrun                       : out std_logic;
   c3_p0_wr_error                          : out std_logic;
   c3_p0_rd_clk                            : in std_logic;
   c3_p0_rd_en                             : in std_logic;
   c3_p0_rd_data                           : out std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
   c3_p0_rd_full                           : out std_logic;
   c3_p0_rd_empty                          : out std_logic;
   c3_p0_rd_count                          : out std_logic_vector(6 downto 0);
   c3_p0_rd_overflow                       : out std_logic;
   c3_p0_rd_error                          : out std_logic;
   c3_p1_cmd_clk                           : in std_logic;
   c3_p1_cmd_en                            : in std_logic;
   c3_p1_cmd_instr                         : in std_logic_vector(2 downto 0);
   c3_p1_cmd_bl                            : in std_logic_vector(5 downto 0);
   c3_p1_cmd_byte_addr                     : in std_logic_vector(29 downto 0);
   c3_p1_cmd_empty                         : out std_logic;
   c3_p1_cmd_full                          : out std_logic;
   c3_p1_wr_clk                            : in std_logic;
   c3_p1_wr_en                             : in std_logic;
   c3_p1_wr_mask                           : in std_logic_vector(C3_P1_MASK_SIZE - 1 downto 0);
   c3_p1_wr_data                           : in std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
   c3_p1_wr_full                           : out std_logic;
   c3_p1_wr_empty                          : out std_logic;
   c3_p1_wr_count                          : out std_logic_vector(6 downto 0);
   c3_p1_wr_underrun                       : out std_logic;
   c3_p1_wr_error                          : out std_logic;
   c3_p1_rd_clk                            : in std_logic;
   c3_p1_rd_en                             : in std_logic;
   c3_p1_rd_data                           : out std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
   c3_p1_rd_full                           : out std_logic;
   c3_p1_rd_empty                          : out std_logic;
   c3_p1_rd_count                          : out std_logic_vector(6 downto 0);
   c3_p1_rd_overflow                       : out std_logic;
   c3_p1_rd_error                          : out std_logic;
   c3_p2_cmd_clk                           : in std_logic;
   c3_p2_cmd_en                            : in std_logic;
   c3_p2_cmd_instr                         : in std_logic_vector(2 downto 0);
   c3_p2_cmd_bl                            : in std_logic_vector(5 downto 0);
   c3_p2_cmd_byte_addr                     : in std_logic_vector(29 downto 0);
   c3_p2_cmd_empty                         : out std_logic;
   c3_p2_cmd_full                          : out std_logic;
   c3_p2_rd_clk                            : in std_logic;
   c3_p2_rd_en                             : in std_logic;
   c3_p2_rd_data                           : out std_logic_vector(31 downto 0);
   c3_p2_rd_full                           : out std_logic;
   c3_p2_rd_empty                          : out std_logic;
   c3_p2_rd_count                          : out std_logic_vector(6 downto 0);
   c3_p2_rd_overflow                       : out std_logic;
   c3_p2_rd_error                          : out std_logic;
   c3_p3_cmd_clk                           : in std_logic;
   c3_p3_cmd_en                            : in std_logic;
   c3_p3_cmd_instr                         : in std_logic_vector(2 downto 0);
   c3_p3_cmd_bl                            : in std_logic_vector(5 downto 0);
   c3_p3_cmd_byte_addr                     : in std_logic_vector(29 downto 0);
   c3_p3_cmd_empty                         : out std_logic;
   c3_p3_cmd_full                          : out std_logic;
   c3_p3_rd_clk                            : in std_logic;
   c3_p3_rd_en                             : in std_logic;
   c3_p3_rd_data                           : out std_logic_vector(31 downto 0);
   c3_p3_rd_full                           : out std_logic;
   c3_p3_rd_empty                          : out std_logic;
   c3_p3_rd_count                          : out std_logic_vector(6 downto 0);
   c3_p3_rd_overflow                       : out std_logic;
   c3_p3_rd_error                          : out std_logic
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
component memc3_tb_top is
generic
  (
      C_P0_MASK_SIZE                   : integer := 4;
      C_P0_DATA_PORT_SIZE              : integer := 32;
      C_P1_MASK_SIZE                   : integer := 4;
      C_P1_DATA_PORT_SIZE              : integer := 32;
      C_MEM_BURST_LEN                  : integer := 8;
      C_MEM_NUM_COL_BITS               : integer := 11;
      C_NUM_DQ_PINS                    : integer := 8;
	        C_p0_BEGIN_ADDRESS                      : std_logic_vector(31 downto 0)  := X"00000100";
      C_p0_DATA_MODE                          : std_logic_vector(3 downto 0)  := "0010";
      C_p0_END_ADDRESS                        : std_logic_vector(31 downto 0)  := X"000002ff";
      C_p0_PRBS_EADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"fffffc00";
      C_p0_PRBS_SADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"00000100";
      C_p1_BEGIN_ADDRESS                      : std_logic_vector(31 downto 0)  := X"00000300";
      C_p1_DATA_MODE                          : std_logic_vector(3 downto 0)  := "0010";
      C_p1_END_ADDRESS                        : std_logic_vector(31 downto 0)  := X"000004ff";
      C_p1_PRBS_EADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"fffff800";
      C_p1_PRBS_SADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"00000300";
      C_p2_BEGIN_ADDRESS                      : std_logic_vector(31 downto 0)  := X"00000100";
      C_p2_DATA_MODE                          : std_logic_vector(3 downto 0)  := "0010";
      C_p2_END_ADDRESS                        : std_logic_vector(31 downto 0)  := X"000002ff";
      C_p2_PRBS_EADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"fffffc00";
      C_p2_PRBS_SADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"00000100";
      C_p3_BEGIN_ADDRESS                      : std_logic_vector(31 downto 0)  := X"00000100";
      C_p3_DATA_MODE                          : std_logic_vector(3 downto 0)  := "0010";
      C_p3_END_ADDRESS                        : std_logic_vector(31 downto 0)  := X"000002ff";
      C_p3_PRBS_EADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"fffffc00";
      C_p3_PRBS_SADDR_MASK_POS                : std_logic_vector(31 downto 0)  := X"00000100"

  );
port
(

   clk0            : in std_logic;
   rst0            : in std_logic;
   calib_done      : in std_logic;

         p0_mcb_cmd_en_o                           : out std_logic;
      p0_mcb_cmd_instr_o                        : out std_logic_vector(2 downto 0);
      p0_mcb_cmd_bl_o                           : out std_logic_vector(5 downto 0);
      p0_mcb_cmd_addr_o                         : out std_logic_vector(29 downto 0);
      p0_mcb_cmd_full_i                         : in std_logic;

      p0_mcb_wr_en_o                            : out std_logic;
      p0_mcb_wr_mask_o                          : out std_logic_vector(C_P0_MASK_SIZE - 1 downto 0);
      p0_mcb_wr_data_o                          : out std_logic_vector(C_P0_DATA_PORT_SIZE - 1 downto 0);
      p0_mcb_wr_full_i                          : in std_logic;
      p0_mcb_wr_fifo_counts                     : in std_logic_vector(6 downto 0);

      p0_mcb_rd_en_o                            : out std_logic;
      p0_mcb_rd_data_i                          : in std_logic_vector(C_P0_DATA_PORT_SIZE - 1 downto 0);
      p0_mcb_rd_empty_i                         : in std_logic;
      p0_mcb_rd_fifo_counts                     : in std_logic_vector(6 downto 0);

      p1_mcb_cmd_en_o                           : out std_logic;
      p1_mcb_cmd_instr_o                        : out std_logic_vector(2 downto 0);
      p1_mcb_cmd_bl_o                           : out std_logic_vector(5 downto 0);
      p1_mcb_cmd_addr_o                         : out std_logic_vector(29 downto 0);
      p1_mcb_cmd_full_i                         : in std_logic;

      p1_mcb_wr_en_o                            : out std_logic;
      p1_mcb_wr_mask_o                          : out std_logic_vector(C_P1_MASK_SIZE - 1 downto 0);
      p1_mcb_wr_data_o                          : out std_logic_vector(C_P1_DATA_PORT_SIZE - 1 downto 0);
      p1_mcb_wr_full_i                          : in std_logic;
      p1_mcb_wr_fifo_counts                     : in std_logic_vector(6 downto 0);

      p1_mcb_rd_en_o                            : out std_logic;
      p1_mcb_rd_data_i                          : in std_logic_vector(C_P1_DATA_PORT_SIZE - 1 downto 0);
      p1_mcb_rd_empty_i                         : in std_logic;
      p1_mcb_rd_fifo_counts                     : in std_logic_vector(6 downto 0);

      p2_mcb_cmd_en_o                           : out std_logic;
      p2_mcb_cmd_instr_o                        : out std_logic_vector(2 downto 0);
      p2_mcb_cmd_bl_o                           : out std_logic_vector(5 downto 0);
      p2_mcb_cmd_addr_o                         : out std_logic_vector(29 downto 0);
      p2_mcb_cmd_full_i                         : in std_logic;

      p2_mcb_rd_en_o                            : out std_logic;
      p2_mcb_rd_data_i                          : in std_logic_vector(31 downto 0);
      p2_mcb_rd_empty_i                         : in std_logic;
      p2_mcb_rd_fifo_counts                     : in std_logic_vector(6 downto 0);

      p3_mcb_cmd_en_o                           : out std_logic;
      p3_mcb_cmd_instr_o                        : out std_logic_vector(2 downto 0);
      p3_mcb_cmd_bl_o                           : out std_logic_vector(5 downto 0);
      p3_mcb_cmd_addr_o                         : out std_logic_vector(29 downto 0);
      p3_mcb_cmd_full_i                         : in std_logic;

      p3_mcb_rd_en_o                            : out std_logic;
      p3_mcb_rd_data_i                          : in std_logic_vector(31 downto 0);
      p3_mcb_rd_empty_i                         : in std_logic;
      p3_mcb_rd_fifo_counts                     : in std_logic_vector(6 downto 0);



   vio_modify_enable   : in std_logic;
   vio_data_mode_value : in std_logic_vector(2 downto 0);
   vio_addr_mode_value : in std_logic_vector(2 downto 0);
   cmp_error       : out std_logic;
   error           : out std_logic;
   error_status    : out std_logic_vector(127 downto 0)
);
end component;

-- ========================================================================== --
-- Signal Declarations                                                        --
-- ========================================================================== --

-- Clocks
					-- Clocks
   signal  c3_sys_clk     : std_logic := '0';
   signal  c3_sys_clk_p   : std_logic;
   signal  c3_sys_clk_n   : std_logic;
-- System Reset
   signal  c3_sys_rst   : std_logic := '0';
   signal  c3_sys_rst_i     : std_logic;



-- Design-Top Port Map
   signal  c3_error  : std_logic;
   signal  c3_calib_done : std_logic;
   signal  c3_error_status : std_logic_vector(127 downto 0); 
   signal  mcb3_dram_a : std_logic_vector(C3_MEM_ADDR_WIDTH-1 downto 0);
   signal  mcb3_dram_ba : std_logic_vector(C3_MEM_BANKADDR_WIDTH-1 downto 0);  
   signal  mcb3_dram_ck : std_logic;  
   signal  mcb3_dram_ck_n : std_logic;  
   signal  mcb3_dram_dq : std_logic_vector(C3_NUM_DQ_PINS-1 downto 0);   
   signal  mcb3_dram_dqs   : std_logic;    
   signal  mcb3_dram_dm    : std_logic;   
   signal  mcb3_dram_ras_n : std_logic;   
   signal  mcb3_dram_cas_n : std_logic;   
   signal  mcb3_dram_we_n  : std_logic;    
   signal  mcb3_dram_cke   : std_logic;   
      signal  mcb3_dram_udqs   : std_logic;
   signal mcb3_dram_dqs_vector : std_logic_vector(1 downto 0);
      signal   mcb3_dram_udm :std_logic;     -- for X16 parts
   signal mcb3_dram_dm_vector : std_logic_vector(1 downto 0);
   
   

-- User design  Sim
   signal  c3_clk0 : std_logic;
   signal  c3_rst0 : std_logic;  
   signal  c3_cmp_error : std_logic; 
   signal  c3_vio_modify_enable : std_logic;
   signal  c3_vio_data_mode_value : std_logic_vector(2 downto 0);
   signal  c3_vio_addr_mode_value : std_logic_vector(2 downto 0);
   signal mcb3_command               : std_logic_vector(2 downto 0);
   signal mcb3_enable1                : std_logic;
   signal mcb3_enable2              : std_logic;

     signal  c3_p0_cmd_en                             : std_logic;
  signal  c3_p0_cmd_instr                          : std_logic_vector(2 downto 0);
  signal  c3_p0_cmd_bl                             : std_logic_vector(5 downto 0);
  signal  c3_p0_cmd_byte_addr                      : std_logic_vector(29 downto 0);
  signal  c3_p0_cmd_empty                          : std_logic;
  signal  c3_p0_cmd_full                           : std_logic;
  signal  c3_p0_wr_en                              : std_logic;
  signal  c3_p0_wr_mask                            : std_logic_vector(C3_P0_MASK_SIZE - 1 downto 0);
  signal  c3_p0_wr_data                            : std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
  signal  c3_p0_wr_full                            : std_logic;
  signal  c3_p0_wr_empty                           : std_logic;
  signal  c3_p0_wr_count                           : std_logic_vector(6 downto 0);
  signal  c3_p0_wr_underrun                        : std_logic;
  signal  c3_p0_wr_error                           : std_logic;
  signal  c3_p0_rd_en                              : std_logic;
  signal  c3_p0_rd_data                            : std_logic_vector(C3_P0_DATA_PORT_SIZE - 1 downto 0);
  signal  c3_p0_rd_full                            : std_logic;
  signal  c3_p0_rd_empty                           : std_logic;
  signal  c3_p0_rd_count                           : std_logic_vector(6 downto 0);
  signal  c3_p0_rd_overflow                        : std_logic;
  signal  c3_p0_rd_error                           : std_logic;

  signal  c3_p1_cmd_en                             : std_logic;
  signal  c3_p1_cmd_instr                          : std_logic_vector(2 downto 0);
  signal  c3_p1_cmd_bl                             : std_logic_vector(5 downto 0);
  signal  c3_p1_cmd_byte_addr                      : std_logic_vector(29 downto 0);
  signal  c3_p1_cmd_empty                          : std_logic;
  signal  c3_p1_cmd_full                           : std_logic;
  signal  c3_p1_wr_en                              : std_logic;
  signal  c3_p1_wr_mask                            : std_logic_vector(C3_P1_MASK_SIZE - 1 downto 0);
  signal  c3_p1_wr_data                            : std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
  signal  c3_p1_wr_full                            : std_logic;
  signal  c3_p1_wr_empty                           : std_logic;
  signal  c3_p1_wr_count                           : std_logic_vector(6 downto 0);
  signal  c3_p1_wr_underrun                        : std_logic;
  signal  c3_p1_wr_error                           : std_logic;
  signal  c3_p1_rd_en                              : std_logic;
  signal  c3_p1_rd_data                            : std_logic_vector(C3_P1_DATA_PORT_SIZE - 1 downto 0);
  signal  c3_p1_rd_full                            : std_logic;
  signal  c3_p1_rd_empty                           : std_logic;
  signal  c3_p1_rd_count                           : std_logic_vector(6 downto 0);
  signal  c3_p1_rd_overflow                        : std_logic;
  signal  c3_p1_rd_error                           : std_logic;

  signal  c3_p2_cmd_en                             : std_logic;
  signal  c3_p2_cmd_instr                          : std_logic_vector(2 downto 0);
  signal  c3_p2_cmd_bl                             : std_logic_vector(5 downto 0);
  signal  c3_p2_cmd_byte_addr                      : std_logic_vector(29 downto 0);
  signal  c3_p2_cmd_empty                          : std_logic;
  signal  c3_p2_cmd_full                           : std_logic;
  signal  c3_p2_rd_en                              : std_logic;
  signal  c3_p2_rd_data                            : std_logic_vector(31 downto 0);
  signal  c3_p2_rd_full                            : std_logic;
  signal  c3_p2_rd_empty                           : std_logic;
  signal  c3_p2_rd_count                           : std_logic_vector(6 downto 0);
  signal  c3_p2_rd_overflow                        : std_logic;
  signal  c3_p2_rd_error                           : std_logic;

  signal  c3_p3_cmd_en                             : std_logic;
  signal  c3_p3_cmd_instr                          : std_logic_vector(2 downto 0);
  signal  c3_p3_cmd_bl                             : std_logic_vector(5 downto 0);
  signal  c3_p3_cmd_byte_addr                      : std_logic_vector(29 downto 0);
  signal  c3_p3_cmd_empty                          : std_logic;
  signal  c3_p3_cmd_full                           : std_logic;
  signal  c3_p3_rd_en                              : std_logic;
  signal  c3_p3_rd_data                            : std_logic_vector(31 downto 0);
  signal  c3_p3_rd_full                            : std_logic;
  signal  c3_p3_rd_empty                           : std_logic;
  signal  c3_p3_rd_count                           : std_logic_vector(6 downto 0);
  signal  c3_p3_rd_overflow                        : std_logic;
  signal  c3_p3_rd_error                           : std_logic;

  signal  c3_selfrefresh_enter                     : std_logic;
  signal  c3_selfrefresh_mode                      : std_logic;


   signal  rzq3     : std_logic;
      

   signal   calib_done  : std_logic;
   signal   error  : std_logic;


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


error <= c3_error;
calib_done <= c3_calib_done;

   


   rzq_pulldown3 : PULLDOWN port map(O => rzq3);
      

-- ========================================================================== --
-- DESIGN TOP INSTANTIATION                                                    --
-- ========================================================================== --

design_top : memory_controller generic map
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

C3_SIMULATION   =>      C3_SIMULATION,

C3_CALIB_SOFT_IP      => C3_CALIB_SOFT_IP
) 
port map ( 

    c3_sys_clk  =>         c3_sys_clk,
  c3_sys_rst_i    =>       c3_sys_rst_i,                        

  mcb3_dram_dq       =>    mcb3_dram_dq,  
  mcb3_dram_a        =>    mcb3_dram_a,  
  mcb3_dram_ba       =>    mcb3_dram_ba,
  mcb3_dram_ras_n    =>    mcb3_dram_ras_n,                        
  mcb3_dram_cas_n    =>    mcb3_dram_cas_n,                        
  mcb3_dram_we_n     =>    mcb3_dram_we_n,                          
  mcb3_dram_cke      =>    mcb3_dram_cke,                          
  mcb3_dram_ck       =>    mcb3_dram_ck,                          
  mcb3_dram_ck_n     =>    mcb3_dram_ck_n,       
  mcb3_dram_dqs      =>    mcb3_dram_dqs,                          
  mcb3_dram_udqs  =>       mcb3_dram_udqs,    -- for X16 parts           
		mcb3_dram_udm  =>        mcb3_dram_udm,     -- for X16 parts
  mcb3_dram_dm  =>       mcb3_dram_dm,
    c3_clk0	=>	        c3_clk0,
  c3_rst0		=>        c3_rst0,
	
 
  c3_calib_done      =>    c3_calib_done,
     mcb3_rzq         =>            rzq3,
        
  
     c3_p0_cmd_clk                           =>  (c3_clk0),
   c3_p0_cmd_en                            =>  c3_p0_cmd_en,
   c3_p0_cmd_instr                         =>  c3_p0_cmd_instr,
   c3_p0_cmd_bl                            =>  c3_p0_cmd_bl,
   c3_p0_cmd_byte_addr                     =>  c3_p0_cmd_byte_addr,
   c3_p0_cmd_empty                         =>  c3_p0_cmd_empty,
   c3_p0_cmd_full                          =>  c3_p0_cmd_full,
   c3_p0_wr_clk                            =>  (c3_clk0),
   c3_p0_wr_en                             =>  c3_p0_wr_en,
   c3_p0_wr_mask                           =>  c3_p0_wr_mask,
   c3_p0_wr_data                           =>  c3_p0_wr_data,
   c3_p0_wr_full                           =>  c3_p0_wr_full,
   c3_p0_wr_empty                          =>  c3_p0_wr_empty,
   c3_p0_wr_count                          =>  c3_p0_wr_count,
   c3_p0_wr_underrun                       =>  c3_p0_wr_underrun,
   c3_p0_wr_error                          =>  c3_p0_wr_error,
   c3_p0_rd_clk                            =>  (c3_clk0),
   c3_p0_rd_en                             =>  c3_p0_rd_en,
   c3_p0_rd_data                           =>  c3_p0_rd_data,
   c3_p0_rd_full                           =>  c3_p0_rd_full,
   c3_p0_rd_empty                          =>  c3_p0_rd_empty,
   c3_p0_rd_count                          =>  c3_p0_rd_count,
   c3_p0_rd_overflow                       =>  c3_p0_rd_overflow,
   c3_p0_rd_error                          =>  c3_p0_rd_error,
   c3_p1_cmd_clk                           =>  (c3_clk0),
   c3_p1_cmd_en                            =>  c3_p1_cmd_en,
   c3_p1_cmd_instr                         =>  c3_p1_cmd_instr,
   c3_p1_cmd_bl                            =>  c3_p1_cmd_bl,
   c3_p1_cmd_byte_addr                     =>  c3_p1_cmd_byte_addr,
   c3_p1_cmd_empty                         =>  c3_p1_cmd_empty,
   c3_p1_cmd_full                          =>  c3_p1_cmd_full,
   c3_p1_wr_clk                            =>  (c3_clk0),
   c3_p1_wr_en                             =>  c3_p1_wr_en,
   c3_p1_wr_mask                           =>  c3_p1_wr_mask,
   c3_p1_wr_data                           =>  c3_p1_wr_data,
   c3_p1_wr_full                           =>  c3_p1_wr_full,
   c3_p1_wr_empty                          =>  c3_p1_wr_empty,
   c3_p1_wr_count                          =>  c3_p1_wr_count,
   c3_p1_wr_underrun                       =>  c3_p1_wr_underrun,
   c3_p1_wr_error                          =>  c3_p1_wr_error,
   c3_p1_rd_clk                            =>  (c3_clk0),
   c3_p1_rd_en                             =>  c3_p1_rd_en,
   c3_p1_rd_data                           =>  c3_p1_rd_data,
   c3_p1_rd_full                           =>  c3_p1_rd_full,
   c3_p1_rd_empty                          =>  c3_p1_rd_empty,
   c3_p1_rd_count                          =>  c3_p1_rd_count,
   c3_p1_rd_overflow                       =>  c3_p1_rd_overflow,
   c3_p1_rd_error                          =>  c3_p1_rd_error,
   c3_p2_cmd_clk                           =>  (c3_clk0),
   c3_p2_cmd_en                            =>  c3_p2_cmd_en,
   c3_p2_cmd_instr                         =>  c3_p2_cmd_instr,
   c3_p2_cmd_bl                            =>  c3_p2_cmd_bl,
   c3_p2_cmd_byte_addr                     =>  c3_p2_cmd_byte_addr,
   c3_p2_cmd_empty                         =>  c3_p2_cmd_empty,
   c3_p2_cmd_full                          =>  c3_p2_cmd_full,
   c3_p2_rd_clk                            =>  (c3_clk0),
   c3_p2_rd_en                             =>  c3_p2_rd_en,
   c3_p2_rd_data                           =>  c3_p2_rd_data,
   c3_p2_rd_full                           =>  c3_p2_rd_full,
   c3_p2_rd_empty                          =>  c3_p2_rd_empty,
   c3_p2_rd_count                          =>  c3_p2_rd_count,
   c3_p2_rd_overflow                       =>  c3_p2_rd_overflow,
   c3_p2_rd_error                          =>  c3_p2_rd_error,
   c3_p3_cmd_clk                           =>  (c3_clk0),
   c3_p3_cmd_en                            =>  c3_p3_cmd_en,
   c3_p3_cmd_instr                         =>  c3_p3_cmd_instr,
   c3_p3_cmd_bl                            =>  c3_p3_cmd_bl,
   c3_p3_cmd_byte_addr                     =>  c3_p3_cmd_byte_addr,
   c3_p3_cmd_empty                         =>  c3_p3_cmd_empty,
   c3_p3_cmd_full                          =>  c3_p3_cmd_full,
   c3_p3_rd_clk                            =>  (c3_clk0),
   c3_p3_rd_en                             =>  c3_p3_rd_en,
   c3_p3_rd_data                           =>  c3_p3_rd_data,
   c3_p3_rd_full                           =>  c3_p3_rd_full,
   c3_p3_rd_empty                          =>  c3_p3_rd_empty,
   c3_p3_rd_count                          =>  c3_p3_rd_count,
   c3_p3_rd_overflow                       =>  c3_p3_rd_overflow,
   c3_p3_rd_error                          =>  c3_p3_rd_error
);      

-- user interface

memc3_tb_top_inst :  memc3_tb_top generic map
 (
   C_NUM_DQ_PINS       =>     C3_NUM_DQ_PINS,
   C_MEM_BURST_LEN     =>     C3_MEM_BURST_LEN,
   C_MEM_NUM_COL_BITS  =>     C3_MEM_NUM_COL_BITS,
   C_P0_MASK_SIZE      =>     C3_P0_MASK_SIZE,
   C_P0_DATA_PORT_SIZE =>     C3_P0_DATA_PORT_SIZE,        
   C_P1_MASK_SIZE      =>     C3_P1_MASK_SIZE,        
   C_P1_DATA_PORT_SIZE =>     C3_P1_DATA_PORT_SIZE,        
   C_p0_BEGIN_ADDRESS                      => C3_p0_BEGIN_ADDRESS,
   C_p0_DATA_MODE                          => C3_p0_DATA_MODE,
   C_p0_END_ADDRESS                        => C3_p0_END_ADDRESS,
   C_p0_PRBS_EADDR_MASK_POS                => C3_p0_PRBS_EADDR_MASK_POS,
   C_p0_PRBS_SADDR_MASK_POS                => C3_p0_PRBS_SADDR_MASK_POS,
   C_p1_BEGIN_ADDRESS                      => C3_p1_BEGIN_ADDRESS,
   C_p1_DATA_MODE                          => C3_p1_DATA_MODE,
   C_p1_END_ADDRESS                        => C3_p1_END_ADDRESS,
   C_p1_PRBS_EADDR_MASK_POS                => C3_p1_PRBS_EADDR_MASK_POS,
   C_p1_PRBS_SADDR_MASK_POS                => C3_p1_PRBS_SADDR_MASK_POS,
   C_p2_BEGIN_ADDRESS                      => C3_p2_BEGIN_ADDRESS,
   C_p2_DATA_MODE                          => C3_p2_DATA_MODE,
   C_p2_END_ADDRESS                        => C3_p2_END_ADDRESS,
   C_p2_PRBS_EADDR_MASK_POS                => C3_p2_PRBS_EADDR_MASK_POS,
   C_p2_PRBS_SADDR_MASK_POS                => C3_p2_PRBS_SADDR_MASK_POS,
   C_p3_BEGIN_ADDRESS                      => C3_p3_BEGIN_ADDRESS,
   C_p3_DATA_MODE                          => C3_p3_DATA_MODE,
   C_p3_END_ADDRESS                        => C3_p3_END_ADDRESS,
   C_p3_PRBS_EADDR_MASK_POS                => C3_p3_PRBS_EADDR_MASK_POS,
   C_p3_PRBS_SADDR_MASK_POS                => C3_p3_PRBS_SADDR_MASK_POS
   )
port map
(
   clk0			         => c3_clk0,
   rst0			         => c3_rst0,
   calib_done            => c3_calib_done, 
   cmp_error             => c3_cmp_error,
   error                 => c3_error,
   error_status          => c3_error_status,
   vio_modify_enable     => c3_vio_modify_enable,
   vio_data_mode_value   => c3_vio_data_mode_value,
   vio_addr_mode_value   => c3_vio_addr_mode_value,
   p0_mcb_cmd_en_o                          =>  c3_p0_cmd_en,
   p0_mcb_cmd_instr_o                       =>  c3_p0_cmd_instr,
   p0_mcb_cmd_bl_o                          =>  c3_p0_cmd_bl,
   p0_mcb_cmd_addr_o                        =>  c3_p0_cmd_byte_addr,
   p0_mcb_cmd_full_i                        =>  c3_p0_cmd_full,
   p0_mcb_wr_en_o                           =>  c3_p0_wr_en,
   p0_mcb_wr_mask_o                         =>  c3_p0_wr_mask,
   p0_mcb_wr_data_o                         =>  c3_p0_wr_data,
   p0_mcb_wr_full_i                         =>  c3_p0_wr_full,
   p0_mcb_wr_fifo_counts                    =>  c3_p0_wr_count,
   p0_mcb_rd_en_o                           =>  c3_p0_rd_en,
   p0_mcb_rd_data_i                         =>  c3_p0_rd_data,
   p0_mcb_rd_empty_i                        =>  c3_p0_rd_empty,
   p0_mcb_rd_fifo_counts                    =>  c3_p0_rd_count,
   p1_mcb_cmd_en_o                          =>  c3_p1_cmd_en,
   p1_mcb_cmd_instr_o                       =>  c3_p1_cmd_instr,
   p1_mcb_cmd_bl_o                          =>  c3_p1_cmd_bl,
   p1_mcb_cmd_addr_o                        =>  c3_p1_cmd_byte_addr,
   p1_mcb_cmd_full_i                        =>  c3_p1_cmd_full,
   p1_mcb_wr_en_o                           =>  c3_p1_wr_en,
   p1_mcb_wr_mask_o                         =>  c3_p1_wr_mask,
   p1_mcb_wr_data_o                         =>  c3_p1_wr_data,
   p1_mcb_wr_full_i                         =>  c3_p1_wr_full,
   p1_mcb_wr_fifo_counts                    =>  c3_p1_wr_count,
   p1_mcb_rd_en_o                           =>  c3_p1_rd_en,
   p1_mcb_rd_data_i                         =>  c3_p1_rd_data,
   p1_mcb_rd_empty_i                        =>  c3_p1_rd_empty,
   p1_mcb_rd_fifo_counts                    =>  c3_p1_rd_count,
   p2_mcb_cmd_en_o                          =>  c3_p2_cmd_en,
   p2_mcb_cmd_instr_o                       =>  c3_p2_cmd_instr,
   p2_mcb_cmd_bl_o                          =>  c3_p2_cmd_bl,
   p2_mcb_cmd_addr_o                        =>  c3_p2_cmd_byte_addr,
   p2_mcb_cmd_full_i                        =>  c3_p2_cmd_full,
   p2_mcb_rd_en_o                           =>  c3_p2_rd_en,
   p2_mcb_rd_data_i                         =>  c3_p2_rd_data,
   p2_mcb_rd_empty_i                        =>  c3_p2_rd_empty,
   p2_mcb_rd_fifo_counts                    =>  c3_p2_rd_count,
   p3_mcb_cmd_en_o                          =>  c3_p3_cmd_en,
   p3_mcb_cmd_instr_o                       =>  c3_p3_cmd_instr,
   p3_mcb_cmd_bl_o                          =>  c3_p3_cmd_bl,
   p3_mcb_cmd_addr_o                        =>  c3_p3_cmd_byte_addr,
   p3_mcb_cmd_full_i                        =>  c3_p3_cmd_full,
   p3_mcb_rd_en_o                           =>  c3_p3_rd_en,
   p3_mcb_rd_data_i                         =>  c3_p3_rd_data,
   p3_mcb_rd_empty_i                        =>  c3_p3_rd_empty,
   p3_mcb_rd_fifo_counts                    =>  c3_p3_rd_count
  

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
