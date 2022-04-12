----------------------------------------------------------------------------------
-- Company:        ABH Engineering
-- Engineer:       Aaron Howard
-- 
-- Create Date:    21:05:50 04/18/2014 
-- Design Name: 
-- Module Name:    mpr121_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity mpr121_top is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           sda : inout  STD_LOGIC;
           scl : out  STD_LOGIC;
           status : out  STD_LOGIC_VECTOR (7 downto 0);
           irq : in  STD_LOGIC);
end mpr121_top;

architecture Behavioral of mpr121_top is


COMPONENT mpr121
	PORT(
		rst : IN std_logic;
		clk : IN std_logic;
		irq : IN std_logic;    
		sda : INOUT std_logic;      
		cmf : OUT std_logic;
		done : OUT std_logic;
		data_out : OUT std_logic_vector(11 downto 0);
		scl : OUT std_logic
		);
	END COMPONENT;


signal data_val : std_logic_vector(11 downto 0) := (others => '0');

--This is a counter to switch between lsb and msb of conv_data every ten seconds
constant ten_sec : std_logic_vector(31 downto 0) := X"1DCD64FF"; 
signal reg_dsp_cnt : std_logic_vector(31 downto 0) := (others => '0');
signal disp_bit : std_logic := '0';
signal done_val : std_logic := '0';
signal cmf_val : std_logic := '0';

begin

	Inst_mpr121: mpr121 PORT MAP(
		rst => rst,
		clk => clk,
		cmf => cmf_val,
		done => done_val,
		data_out => data_val,
		scl => scl,
		sda => sda,
		irq => irq
	);

DISP: process(clk,rst)
--Displays byte count and byte values    
begin
if rst = '1' then
   reg_dsp_cnt <= (others => '0');
   disp_bit <= '0';	
elsif (clk'event and clk = '1') then
   if reg_dsp_cnt = ten_sec then
	 --reset counter
	 reg_dsp_cnt <= (others => '0');
    --toggle display bit
	 disp_bit <= not disp_bit;
   else 
    reg_dsp_cnt <= reg_dsp_cnt+1;
	end if;
end if;
end process DISP;

--concurrent statements
status <= data_val(7 downto 0) when disp_bit = '0' else done_val&cmf_val&"00"&data_val(11 downto 8);


end Behavioral;

