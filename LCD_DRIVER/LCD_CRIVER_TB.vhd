--------------------------------------------------------------------------------
-- Company:       ABH Engineering
-- Engineer:      Aaron Howard
--
-- Create Date:   21:05:23 02/23/2014
-- Design Name:   
-- Module Name:   C:/Users/HowardFamily/Dropbox/VHDL/HOME_PROJECT/LCD_DRIVER/LCD_DRIVER/LCD_CRIVER_TB.vhd
-- Project Name:  LCD_DRIVER
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: LCD_DRIVER
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY LCD_CRIVER_TB IS
END LCD_CRIVER_TB;
 
ARCHITECTURE behavior OF LCD_CRIVER_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT LCD_DRIVER
    PORT(
         RST : IN  std_logic;
         CLK : IN  std_logic;
         RS : OUT  std_logic;
         RW : OUT  std_logic;
         DATA : INOUT  std_logic_vector(7 downto 0);
         COMM : IN  std_logic_vector(1 downto 0);
         CHG : IN  std_logic;
         E : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal RST : std_logic := '1';
   signal CLK : std_logic := '0';
   signal COMM : std_logic_vector(1 downto 0) := (others => '0');
   signal CHG : std_logic := '0';

	--BiDirs
   signal DATA : std_logic_vector(7 downto 0);

 	--Outputs
   signal RS : std_logic;
   signal RW : std_logic;
   signal E : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: LCD_DRIVER PORT MAP (
          RST => RST,
          CLK => CLK,
          RS => RS,
          RW => RW,
          DATA => DATA,
          COMM => COMM,
          CHG => CHG,
          E => E
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 
 
  

   -- Stimulus process
   stim_proc: process
   begin		
      wait for 100 ns;	
      RST <= '0';
		chg <= '1';
     
      wait;
   end process;

END;
