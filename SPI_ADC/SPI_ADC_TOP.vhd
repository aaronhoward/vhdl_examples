----------------------------------------------------------------------------------
-- Company:        ABH Engineering
-- Engineer:       Aaron Howard
-- 
-- Create Date:    19:05:17 04/08/2014 
-- Design Name: 
-- Module Name:    SPI_ADC_TOP - Behavioral 
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


entity SPI_ADC_TOP is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           sck : out  STD_LOGIC;
           sdo : out  STD_LOGIC;
           sdi : in  STD_LOGIC;
           cs_n : out  STD_LOGIC;
           bgn : in  STD_LOGIC;
           ch_sel : in  STD_LOGIC;
           status : out  STD_LOGIC_VECTOR (7 downto 0));
end SPI_ADC_TOP;

architecture Behavioral of SPI_ADC_TOP is

COMPONENT SPI_ADC
	PORT(
		rst : IN std_logic;
		clk : IN std_logic;
		sdi : IN std_logic;
		bgn : IN std_logic;
		ch_sel : IN std_logic;          
		sck : OUT std_logic;
		sdo : OUT std_logic;
		cs_n : OUT std_logic;
		conv_data : OUT std_logic_vector(9 downto 0);
		done : OUT std_logic --will be muxed into rolling leds 
		);
	END COMPONENT;


signal conv_data : std_logic_vector(9 downto 0) := (others => '0');

--This is a counter to switch between lsb and msb of conv_data every ten seconds
constant ten_sec : std_logic_vector(31 downto 0) := X"1DCD64FF"; 
signal reg_dsp_cnt : std_logic_vector(31 downto 0) := (others => '0');
signal disp_bit : std_logic := '0';
signal done_val : std_logic := '0';



begin

Inst_SPI_ADC: SPI_ADC PORT MAP(
		rst => rst,
		clk => clk,
		sck => sck,
		sdo => sdo,
		sdi => sdi,
		cs_n => cs_n,
		bgn => bgn,
		ch_sel => ch_sel,
		conv_data => conv_data,
		done => done_val
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
status <= conv_data(7 downto 0) when disp_bit = '0' else done_val&"00000"&conv_data(9 downto 8);

end Behavioral;

