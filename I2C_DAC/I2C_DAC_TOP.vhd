----------------------------------------------------------------------------------
-- Company:        ABH Engineering
-- Engineer:       Aaron Howard
-- 
-- Create Date:    20:07:15 03/31/2014 
-- Design Name: 
-- Module Name:    I2C_DAC_TOP - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies:  A0 is tied to ground
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity I2C_DAC_TOP is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  bgn : in STD_LOGIC;
           data_val : in  STD_LOGIC_VECTOR (7 downto 0);
           sda : inout  STD_LOGIC;
           scl : out  STD_LOGIC;
           done : out  STD_LOGIC;
			  cmf : out STD_LOGIC);
end I2C_DAC_TOP;

architecture Behavioral of I2C_DAC_TOP is

signal conc_val : std_logic_vector(11 downto 0);


COMPONENT I2C_DAC is
    Port ( sda : inout  STD_LOGIC;
	        cmf : out STD_LOGIC;
			  val : in STD_LOGIC_VECTOR(11 downto 0);
			  bgn : in STD_LOGIC;
			  done : out STD_LOGIC;
           scl : out  STD_LOGIC;
           rst : in  STD_LOGIC;
           clk : in  STD_LOGIC);
end COMPONENT;


begin

process(data_val)
begin
conc_val <= data_val & "0000";
end process;



		Inst_I2C_DAC: I2C_DAC PORT MAP(
		sda => sda,
		cmf => cmf,
		val => conc_val,
		bgn => bgn,
		done => done,
		scl => scl,
		rst => rst,
		clk => clk 
	);


end Behavioral;

