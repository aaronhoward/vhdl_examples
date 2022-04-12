----------------------------------------------------------------------------------
-- Company:        ABH ENGINEERING
-- Engineer:       Aaron Howard
-- 
-- Create Date:    19:34:34 03/18/2014 
-- Design Name: 
-- Module Name:    DIGIPOT - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:    Bidirectional SPI interface 10K pot
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

entity DIGIPOT is
    Port ( clk : in STD_LOGIC;
	        rst : in STD_LOGIC;
			  cmf : out STD_LOGIC;
	        cs : out  STD_LOGIC := '1';
           sdi_sdo : inout  STD_LOGIC;
			  ctrl : in STD_LOGIC_VECTOR(7 downto 0);
			  bgn : in STD_LOGIC;
           sck : out  STD_LOGIC := '0');
end DIGIPOT;

architecture Behavioral of DIGIPOT is
--wiper location zero write command
constant wiper_0: std_logic_vector(3 downto 0) := B"0000";
constant wrt_cmd: std_logic_vector(2 downto 0) := B"000";

type state_type is (start,init,idle,mode,addr,cmd,data,dly);
signal state : state_type := start; 
 
signal next_state : std_logic := '0';
 
signal data_dir: std_logic := '0'; -- direction bit for SPI data

signaL auxclk : std_logic := '0'; -- divided clock 200KHz
signaL spiclk : std_logic := '1'; -- divided clock 200KHz

--value to be registered to the spi interface
signal value : std_logic := '0';
--timer value for state transitions
signal timer: natural range 0 to 10;

--place holder for error signal
--default to 1 since error is 0
signal err_val : std_logic := '0';

--this vector will bve used for the rising edge detection
signal in_val : std_logic_vector(2 downto 0) := (others => '0'); 

--data buffer for control data
signal data_buf : std_logic_vector(9 downto 0) := (others => '0'); 

--track edge of auxclk
signal auxtrack : std_logic_vector(3 downto 0) := (others => '0');

signal nxtrack : std_logic_vector(2 downto 0) := (others => '0');

--up to ten bits are transfered
signal i : natural range 0 to 10;
--allows to pass the value of the counter to drive tri-states
--at midway of auxclk
signal count: natural range 0 to 125;


begin
--Tri state buffer
sdi_sdo <= value when data_dir = '1' else 'Z';
cmf <= err_val;

SPI_DRIVER: process(rst,clk,i,next_state,auxtrack) 
 begin 
 if rst = '1' then
    data_dir <= '0';
		state <= init;
      cs <= '1';
	   sck <= '0'; --mode 0,0
      value <= '0';
		in_val <= (others => '0');
		timer <= 1;
		nxtrack <= (others => '0');
		data_buf <= (others => '0');
		err_val <= '0';
 elsif (clk'event and clk = '1') then
  --nx_state control signal rising edge
  nxtrack(2 downto 0) <= nxtrack(1 downto 0) & next_state;
   case state is
     when start =>
	   data_dir <= '0';
		if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		state <= init;
		end if;
		err_val <= '0';
      cs <= '1';
	   sck <= '0'; --mode 0,0
      value <= '0';
		in_val <= (others => '0');
		timer <= 1;
	  when init =>
	   data_dir <= '0';
		cs <= '1';
	   sck <= '0'; --mode 0,0
		value <= '0';
      if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		state <= idle;
		end if;
		timer <= 1;
     when idle =>
	  err_val <= '0';
	  cs <= '1';
	  data_dir <= '1';	
	   --LEFT SHIFT
      in_val(2 downto 0) <= in_val(1 downto 0) & bgn;
      --control logic
	   sck <= '0'; --mode 0,0
		value <= '0';
		timer <= 1;
		--rising edge detector
		 if (in_val(2) = '0' and in_val(1) = '1') then
		   data_buf(9 downto 0) <= "00" & ctrl;
       	 state <= mode;
       end if;
		when mode =>
		 data_dir <= '1';	
		 cs <= '0';
	    sck <= '0'; --mode 0,0
		 value <= '0';
		 timer <= 1;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= addr; 
		 end if; 
      when addr =>
		 data_dir <= '1';	
		 cs <= '0';
	    sck <= spiclk; --mode 0,0
		 value <= wiper_0(3-i);
		 timer <= 3;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= cmd;
		 end if; 
      when cmd =>
		 cs <= '0';
	    sck <= spiclk; --mode 0,0
		 value <= wrt_cmd(2-i);
		 timer <= 2;
		 if  i = 1 then
		  if  spiclk = '1' then
 	      if count = 62 then
	       data_dir <= '0';
	      end if;
		  end if;	
       end if;
		 if  i = 2 then
		  if  spiclk = '0' then
		   if count = 62 then
	       err_val  <= sdi_sdo;
	      end if;
		  end if;
		  if  spiclk = '1' then
 	      if count = 62 then
	       data_dir <= '1';
	      end if;
		  end if;	
       end if;
		if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= data; 
		  value <= '0';
		 end if;
		when data =>
		 data_dir <= '1';	
		 cs <= '0';
	    sck <= spiclk; --mode 0,0
		 value <= data_buf(9-i);
		 timer <= 9;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  value <= '0';
		  state <= dly;
		 end if;
		when dly =>
		 data_dir <= '1';	
		 cs <= '0';
	    sck <= '0'; --mode 0,0
		 value <= '0';
		 timer <= 1;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= idle;
		 end if;
		when others =>
		 data_dir <= '0';	
		 cs <= '0';
	    sck <= '0'; --mode 0,0
		 value <= '0';
		 timer <= 1;
		 state <= idle;
	 end case; 
 end if;	 
end process SPI_DRIVER;


fsm_clk: process(rst,clk,auxclk)
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


--creates 200KHz clock
--this process drives the shared count variable
CLOCK: process(rst,clk)
begin
  if RST = '1' then
   count <= 0;
	auxclk <= '0';
	spiclk <= '1';
  elsif(clk'event and clk='1') then
   count <= count + 1;
	if (count = 125) then
	 auxclk <= not auxclk;
	 spiclk <= not spiclk;
	 count <= 0;
	end if;
  end if;
end process CLOCK;


end Behavioral;

