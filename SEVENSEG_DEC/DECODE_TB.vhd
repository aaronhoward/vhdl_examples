--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:01:45 09/15/2013
-- Design Name:   
-- Module Name:   C:/DIGILENT_EXAMPLES/SEVENSEG_DEC/DECODE_TB.vhd
-- Project Name:  SEVENSEG_DEC
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SEVEN_SEG_DECODE
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
USE ieee.std_logic_UNSIGNED.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY DECODE_TB IS
END DECODE_TB;
 
ARCHITECTURE behavior OF DECODE_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SEVEN_SEG_DECODE
    PORT(
         x : IN  std_logic_vector(3 downto 0);
         decode : OUT  std_logic_vector(6 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal x : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal decode : std_logic_vector(6 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SEVEN_SEG_DECODE PORT MAP (
          x => x,
          decode => decode
        );

 
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
      x <= x+1;
      -- insert stimulus here 

      --wait;
   end process;

END;
