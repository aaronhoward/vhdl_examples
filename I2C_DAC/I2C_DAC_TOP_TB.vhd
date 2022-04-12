--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:07:44 03/31/2014
-- Design Name:   
-- Module Name:   C:/Users/HowardFamily/Dropbox/VHDL/HOME_PROJECT/I2C_DAC/I2C_DAC/I2C_DAC_TOP_TB.vhd
-- Project Name:  I2C_DAC
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: I2C_DAC_TOP
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
 
 
ENTITY I2C_DAC_TOP_TB IS
END I2C_DAC_TOP_TB;
 
ARCHITECTURE behavior OF I2C_DAC_TOP_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT I2C_DAC_TOP
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         bgn : IN  std_logic;
         data_val : IN  std_logic_vector(7 downto 0);
         sda : INOUT  std_logic;
         scl : OUT  std_logic;
         done : OUT  std_logic;
         cmf : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '1';
   signal clk : std_logic := '0';
   signal bgn : std_logic := '0';
   signal data_val : std_logic_vector(7 downto 0) := B"1010_1010";

	--BiDirs
   signal sda : std_logic;

 	--Outputs
   signal scl : std_logic;
   signal done : std_logic;
   signal cmf : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: I2C_DAC_TOP PORT MAP (
          rst => rst,
          clk => clk,
          bgn => bgn,
          data_val => data_val,
          sda => sda,
          scl => scl,
          done => done,
          cmf => cmf
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
      -- hold reset state for 100 ns.
		sda <= 'L';
      wait for 100 ns;	
      rst <= '0';
		wait for 100 ns;
		bgn <= '1';
		
      

      wait;
   end process;

END;
