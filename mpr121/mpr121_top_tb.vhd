--------------------------------------------------------------------------------
-- Company:       ABH Engineering
-- Engineer:      Aaron Howard
--
-- Create Date:   21:32:06 04/18/2014
-- Design Name:   
-- Module Name:   C:/Users/HowardFamily/Dropbox/VHDL/HOME_PROJECT/mpr121/mpr121/mpr121_top_tb.vhd
-- Project Name:  mpr121
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: mpr121_top
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
  
ENTITY mpr121_top_tb IS
END mpr121_top_tb;
 
ARCHITECTURE behavior OF mpr121_top_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT mpr121_top
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         sda : INOUT  std_logic;
         scl : OUT  std_logic;
         status : OUT  std_logic_vector(7 downto 0);
         irq : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '1';
   signal clk : std_logic := '0';
   signal irq : std_logic := '0';

	--BiDirs
   signal sda : std_logic;

 	--Outputs
   signal scl : std_logic;
   signal status : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: mpr121_top PORT MAP (
          rst => rst,
          clk => clk,
          sda => sda,
          scl => scl,
          status => status,
          irq => irq
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
      wait for 100 ns;	
      rst <= '0'; 
      wait for 100 ns;	
      irq <= '0';	
      wait;
   end process;

END;
