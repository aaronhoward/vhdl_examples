----------------------------------------------------------------------------------
-- Company: 		 ABH Engineering
-- Engineer:       Aaron Howard
-- 
-- Create Date:    20:50:43 04/04/2014 
-- Design Name: 
-- Module Name:    SPI_ADC - Behavioral 
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

entity SPI_ADC is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           sck : out  STD_LOGIC := '0';
           sdo : out  STD_LOGIC := '0';
           sdi : in  STD_LOGIC;
           cs_n : out  STD_LOGIC := '1';
           bgn : in  STD_LOGIC;
			  ch_sel : in STD_LOGIC; 
			  conv_data : out STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
           done : out  STD_LOGIC := '1');
end SPI_ADC;

architecture Behavioral of SPI_ADC is

--ch selection commands
constant ch0_sel: std_logic_vector(15 downto 0) := B"0110_1000_0000_0000";
constant ch1_sel: std_logic_vector(15 downto 0) := B"0111_1000_0000_0000";
--place holder to latch in constant value
signal ch_slct_hld : std_logic_vector(15 downto 0) := (others => '0');

type state_type is (start,idle,dly1,mode,data,dly2,stop);
signal state : state_type := start; 
 
signal next_state : std_logic := '0';
 
signaL auxclk : std_logic := '0'; -- divided clock 200KHz
signaL spiclk : std_logic := '1'; -- divided clock 200KHz

--timer value for state transitions
signal timer: natural range 0 to 16;

--this vector will bve used for the rising edge detection
signal in_val : std_logic_vector(2 downto 0) := (others => '0'); 

--place holder for converted data
--default to 1 since error is 0
signal data_buf : std_logic_vector(9 downto 0) := (others => '0'); 

--track edge of auxclk
signal auxtrack : std_logic_vector(3 downto 0) := (others => '0');

signal nxtrack : std_logic_vector(2 downto 0) := (others => '0');

--up to sixteen bits are transfered
signal i : natural range 0 to 16;
--allows to pass the value of the counter to drive tri-states
--at midway of auxclk
signal count: natural range 0 to 500;

begin

SPI_ADC_DRIVER: process(rst,clk)
 begin 
 if rst = '1' then
		state <= start;
      cs_n <= '1';
	   sck <= '0'; --mode 0,0
      sdo <= '0';
		in_val <= (others => '0');
		timer <= 1;
		nxtrack <= (others => '0');
		data_buf <= (others => '0');
		conv_data <= (others => '0');
		done <= '1';
		ch_slct_hld <= (others => '0');
 elsif (clk'event and clk = '1') then
  --nx_state control signal rising edge
  nxtrack(2 downto 0) <= nxtrack(1 downto 0) & next_state;
  --LEFT SHIFT
  in_val(2 downto 0) <= in_val(1 downto 0) & bgn;
   case state is
     when start =>
		if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		state <= idle;
		end if;
		cs_n <= '1';
	   sck <= '0'; --mode 0,0
      sdo <= '0';
		timer <= 1;
		data_buf <= (others => '0');
		conv_data <= (others => '0');
		done <= '1';
		in_val <= (others => '0');
		ch_slct_hld <= (others => '0');
     when idle =>		   
      --control logic
	   cs_n <= '1';
	   sck <= '0'; --mode 0,0
      sdo <= '0';
		timer <= 1;
		nxtrack <= (others => '0');
		--rising edge detector
		 if (in_val(2) = '0' and in_val(1) = '1') then
		  if ch_sel = '1' then
		   ch_slct_hld <= ch1_sel;
        else
		   ch_slct_hld <= ch0_sel;
		  end if;
  		    data_buf <= (others => '0');
       	 done <= '0';
			 state <= mode;
       end if;
		when mode =>
		 cs_n <= '0';
	    sck <= '0'; --mode 0,0
       sdo <= '0';
		 timer <= 1;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= dly1; 
		 end if; 
		when dly1 =>
		 cs_n <= '0';
	    sck <= '0'; --mode 0,0
		 sdo <= '0';
		 timer <= 1;		 
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= data;
		 end if; 
      when data =>	
		 cs_n <= '0'; 
	    sck <= spiclk; --mode 0,0
		 sdo <= ch_slct_hld(15-i);
		 timer <= 15;
		 if  i > 5 then
		  if  spiclk = '1' then
		   if count = 1 then
	       data_buf(15-i) <= sdi;
	      end if;
		  end if;	  
       end if;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= dly2;
		  conv_data <= data_buf;
		 end if;
		when dly2 =>
		 cs_n <= '0';
	    sck <= '0'; --mode 0,0
		 sdo <= '0';
		 timer <= 1;		 
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= stop;
		 end if;
		 --need to hold cs high min 310ns
		when stop =>
		 cs_n <= '1';
	    sck <= '0'; --mode 0,0
		 sdo <= '0';
		 timer <= 1;	 
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= idle;
		  done <= '1';
		 end if;	 
		when others =>
		 cs_n <= '0';
	    sck <= '0'; --mode 0,0
		 sdo <= '0';
		 timer <= 1;
		 state <= idle;
		 done <= '1';
		 data_buf <= (others => '0');
	 end case; 
 end if;	 
end process SPI_ADC_DRIVER;


fsm_clk: process(rst,clk)
--this process drives the shared i variable
begin
 if rst = '1' then
   next_state <= '0';
   i <= 0;
	auxtrack <= (others => '0');
 --send data to hybrid spi interface
 elsif (clk'event and clk = '1') then
	--comtrols timing of state transition
	auxtrack(3 downto 0) <= auxtrack(2 downto 0) & auxclk;
     if (auxtrack(3) = '0' and auxtrack(2) = '1') then
		if (i=timer) then
		 next_state <= '1';
		 i <= 0;
		else 
		 i <= i + 1;
		 next_state <= '0';
		end if;	
    end if;
 end if;
end process fsm_clk;


--creates 50KHz clock
--the whole cycle cannot exceed 700us or charge cap will leak 
--this process drives the shared count variable
CLOCK: process(rst,clk)
begin
  if rst = '1' then
   count <= 0;
	auxclk <= '0';
	spiclk <= '1';
  elsif(clk'event and clk='1') then
   count <= count + 1;
	if (count = 500) then
	 auxclk <= not auxclk;
	 spiclk <= not spiclk;
	 count <= 0;
	end if;
  end if;
end process CLOCK;

end Behavioral;

