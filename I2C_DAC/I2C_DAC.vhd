----------------------------------------------------------------------------------
-- Company:        ABH Engineering 
-- Engineer:       Aaron Howard
-- 
-- Create Date:    13:22:23 03/29/2014 
-- Design Name: 
-- Module Name:    I2C_DAC - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies:   A0 should be pulled to ground
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity I2C_DAC is
    Port ( sda : inout  STD_LOGIC;
	        cmf : out STD_LOGIC;
			  val : in STD_LOGIC_VECTOR(11 downto 0);
			  bgn : in STD_LOGIC;
			  done : out STD_LOGIC;
           scl : out  STD_LOGIC;
           rst : in  STD_LOGIC;
           clk : in  STD_LOGIC);
end I2C_DAC;

architecture Behavioral of I2C_DAC is

--I2C_DAC address
--last bit is place holder for ack
constant full_addr: std_logic_vector(8 downto 0) := B"110000000";
--last bit is place holder for ack
constant control: std_logic_vector(8 downto 0)   := B"011000000";


type state_type is (default,init,idle,start,dly1,addr_st,ctrl,data1,data2,stop,dly2,dly3);
signal state : state_type := default; 
 
signal next_state : std_logic := '0';
 
signal data_dir: std_logic := '0'; -- direction bit for SPI data

signaL auxclk : std_logic := '0'; -- divided clock 100KHz
signaL i2cclk : std_logic := '1'; -- divided clock 100KHz

--value to be registered to the spi interface
signal value : std_logic := '0';
--timer value for state transitions
signal timer: natural range 0 to 10;

--place holder for error signal
--default to 1 since error is 0
signal ack_val1 : std_logic := '1';
signal ack_val2 : std_logic := '1';
signal ack_val3 : std_logic := '1';
signal ack_val4 : std_logic := '1';

--this vector will bve used for the rising edge detection
signal in_val : std_logic_vector(2 downto 0) := (others => '0'); 

--data buffers for control data
signal data_buf1 : std_logic_vector(8 downto 0) := (others => '0'); 
signal data_buf2 : std_logic_vector(8 downto 0) := (others => '0');

--track edge of auxclk
signal auxtrack : std_logic_vector(3 downto 0) := (others => '0');

signal nxtrack : std_logic_vector(2 downto 0) := (others => '0');

--up to ten bits are transfered
signal i : natural range 0 to 10;
--allows to pass the value of the counter to drive tri-states
--at midway of auxclk
signal count: natural range 0 to 250;

begin
--Tri state buffer
sda <= value when data_dir = '1' else 'Z';
cmf <= not(ack_val1 or ack_val2 or ack_val3 or ack_val4);

I2C_DRIVER: process(rst,clk,i,next_state,auxtrack) 
 begin 
 if rst = '1' then
      done <= '1';
      data_dir <= '0';
		state <= init;
	   scl <= '1'; 
      value <= '1';
		in_val <= (others => '0');
		timer <= 1;
		nxtrack <= (others => '0');
		data_buf1 <= (others => '0');
		data_buf2 <= (others => '0');
		ack_val1 <= '1';
		ack_val2 <= '1';
		ack_val3 <= '1';
		ack_val4 <= '1';
 elsif (clk'event and clk = '1') then
  --nx_state control signal rising edge
  nxtrack(2 downto 0) <= nxtrack(1 downto 0) & next_state;
   case state is
     when default =>
	   data_dir <= '0';
		if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		state <= init;
		end if;
	   done <= '1';
		scl <= '1'; 
      value <= '1';
		in_val <= (others => '0');
		timer <= 1;
		data_buf1 <= (others => '0');
		data_buf2 <= (others => '0');
		ack_val1 <= '1';
		ack_val2 <= '1';
		ack_val3 <= '1';
		ack_val4 <= '1';
	  when init =>
	   done <= '1';
	   data_dir <= '1';
	   scl <= '1'; 
		value <= '1';
		data_buf1 <= (others => '0');
		data_buf2 <= (others => '0');
		ack_val1 <= '1';
		ack_val2 <= '1';
		ack_val3 <= '1';
		ack_val4 <= '1';
      if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		state <= idle;
		end if;
		timer <= 1;
     when idle =>
	  data_dir <= '1';	
	   --LEFT SHIFT
      in_val(2 downto 0) <= in_val(1 downto 0) & bgn;
      --control logic
	   scl <= '1'; 
		value <= '1';
		timer <= 1;
		--rising edge detector
		 if (in_val(2) = '0' and in_val(1) = '1') then
		   data_buf1 <= val(11 downto 4) & '0';
			data_buf2 <= val(3 downto 0) & "00000";
			done <= '0';
			ack_val1 <= '1';
		   ack_val2 <= '1';
		   ack_val3 <= '1';
		   ack_val4 <= '1';
       	state <= start;
       end if;
		when start =>
		 data_dir <= '1';	
	    scl <= '1'; 
		 value <= '0';
		 timer <= 1;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= dly1; 
		 end if; 
		when dly1 =>
		 data_dir <= '1';	
	    scl <= '0'; 
		 value <= '0';
		 timer <= 1;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= addr_st; 
		 end if; 
      when addr_st =>
       if  i = 0 then
		  if  i2cclk = '0' then
 	      if count = 125 then
	       data_dir <= '1';
	      end if;
		  end if;	
       end if;
	    scl <= i2cclk; 
		 value <= full_addr(8-i);
		 timer <= 8;
		 if  i = 7 then
		  if  i2cclk = '0' then
 	      if count = 1 then
	       data_dir <= '0';
	      end if;
		  end if;	
       end if;
		 if  i = 8 then
		  if  i2cclk = '1' then
 	      if count = 125 then
	       ack_val1 <= sda;
	      end if;
		  end if;	
       end if;	 
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= ctrl;
		 end if; 
		 
		when ctrl =>
		 if  i = 0 then
		  if  i2cclk = '0' then
 	      if count = 125 then
	       data_dir <= '1';
	      end if;
		  end if;	
       end if;
		 scl <= i2cclk; 
		 value <= control(8-i);
		 timer <= 8;
		 if  i = 7 then
		  if  i2cclk = '0' then
 	      if count = 1 then
	       data_dir <= '0';
	      end if;
		  end if;	
       end if;
		  if  i = 8 then
		  if  i2cclk = '1' then
 	      if count = 125 then
	       ack_val2 <= sda;
	      end if;
		  end if;	
       end if;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= data1;
		 end if; 
		 when data1 =>
		 if  i = 0 then
		  if  i2cclk = '0' then
 	      if count = 125 then
	       data_dir <= '1';
	      end if;
		  end if;	
       end if;
	    scl <= i2cclk; 
		 value <= data_buf1(8-i);
		 timer <= 8;
		 if  i = 7 then
		  if  i2cclk = '0' then
 	      if count = 1 then
	       data_dir <= '0';
	      end if;
		  end if;	
       end if;
		  if  i = 8 then
		  if  i2cclk = '1' then
 	      if count = 125 then
	       ack_val3 <= sda;
	      end if;
		  end if;	
       end if;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= data2;
		 end if; 
		 when data2 =>
		 if  i = 0 then
		  if  i2cclk = '0' then
 	      if count = 125 then
	       data_dir <= '1';
	      end if;
		  end if;	
       end if;
	    scl <= i2cclk;
		 value <= data_buf2(8-i);
		 timer <= 8;
		 if  i = 7 then
		  if  i2cclk = '0' then
 	      if count = 1 then
	       data_dir <= '0';
	      end if;
		  end if;	
       end if;
        if  i = 8 then
		  if  i2cclk = '1' then
 	      if count = 125 then
	       ack_val4 <= sda;
	      end if;
		  end if;	
       end if;		 
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= dly2;
		 end if;
		 when dly2 =>
		  if  i = 0 then
		  if  i2cclk = '0' then
 	      if count = 125 then
	       data_dir <= '1';
	      end if;
		  end if;	
       end if;
	    scl <= '0'; 
		 value <= '0';
		 timer <= 1;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= stop;
		 end if;	 
		 when stop =>
		 data_dir <= '1';	
	    scl <= '1'; 
		 value <= '0';
		 timer <= 1;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= dly3; 
		 end if;
		when dly3 =>
		 data_dir <= '1';	
	    scl <= '1'; 
		 value <= '1';
		 timer <= 1;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  done <= '1';
		  data_buf1 <= (others => '0');
		  data_buf2 <= (others => '0');
		  state <= idle;
		 end if;
		when others =>
		 data_dir <= '0';	
	    scl <= '1'; 
		 value <= '1';
		 timer <= 1;
		 state <= idle;
	 end case; 
 end if;	 
end process I2C_DRIVER;


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


--creates 100KHz clock standard mode
--this process drives the shared count variable
CLOCK: process(rst,clk)
begin
  if rst = '1' then
   count <= 0;
	auxclk <= '0';
	i2cclk <= '1';
  elsif(clk'event and clk='1') then
   count <= count + 1;
	if (count = 250) then
	 auxclk <= not auxclk;
	 i2cclk <= not i2cclk;
	 count <= 0;
	end if;
  end if;
end process CLOCK;

end Behavioral;

