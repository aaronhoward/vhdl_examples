----------------------------------------------------------------------------------
-- Company:        ABH Engineering
-- Engineer:       Aaron Howard
-- 
-- Create Date:    10:14:42 04/03/2014 
-- Design Name: 
-- Module Name:    PAR_DAC - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies:   Gain and Buf are both tied to zero
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity PAR_DAC is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           ldac_n : out  STD_LOGIC := '1';
           cs_n : out  STD_LOGIC := '1';
           we_n : out  STD_LOGIC := '1';
           clr_n : out  STD_LOGIC := '1';
           pd_n : out  STD_LOGIC := '1';
           data : out  STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
           bgn : in  STD_LOGIC;
           done : out  STD_LOGIC := '1';
           data_ld : in  STD_LOGIC_VECTOR (7 downto 0));
end PAR_DAC;

architecture Behavioral of PAR_DAC is

type state_type is (init,load,slct,clear_n,clear,wrt_inreg_n,wrt_inreg,ld_dacreg_n,ld_dacreg,dslct);
signal state : state_type := init; 
--rising edge detector shift register
signal cntrl   : std_logic_vector(2 downto 0) := (others => '0');
--this will be used as a counter to control state to state transitions
signal delay_cnt: natural range 0 to 3;

begin

PAR_DAC_DRIVER: process(rst,clk) 
 begin
  if rst = '1' then
		state <= init;
		delay_cnt <= 0;
		ldac_n <= '1';
		cs_n <= '1';
		we_n <= '1';
		clr_n <= '1';
		pd_n <= '1';
		data <= (others => '0');
		done <= '1';
		cntrl(2 DOWNTO 0) <= (others => '0'); 
  --This is based off of a 50MHz clock state to state 20ns		
  elsif (clk'event and clk = '1') then
    --controls delay of states  
    delay_cnt <= delay_cnt+1;
    case state is
     when init =>
	   state <= load;
      delay_cnt <= 0;
		ldac_n <= '1';
		cs_n <= '1';
		we_n <= '1';
      clr_n <= '1';
		pd_n <= '1';
		data <= (others => '0');
		done <= '1';
		cntrl(2 DOWNTO 0) <= (others => '0');			
	  when load =>
	   --rising edge detection for bgn signal
	   cntrl(2 DOWNTO 0) <= cntrl(1 DOWNTO 0)&bgn;
	   delay_cnt <= 0;
		ldac_n <= '1';
		cs_n <= '1';
		we_n <= '1';
      clr_n <= '1';
		pd_n <= '1';
		if (cntrl(2) = '0' and cntrl(1) = '1') then 
		data <= data_ld;
		state <= slct;
		--writing process has begun
		done <= '0';
	   end if;	
	 when  slct=>
      ldac_n <= '1';
		cs_n <= '0';
		we_n <= '1';
      clr_n <= '1';
		pd_n <= '1';
		--writing process has begun
		done <= '0';
		--80ns delay
		if delay_cnt = 3 then
		delay_cnt <= 0;
      state <= clear_n;
		end if;
    when  clear_n=>
	   --This state will clear internal registers
      ldac_n <= '1';
		cs_n <= '0';
		we_n <= '1';
      clr_n <= '0';
		pd_n <= '1';
		--writing process has begun
		done <= '0';
		--80ns delay
		if delay_cnt = 3 then
		delay_cnt <= 0;
      state <= clear;
		end if;
    when  clear=>
	   --This state will clear internal registers
      ldac_n <= '1';
		cs_n <= '0';
		we_n <= '1';
      clr_n <= '1';
		pd_n <= '1';
		--writing process has begun
		done <= '0';
		--80ns delay
		if delay_cnt = 3 then
		delay_cnt <= 0;
      state <= wrt_inreg_n;
		end if;
    when  wrt_inreg_n=>
	   --This state will clear internal registers
      ldac_n <= '1';
		cs_n <= '0';
		we_n <= '0';
      clr_n <= '1';
		pd_n <= '1';
		--writing process has begun
		done <= '0';
		--80ns delay
		if delay_cnt = 3 then
		delay_cnt <= 0;
      state <= wrt_inreg;
		end if;
    when  wrt_inreg=>
	   --This state will clear internal registers
      ldac_n <= '1';
		cs_n <= '0';
		--rising edge write 
		we_n <= '1';
      clr_n <= '1';
		pd_n <= '1';
		--writing process has begun
		done <= '0';
		--80ns delay
		if delay_cnt = 3 then
		delay_cnt <= 0;
      state <= ld_dacreg_n;
		end if;
	 when  ld_dacreg_n=>
	   --This state will clear internal registers
      ldac_n <= '0';
		cs_n <= '0';
		--rising edge write 
		we_n <= '1';
      clr_n <= '1';
		pd_n <= '1';
		--writing process has begun
		done <= '0';
		--80ns delay
		if delay_cnt = 3 then
		delay_cnt <= 0;
      state <= ld_dacreg;
		end if;
    when  ld_dacreg=>
	   --This state will clear internal registers
      ldac_n <= '1';
		cs_n <= '0';
		--rising edge write 
		we_n <= '1';
      clr_n <= '1';
		pd_n <= '1';
		--writing process has begun
		done <= '0';
		--80ns delay
		if delay_cnt = 3 then
		delay_cnt <= 0;
      state <= dslct;
		end if;
    when  dslct=>
	   --This state will clear internal registers
      ldac_n <= '1';
		cs_n <= '1';
		--rising edge write 
		we_n <= '1';
      clr_n <= '1';
		pd_n <= '1';
		--writing process has begun
		done <= '1';
		--80ns delay
		if delay_cnt = 3 then
		delay_cnt <= 0;
      state <= load;
		end if;
	 end case;
  end if; 
end process PAR_DAC_DRIVER;

end Behavioral;

