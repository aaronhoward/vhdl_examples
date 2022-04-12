--------------------------------------------------------------------------------
-- Company:       ABH Engineering
-- Engineer:      Aaron Howard
--
-- Create Date:   22:20:59 04/17/2014
-- Design Name:   
-- Module Name:   C:/Users/HowardFamily/Dropbox/VHDL/HOME_PROJECT/mpr121/mpr121/mpr121_tb.vhd
-- Project Name:  mpr121
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: mpr121
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
  
ENTITY mpr121_tb IS
END mpr121_tb;
 
ARCHITECTURE behavior OF mpr121_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT mpr121
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         cmf : OUT  std_logic;
         done : OUT  std_logic;
         data_out : OUT  std_logic_vector(11 downto 0);
         scl : OUT  std_logic;
         sda : INOUT  std_logic;
         irq : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '1';
   signal clk : std_logic := '0';
   signal irq : std_logic := '1';

	--BiDirs
   signal sda : std_logic;

 	--Outputs
   signal cmf : std_logic;
   signal done : std_logic;
   signal data_out : std_logic_vector(11 downto 0);
   signal scl : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: mpr121 PORT MAP (
          rst => rst,
          clk => clk,
          cmf => cmf,
          done => done,
          data_out => data_out,
          scl => scl,
          sda => sda,
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
