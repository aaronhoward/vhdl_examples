----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:17:01 09/15/2013 
-- Design Name: 
-- Module Name:    SEVEN_SEG_TOP - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SEVEN_SEG_TOP is
    Port ( an : out  STD_LOGIC_VECTOR (3 downto 0);
           seg : out  STD_LOGIC_VECTOR (0 to 6);
           dp : out  STD_LOGIC;
           sw : in  STD_LOGIC_VECTOR (7 downto 0));
end SEVEN_SEG_TOP;

architecture Behavioral of SEVEN_SEG_TOP is

component SEVEN_SEG_DECODE is
    PORT ( x : in STD_LOGIC_VECTOR (3 downto 0);
	        decode : out STD_LOGIC_VECTOR (6 downto 0));
end component;

begin

an(3) <= sw(7);
an(2) <= sw(6);
an(1) <= sw(5);
an(0) <= sw(4);
dp <= '1';

U1: SEVEN_SEG_DECODE port map
 ( x => sw(3 downto 0),
   decode => seg);
end Behavioral;

