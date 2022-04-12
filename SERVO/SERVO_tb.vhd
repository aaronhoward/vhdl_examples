--------------------------------------------------------------------------------
-- Company:       ABH Engineering
-- Engineer:      Aaron Howard
--
-- Create Date:   21:47:40 03/03/2014
-- Design Name:   
-- Module Name:   C:/Users/HowardFamily/Dropbox/VHDL/HOME_PROJECT/SERVO/SERVO/Servo_tb.vhd
-- Project Name:  SERVO
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Servo
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

 
ENTITY Servo_tb IS
END Servo_tb;
 
ARCHITECTURE behavior OF Servo_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Servo
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         pwm : OUT  std_logic;
         duty : IN  std_logic_vector(19 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '1';
   signal duty : std_logic_vector(19 downto 0) := (others => '0');

 	--Outputs
   signal pwm : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Servo PORT MAP (
          clk => clk,
          rst => rst,
          pwm => pwm,
          duty => duty
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
      duty <= X"0D6D8";
      wait for 40 ms; 
      duty <= X"107AC";
		wait for 40 ms; 
      duty <= X"17318";
      wait;
   end process;

END;
