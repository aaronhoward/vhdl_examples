----------------------------------------------------------------------------------
-- Company: 			ABH ENGINEERING
-- Engineer: 			AARON HOWARD
-- 
-- Create Date:    13:30:44 09/15/2013 
-- Design Name: 
-- Module Name:    SEVEN_SEG_DECODE - Behavioral 
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

entity SEVEN_SEG_DECODE is
    Port ( x : in  STD_LOGIC_VECTOR (3 downto 0);
           decode : out  STD_LOGIC_VECTOR (6 downto 0));
end SEVEN_SEG_DECODE;

architecture Behavioral of SEVEN_SEG_DECODE is

begin

P1: process(x)
		begin		--common anode 1 is off
			case x is					   --abcdefg
				when X"0"   => decode <= "0000001";  --0
				when X"1"   => decode <= "1001111";  --1
				when X"2"   => decode <= "0010010";  --2
				when X"3"   => decode <= "0000110";  --3
				when X"4"   => decode <= "1001100";  --4
				when X"5"   => decode <= "0100100";  --5
				when X"6"   => decode <= "0100000";  --6
				when X"7"   => decode <= "0001111";  --7
				when X"8"   => decode <= "0000000";  --8
				when X"9"   => decode <= "0001100";  --9
				when X"A"   => decode <= "0001000";  --A
				when X"B"   => decode <= "1100000";  --b
				when X"C"   => decode <= "0110001";  --C
				when X"D"   => decode <= "1000010";  --d
				when X"E"   => decode <= "0110000";  --E
				when others => decode <= "0111000";  --F
			end case;
		end process;
end Behavioral;

