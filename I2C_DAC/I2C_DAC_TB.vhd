--------------------------------------------------------------------------------
-- Company:       ABH Engineering
-- Engineer:      Aaron Howard
--
-- Create Date:   21:52:06 03/29/2014
-- Design Name:   
-- Module Name:   C:/Users/HowardFamily/Dropbox/VHDL/HOME_PROJECT/I2C_DAC/I2C_DAC/I2C_DAC_TB.vhd
-- Project Name:  I2C_DAC
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: I2C_DAC
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
 
ENTITY I2C_DAC_TB IS
END I2C_DAC_TB;
 
ARCHITECTURE behavior OF I2C_DAC_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT I2C_DAC
    PORT(
         sda : INOUT  std_logic;
         cmf : OUT  std_logic;
         val : IN  std_logic_vector(11 downto 0);
         bgn : IN  std_logic;
			done : OUT std_logic;
         scl : OUT  std_logic;
         rst : IN  std_logic;
         clk : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal val : std_logic_vector(11 downto 0) := (others => '0');
   signal bgn : std_logic := '0';
   signal rst : std_logic := '1';
   signal clk : std_logic := '0';

	--BiDirs
   signal sda : std_logic := 'L'; --simulates pulldown for ack

 	--Outputs
   signal cmf : std_logic;
   signal scl : std_logic;
	signal done : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: I2C_DAC PORT MAP (
          sda => sda,
          cmf => cmf,
          val => val,
          bgn => bgn,
			 done => done,
          scl => scl,
          rst => rst,
          clk => clk
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
		val <= X"AAA";
		wait for 100 ns;
		bgn <= '1';
		wait until done = '1';
		bgn <= '0';
		wait for 100 ns;
		val <= X"555";
		wait for 100 ns;
		bgn <= '1';
      wait;
   end process;

END;
