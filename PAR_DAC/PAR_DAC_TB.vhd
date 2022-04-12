--------------------------------------------------------------------------------
-- Company:        ABH Engineering
-- Engineer:       Aaron Howard
--
-- Create Date:   11:52:02 04/03/2014
-- Design Name:   
-- Module Name:   C:/Users/HowardFamily/Dropbox/VHDL/HOME_PROJECT/PAR_DAC/PAR_DAC/PAR_DAC_TB.vhd
-- Project Name:  PAR_DAC
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: PAR_DAC
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
 
ENTITY PAR_DAC_TB IS
END PAR_DAC_TB;
 
ARCHITECTURE behavior OF PAR_DAC_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PAR_DAC
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         ldac_n : OUT  std_logic;
         cs_n : OUT  std_logic;
         we_n : OUT  std_logic;
         clr_n : OUT  std_logic;
         pd_n : OUT  std_logic;
         data : OUT  std_logic_vector(7 downto 0);
         bgn : IN  std_logic;
         done : OUT  std_logic;
         data_ld : IN  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '1';
   signal clk : std_logic := '0';
   signal bgn : std_logic := '0';
   signal data_ld : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal ldac_n : std_logic;
   signal cs_n : std_logic;
   signal we_n : std_logic;
   signal clr_n : std_logic;
   signal pd_n : std_logic;
   signal data : std_logic_vector(7 downto 0);
   signal done : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PAR_DAC PORT MAP (
          rst => rst,
          clk => clk,
          ldac_n => ldac_n,
          cs_n => cs_n,
          we_n => we_n,
          clr_n => clr_n,
          pd_n => pd_n,
          data => data,
          bgn => bgn,
          done => done,
          data_ld => data_ld
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
      wait for 100 ns;	
      rst <= '0';
      wait for 100 ns;
      data_ld <= X"AA";
		wait for 100 ns;
		bgn <= '1';
      wait;
   end process;

END;
