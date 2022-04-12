--------------------------------------------------------------------------------
-- Company:       ABH ENGINEERING
-- Engineer:      Aaron Howard
--
-- Create Date:   23:46:03 03/21/2014
-- Design Name:   
-- Module Name:   C:/Users/HowardFamily/Dropbox/VHDL/HOME_PROJECT/DIGIPOT/DIGIPOT/DIGIPOT_TB.vhd
-- Project Name:  DIGIPOT
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: DIGIPOT
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
USE ieee.numeric_std.ALL;
 
ENTITY DIGIPOT_TB IS
END DIGIPOT_TB;
 
ARCHITECTURE behavior OF DIGIPOT_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DIGIPOT
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
			cmf : OUT std_logic;
         cs : OUT  std_logic;
         sdi_sdo : INOUT  std_logic;
         ctrl : IN  std_logic_vector(7 downto 0);
         bgn : IN  std_logic;
         sck : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '1';
   signal ctrl : std_logic_vector(7 downto 0) := (others => '0');
   signal bgn : std_logic := '0';

	--BiDirs
   signal sdi_sdo : std_logic;

 	--Outputs
   signal cs : std_logic;
   signal sck : std_logic;
	signal cmf : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DIGIPOT PORT MAP (
          clk => clk,
          rst => rst,
			 cmf => cmf,
          cs => cs,
          sdi_sdo => sdi_sdo,
          ctrl => ctrl,
          bgn => bgn,
          sck => sck
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
		--pullup set to H to prevent issues
		sdi_sdo <= 'H';
      wait for 100 ns;	
      rst <= '0';
      ctrl <= B"1010_1010";
		wait for 100 ns;
      bgn <= '1';
      wait;
   end process;

END;
