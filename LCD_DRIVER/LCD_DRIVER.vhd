----------------------------------------------------------------------------------
-- Company:        ABH Engineering
-- Engineer:       Aaron Howard
-- 
-- Create Date:    14:19:05 02/22/2014 
-- Design Name: 
-- Module Name:    LCD_DRIVER - Behavioral 
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



entity LCD_DRIVER is
    Port ( RST : in STD_LOGIC;
	        CLK : in STD_LOGIC;
	        RS : out  STD_LOGIC := '0';
           RW : out  STD_LOGIC := '0';
           DATA : out  STD_LOGIC_VECTOR (7 downto 0);
			  COMM : in STD_LOGIC_VECTOR(1 downto 0); -- direction command 
			  CHG : in STD_LOGIC;
           E : out  STD_LOGIC := '0');
end LCD_DRIVER;

architecture Behavioral of LCD_DRIVER is

type state_type is (start,init,proc1,proc2,proc3,setup1,setup2,setup3,setup4,comm_wait,
write1_clr,write1);
signal state : state_type := start;  
--100ms delay for init process
constant init_delay: std_logic_vector(23 downto 0) := X"4C4B3F";  
constant data_cyl: std_logic_vector(19 downto 0) := X"1869F";
constant data_cyl2: std_logic_vector(19 downto 0) := X"30D3F";
constant data_cyl3: std_logic_vector(19 downto 0) := X"493DF";
signal delay_cnt: std_logic_vector(23 downto 0) := (others => '0'); 
signal write_cnt: std_logic_vector(3 downto 0) := (others => '0'); 
signal data_dir: std_logic := '0'; -- direction bit for LCD data
signal value: std_logic_vector(7 downto 0) := (others => '0');
--three letter codes will be used for directon 
signal dir1: std_logic_vector(7 downto 0) := (others => '0');
signal dir2: std_logic_vector(7 downto 0) := (others => '0');
signal dir3: std_logic_vector(7 downto 0) := (others => '0');
--control for rising edge detection for new data
signal cntrl : std_logic_vector(2 downto 0) := (others => '0');

begin

data <= value when data_dir = '1' else (others => '0');

LCD_DRIVER: process(RST,CLK) 
 begin
  if RST = '1' then
   state <= init;
   delay_cnt <= (others => '0');
	write_cnt <= (others => '0');
   data_dir <= '0';
   value <= (others => '0');
   dir1 <= (others => '0');
	dir2 <= (others => '0');
	dir3 <= (others => '0');
	RS <= '0';
   RW <= '0';
   E <= '0';
   cntrl <= (others => '0'); 	
  elsif (CLK'event and CLK = '1') then
    case state is
     when start =>
	   state <= init;
      delay_cnt <= (others => '0');
		write_cnt <= (others => '0');
      data_dir <= '0';
      value <= (others => '0');
		dir1 <= (others => '0');
	   dir2 <= (others => '0');
	   dir3 <= (others => '0');
	   RS <= '0';
      RW <= '0';
      E <= '0';
		cntrl <= (others => '0');
	  when init =>
	   delay_cnt <= delay_cnt+1;
		data_dir <= '1';
		RS <= '0';
      RW <= '0';
      E <= '0';
      value <= B"0011_1000";
		if delay_cnt = init_delay then	
			state <= proc1;
			delay_cnt <= (others => '0');
      end if;
	  when proc1 =>
      delay_cnt <= delay_cnt+1;
		data_dir <= '1';
		RS <= '0';
      RW <= '0';
		if delay_cnt = data_cyl then	
			value <= B"0011_1000";
      end if;		
		if delay_cnt = data_cyl2 then	
			E <= '1';
      end if;
      if delay_cnt = data_cyl3 then	
			E <= '0';
			state <= proc2;
			delay_cnt <= (others => '0');
      end if;	
	 when proc2 =>
      delay_cnt <= delay_cnt+1;
		data_dir <= '1';
		RS <= '0';
      RW <= '0';
		if delay_cnt = data_cyl then	
         value <= B"0011_1000";		
      end if;		
		if delay_cnt = data_cyl2 then	
			E <= '1';
      end if;
      if delay_cnt = data_cyl3 then	
			E <= '0';
			state <= proc3;
			delay_cnt <= (others => '0');
      end if;	  
	 when proc3 =>
      delay_cnt <= delay_cnt+1;
		data_dir <= '1';
		RS <= '0';
      RW <= '0';
		if delay_cnt = data_cyl then	
         value <= B"0011_1000";
      end if;		
		if delay_cnt = data_cyl2 then	
			E <= '1';
      end if;
      if delay_cnt = data_cyl3 then	
			E <= '0';
			state <= setup1;
			delay_cnt <= (others => '0');
      end if;
	  when setup1 =>
      delay_cnt <= delay_cnt+1;
		data_dir <= '1';
		RS <= '0';
      RW <= '0';
		if delay_cnt = data_cyl then	
			--FUNCTION SET
         value <= B"0011_1000";
      end if;		
		if delay_cnt = data_cyl2 then	
			E <= '1';
      end if;
      if delay_cnt = data_cyl3 then	
			E <= '0';
			state <= setup2;
			delay_cnt <= (others => '0');
      end if;	
	  when setup2 =>
      delay_cnt <= delay_cnt+1;
		data_dir <= '1';
		RS <= '0';
      RW <= '0';
		if delay_cnt = data_cyl then	
		--DISPLAY ON
			value <= B"0000_1100";	
      end if;
      if delay_cnt = data_cyl2 then	
			E <= '1';
      end if;		
		if delay_cnt = data_cyl3 then	
			E <= '0';
			state <= setup3;
			delay_cnt <= (others => '0');
      end if;  
	  when setup3 =>
      delay_cnt <= delay_cnt+1;
		data_dir <= '1';
		RS <= '0';
      RW <= '0';
		if delay_cnt = data_cyl then	
			--DISPLAY CLEAR
			value <= B"0000_0001";
      end if;
      if delay_cnt = data_cyl2 then	
			E <= '1';
      end if;		
		if delay_cnt = data_cyl3 then	
			E <= '0';
			state <= setup4;
			delay_cnt <= (others => '0');
      end if;
	 when setup4 =>
      delay_cnt <= delay_cnt+1;
		data_dir <= '1';
		RS <= '0';
      RW <= '0';
		if delay_cnt = data_cyl then	
			--ENTRY MODE
			value <= B"0000_0110";
      end if;	
      if delay_cnt = data_cyl2 then	
			E <= '1';
      end if;
		if delay_cnt = data_cyl3 then	
			E <= '0';
			state <= comm_wait;
			delay_cnt <= (others => '0');
      end if;
	 when comm_wait =>
		--LEFT SHIFT
	   cntrl(2 DOWNTO 0) <= cntrl(1 DOWNTO 0)&CHG;
		data_dir <= '1';
		RS <= '0';
      RW <= '0';
      E <= '0';  
	    if cntrl(2) = '0' and cntrl(1) = '1' then
		  case COMM is
		   when B"00" => --forward
			 dir1 <=B"0100_0110"; --F 
			 dir2 <=B"0101_0111"; --W
			 dir3 <=B"0100_0100"; --D 
		    state <= write1_clr;	 
			when B"01" => --reverse
			 dir1 <=B"0101_0010"; --R
			 dir2 <=B"0101_0110"; --V 
			 dir3 <=B"0101_0011"; --S
          state <= write1_clr;			 
         when B"10" => --right
          dir1 <=B"0101_0010"; --R
			 dir2 <=B"0100_1000"; --H 
			 dir3 <=B"0101_0100"; --T
          state <= write1_clr;			 
         when B"11" => --left
			 dir1 <=B"0100_1100"; --L
			 dir2 <=B"0100_0110"; --F 
			 dir3 <=B"0101_0100"; --T
          state <= write1_clr;			 
	      when others =>
         null;			
		  end case;
	    end if;
	when write1_clr =>
      delay_cnt <= delay_cnt+1;
		data_dir <= '1';
		RS <= '0';
      RW <= '0';
		if delay_cnt = data_cyl then	
			--DISPLAY CLEAR
			value <= B"0000_0001";
      end if;
      if delay_cnt = data_cyl2 then	
			E <= '1';
      end if;		
		if delay_cnt = data_cyl3 then	
			state <= write1;
			E <= '0';
			delay_cnt <= (others => '0');
      end if;	
	 when write1 =>
      delay_cnt <= delay_cnt+1;
		data_dir <= '1';
      RW <= '0';
	   if delay_cnt = data_cyl then	
		   write_cnt <= write_cnt+1;
			RS <= '1';
			if write_cnt = 0 then
			 value <= dir1;
			elsif write_cnt = 1 then
			 value <= dir2;
			elsif write_cnt = 2 then
			 value <= dir3;
			else 
			 value <= (others => '0');
			end if;
      end if;
      if delay_cnt = data_cyl2 then	
			if write_cnt < 4 then
			E <= '1';
			end if;
      end if;		
		if delay_cnt = data_cyl3 then	
			E <= '0';
			delay_cnt <= (others => '0');
			 if write_cnt = 4 then
			   RS <= '0';   
				state <= comm_wait;
				write_cnt <= (others => '0');
         else 			
			   state <= write1;
			end if;
      end if;
	 end case;
  end if; 
end process LCD_DRIVER;

end Behavioral;

