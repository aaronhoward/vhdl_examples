--------------------------------------------------------------------------------
-- Company:       ABH Engineering
-- Engineer:      Aaron Howard
--
-- Create Date:   21:55:43 04/04/2014
-- Design Name:   
-- Module Name:   C:/Users/HowardFamily/Dropbox/VHDL/HOME_PROJECT/SPI_ADC/SPI_ADC/SPI_ADC_TB.vhd
-- Project Name:  SPI_ADC
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SPI_ADC
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
  
ENTITY SPI_ADC_TB IS
END SPI_ADC_TB;
 
ARCHITECTURE behavior OF SPI_ADC_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SPI_ADC
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         sck : OUT  std_logic;
         sdo : OUT  std_logic;
         sdi : IN  std_logic;
         cs_n : OUT  std_logic;
         bgn : IN  std_logic;
         ch_sel : IN  std_logic;
			conv_data : out STD_LOGIC_VECTOR(9 downto 0);
         done : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '1';
   signal clk : std_logic := '0';
   signal sdi : std_logic := 'H';
   signal bgn : std_logic := '0';
   signal ch_sel : std_logic := '0';

 	--Outputs
   signal sck : std_logic;
   signal sdo : std_logic;
   signal cs_n : std_logic;
   signal done : std_logic;
	signal conv_data : std_logic_vector(9 downto 0);

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SPI_ADC PORT MAP (
          rst => rst,
          clk => clk,
          sck => sck,
          sdo => sdo,
          sdi => sdi,
          cs_n => cs_n,
          bgn => bgn,
          ch_sel => ch_sel,
			 conv_data => conv_data,
          done => done
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
      sdi <= 'H';	
      wait for 100 ns;
      rst <= '0';		
      wait for 100 ns;
      ch_sel <= '1';
		bgn <= '1';
		wait until done = '0';
		bgn <= '0';
		wait until done = '1';
		sdi <= 'L';	
		ch_sel <= '0';
		bgn <= '1';
		wait until done = '0';
		bgn <= '0';
		wait until done = '1';
		sdi <= 'H';
		ch_sel <= '1';
		bgn <= '1';
      wait;
   end process;

END;
