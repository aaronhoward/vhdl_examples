----------------------------------------------------------------------------------
-- Company:        ABH Engineering
-- Engineer:       Aaron Howard
-- 
-- Create Date:    20:23:36 04/16/2014 
-- Design Name: 
-- Module Name:    mpr121 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies:    pull ups on scl and sda and irq lines try 4.7K
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mpr121 is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  cmf : out STD_LOGIC;
			  done : out STD_LOGIC;
           data_out : out  STD_LOGIC_VECTOR (11 downto 0);
           scl : out  STD_LOGIC;
           sda : inout  STD_LOGIC;
           irq : in  STD_LOGIC);
end mpr121;

architecture Behavioral of mpr121 is

--SLAVE ADDRESS WRITE
constant WR_ADDR : std_logic_vector(8 downto 0) := X"B4"&'0'; 
--SLAVE ADDRESS READ
constant RD_ADDR : std_logic_vector(8 downto 0) := X"B5"&'0'; 

--ELECTRODE TOUCH VALUE DATA REGISTER
--UTILIZED AUTO INCREMENT TO READ 0x01 FOR THE MSB BITS
constant ELEC_ADDR : std_logic_vector(8 downto 0) := X"00"&'0'; 

--FIRST SEGMENT IS DEV REG, SECOND IS REG, THIRD IS DATA
type mpr121_reg_config is array (0 to 33) of std_logic_vector (8 downto 0); 
constant CONFIG_REG : mpr121_reg_config := 
( 
--registers to be configured last bit is for ack cycle
--rising time for when value is above baseline
X"2B"&'0', 
X"2C"&'0',
X"2D"&'0', 
X"2E"&'0',
--falling time for when value is below baseline
X"2F"&'0', 
X"30"&'0', 
X"31"&'0', 
X"32"&'0', 
--electrode threshholds touch and release
X"41"&'0',
X"42"&'0',
X"43"&'0',
X"44"&'0',
X"45"&'0',
X"46"&'0',
X"47"&'0',
X"48"&'0',
X"49"&'0',
X"4A"&'0',
X"4B"&'0',
X"4C"&'0',
X"4D"&'0',
X"4E"&'0',
X"4F"&'0',
X"50"&'0',
X"51"&'0',
X"52"&'0',
X"53"&'0',
X"54"&'0',
X"55"&'0',
X"56"&'0',
X"57"&'0',
X"58"&'0',
--filter configuration
X"5D"&'0',
----electrode configuration
X"5E"&'0'
); 

type mpr121_data_config is array (0 to 33) of std_logic_vector (8 downto 0); 
constant CONFIG_DATA : mpr121_data_config := 
( 
--registers to be configured last bit is for ack cycle
--rising time for when value is above baseline
X"01"&'0', 
X"01"&'0',
X"00"&'0', 
X"00"&'0',
--falling time for when value is below baseline
X"01"&'0', 
X"01"&'0', 
X"FF"&'0', 
X"02"&'0', 
--electrode threshholds touch and release
X"0F"&'0',
X"0A"&'0',
X"0F"&'0',
X"0A"&'0',
X"0F"&'0',
X"0A"&'0',
X"0F"&'0',
X"0A"&'0',
X"0F"&'0',
X"0A"&'0',
X"0F"&'0',
X"0A"&'0',
X"0F"&'0',
X"0A"&'0',
X"0F"&'0',
X"0A"&'0',
X"0F"&'0',
X"0A"&'0',
X"0F"&'0',
X"0A"&'0',
X"0F"&'0',
X"0A"&'0',
X"0F"&'0',
X"0A"&'0',
--filter configuration
X"04"&'0',
----electrode configuration
X"0C"&'0'
);

--MUX counter will be used to mux out constant values
signal mux_cnt: natural range 0 to 33; 

type state_type is (default,init,conf_start,conf_dly1,conf_slv_addr,conf_reg,conf_data,conf_dly2,conf_stop,conf_dly3,
idle,start,dly1,addr_st1,addr_data,restart_setup,restart,addr_st2,data_rd1,data_rd2,stop,dly2,dly3);

signal state : state_type := default; 
 
signal next_state : std_logic := '0';
 
signal data_dir: std_logic := '0'; -- direction bit for I2C data

signaL auxclk : std_logic := '0'; -- divided clock 400KHz
signaL i2cclk : std_logic := '1'; -- divided clock 400KHz

--value to be registered to the spi interface
signal value : std_logic := '0';
--timer value for state transitions
signal timer: natural range 0 to 10;

--place holder for error signal
--default to 1 since error is 0
signal ack_val1 : std_logic := '1';
signal ack_val2 : std_logic := '1';
signal ack_val3 : std_logic := '1';

--this vector will bve used for the falling edge detection for IRQ
signal in_val1 : std_logic_vector(2 downto 0) := (others => '1'); 

--data buffers for control data last bit is for ack
signal data_buf1 : std_logic_vector(8 downto 0) := (others => '0'); 
signal data_buf2 : std_logic_vector(8 downto 0) := (others => '0');
signal val_buf1 : std_logic_vector(7 downto 0) := (others => '0');
signal val_buf2 : std_logic_vector(7 downto 0) := (others => '0');

--track edge of auxclk
signal auxtrack : std_logic_vector(3 downto 0) := (others => '0');
signal nxtrack : std_logic_vector(2 downto 0) := (others => '0');

--up to ten bits are transfered
signal i : natural range 0 to 10;
--allows to pass the value of the counter to drive tri-states
--at midway of auxclk
signal count: natural range 0 to 64;

begin

--Tri state buffer
sda <= value when data_dir = '1' else 'Z';
--write confirm
cmf <= not(ack_val1 or ack_val2 or ack_val3);

I2C_DRIVER: process(rst,clk,i,next_state,auxtrack) 
 begin 
 if rst = '1' then
      done <= '1';
      data_dir <= '0';
		data_out <= (others => '0');
		state <= init;
	   scl <= '1'; 
      value <= '1';
		in_val1 <= (others => '1');
		timer <= 1;
		mux_cnt <= 0;
		nxtrack <= (others => '0');
		data_buf1 <= (others => '0');
		data_buf2 <= (others => '0');
		val_buf1 <= (others => '0');
		val_buf2 <= (others => '0');
		ack_val1 <= '1';
		ack_val2 <= '1';
		ack_val3 <= '1';
		
 elsif (clk'event and clk = '1') then
  --nx_state control signal rising edge
  nxtrack(2 downto 0) <= nxtrack(1 downto 0) & next_state;
   case state is
     
	  when default =>
	   data_dir <= '0';
		if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		state <= init;
		end if;
		mux_cnt <= 0;
	   done <= '1';
		scl <= '1'; 
      value <= '1';
		data_out <= (others => '0');
		in_val1 <= (others => '1');
		timer <= 1;
		data_buf1 <= (others => '0');
		data_buf2 <= (others => '0');
		val_buf1 <= (others => '0');
		val_buf2 <= (others => '0');
		ack_val1 <= '1';
		ack_val2 <= '1';
		ack_val3 <= '1';
		  
	  when init =>
	   done <= '1';
	   data_dir <= '1';
	   scl <= '1'; 
		value <= '1';
		in_val1 <= (others => '1');
		data_out <= (others => '0');
		data_buf1 <= (others => '0');
		data_buf2 <= (others => '0');
		val_buf1 <= (others => '0');
		val_buf2 <= (others => '0');
		ack_val1 <= '1';
		ack_val2 <= '1';
		ack_val3 <= '1';
      if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		state <= conf_start;
		end if;
		mux_cnt <= 0;
		timer <= 1;
     
	  when conf_start =>
	    in_val1 <= (others => '1');
	    data_out <= (others => '0');
		 val_buf1 <= (others => '0');
		 val_buf2 <= (others => '0');
		 data_dir <= '1';	
	    scl <= '1'; 
		 value <= '0';
		 timer <= 1;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= conf_dly1; 
		 end if; 
	  
	  when conf_dly1 =>
		 data_dir <= '1';	
	    scl <= '0'; 
		 value <= '0';
		 timer <= 1;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= conf_slv_addr; 
		 end if; 
	  
	  when conf_slv_addr =>
--	   if  i = 0 then
--		  if  i2cclk = '0' then
-- 	      if count = 0 then	       
	       data_buf1 <= CONFIG_REG(mux_cnt);
--	      end if;
--		  end if;	
--       end if;
--		 if  i = 0 then
--		  if  i2cclk = '0' then
-- 	      if count = 1 then	       
	       data_buf2 <= CONFIG_DATA(mux_cnt);
--	      end if;
--		  end if;	
--       end if; 
	    if  i = 0 then
		  if  i2cclk = '0' then
 	      if count = 32 then
	       data_dir <= '1';
	      end if;
		  end if;	
       end if;
		 scl <= i2cclk; 
		 timer <= 8;
		 value <= WR_ADDR(8-i);
		 if  i = 7 then
		  if  i2cclk = '0' then
 	      if count = 1 then
	       data_dir <= '0';
	      end if;
		  end if;	
       end if;
		 if  i = 8 then
		  if  i2cclk = '1' then
 	      if count = 32 then
	       ack_val1 <= sda;
	      end if;
		  end if;	
       end if;	 
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= conf_reg;	  
		 end if; 

	  when conf_reg =>
       if  i = 0 then
		  if  i2cclk = '0' then
 	      if count = 32 then
	       data_dir <= '1';
	      end if;
		  end if;	
       end if;
		 scl <= i2cclk; 
		 timer <= 8;
		 value <= data_buf1(8-i);
		 if  i = 7 then
		  if  i2cclk = '0' then
 	      if count = 1 then
	       data_dir <= '0';
	      end if;
		  end if;	
       end if;
		 if  i = 8 then
		  if  i2cclk = '1' then
 	      if count = 32 then
	       ack_val2 <= sda;
	      end if;
		  end if;	
       end if;	 
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= conf_data;	  
		 end if; 

	  when conf_data =>
       if  i = 0 then
		  if  i2cclk = '0' then
 	      if count = 32 then
	       data_dir <= '1';
	      end if;
		  end if;	
       end if;
		 scl <= i2cclk; 
		 timer <= 8;
		 value <= data_buf2(8-i);
		 if  i = 7 then
		  if  i2cclk = '0' then
 	      if count = 1 then
	       data_dir <= '0';
	      end if;
		  end if;	
       end if;
		 if  i = 8 then
		  if  i2cclk = '1' then
 	      if count = 32 then
	       ack_val3 <= sda;
	      end if;
		  end if;	
       end if;	 
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= conf_dly2;
		 end if; 

     when conf_dly2 =>
		  if  i = 0 then
		  if  i2cclk = '0' then
 	      if count = 32 then
	       data_dir <= '1';
	      end if;
		  end if;	
       end if;
	    scl <= '0'; 
		 value <= '0';
		 timer <= 1;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= conf_stop;
		 end if;	 
		 
		 when conf_stop =>
		 data_dir <= '1';	
	    scl <= '1'; 
		 value <= '0';
		 timer <= 1;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= conf_dly3; 
		 end if;
		
		when conf_dly3 =>
		 --allow for all of the array values to be read out 
		 data_dir <= '1';	
	    scl <= '1'; 
		 value <= '1';
		 timer <= 1;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  mux_cnt <= mux_cnt + 1;
		  if mux_cnt = 33 then
		  state <= idle;
		  else
		  state <= conf_start;
		  end if;	  
		 end if;
	  
--monitor IRQ pin to read out electrode values
	  when idle =>
	  data_dir <= '1';	
	   --LEFT SHIFT irq pin is asserted until read starts
      in_val1(2 downto 0) <= in_val1(1 downto 0) & irq;
      --control logic
	   scl <= '1'; 
		value <= '1';
		timer <= 1;
		--falling edge detector for IRQ
		 if (in_val1(2) = '1' and in_val1(1) = '0') then
			done <= '0';
			val_buf1 <= (others => '0');
		   val_buf2 <= (others => '0');
			ack_val1 <= '1';
		   ack_val2 <= '1';
		   ack_val3 <= '1';
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
		  state <= addr_st1; 
		 end if; 
      
		when addr_st1 =>
       if  i = 0 then
		  if  i2cclk = '0' then
 	      if count = 32 then
	       data_dir <= '1';
	      end if;
		  end if;	
       end if;
		 scl <= i2cclk; 
		 timer <= 8;
		 value <= WR_ADDR(8-i);
		 if  i = 7 then
		  if  i2cclk = '0' then
 	      if count = 1 then
	       data_dir <= '0';
	      end if;
		  end if;	
       end if;
		 if  i = 8 then
		  if  i2cclk = '1' then
 	      if count = 32 then
	       ack_val1 <= sda;
	      end if;
		  end if;	
       end if;	 
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= addr_data;
		 end if; 
		 
		when addr_data =>
		 if  i = 0 then
		  if  i2cclk = '0' then
 	      if count = 32 then
	       data_dir <= '1';
	      end if;
		  end if;	
       end if;
		 scl <= i2cclk; 
		 value <= ELEC_ADDR(8-i);
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
 	      if count = 32 then
	       ack_val2 <= sda;
	      end if;
		  end if;	
       end if;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		     state <= restart_setup;
		 end if; 
		 
		 when restart_setup =>
		  timer <= 4;
		  if  i = 0 then
		  if  i2cclk = '0' then
 	      if count = 1 then
	       data_dir <= '1';
			 scl <= '0';
			 value <= '0';
	      end if;
		  end if;	
       end if;
	    if  i = 2 then
		  if  i2cclk = '0' then
 	      if count = 1 then
	       data_dir <= '1';
			 scl <= '0';
			 value <= '1';
	      end if;
		  end if;	
       end if;
		 if  i = 3 then
		  if  i2cclk = '0' then
 	      if count = 1 then
	       data_dir <= '1';
			 scl <= '1';
			 value <= '1';
	      end if;
		  end if;	
       end if;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= restart;
		 end if;	
		 
		  when restart =>
		  timer <= 4;
		  if  i = 0 then
		  if  i2cclk = '0' then
 	      if count = 1 then
	       data_dir <= '1';
			 scl <= '1';
			 value <= '1';
	      end if;
		  end if;	
       end if;
	    if  i = 2 then
		  if  i2cclk = '0' then
 	      if count = 1 then
	       data_dir <= '1';
			 scl <= '1';
			 value <= '0';
	      end if;
		  end if;	
       end if;
		 if  i = 3 then
		  if  i2cclk = '0' then
 	      if count = 1 then
	       data_dir <= '1';
			 scl <= '0';
			 value <= '0';
	      end if;
		  end if;	
       end if;
		  if  i = 4 then
		  if  i2cclk = '0' then
 	      if count = 1 then
	       data_dir <= '1';
			 scl <= '0';
			 value <= '0';
	      end if;
		  end if;	
       end if;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= addr_st2;
		 end if;	
		 
		 	when addr_st2 =>
       if  i = 0 then
		  if  i2cclk = '0' then
 	      if count = 32 then
	       data_dir <= '1';
	      end if;
		  end if;	
       end if;
		 scl <= i2cclk; 
		 timer <= 8;
		 value <= RD_ADDR(8-i);
		 if  i = 7 then
		  if  i2cclk = '0' then
 	      if count = 1 then
	       data_dir <= '0';
	      end if;
		  end if;	
       end if;
		 if  i = 8 then
		  if  i2cclk = '1' then
 	      if count = 32 then
	       ack_val3 <= sda;
	      end if;
		  end if;	
       end if;	 
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= data_rd1;
		 end if; 
    	 
		 when data_rd1 =>
		 if  i = 0 then
		  if  i2cclk = '0' then
 	      if count = 32 then
	       data_dir <= '0';
	      end if;
		  end if;	
       end if;		 
	    scl <= i2cclk;
		 timer <= 8; 
       --read data
		if i >= 0 and i < 8  then 
       if  i2cclk = '0' then
 	      if count = 40 then
	       val_buf1(7-i) <= sda;
	      end if;
		  end if;
		 end if; 
		 --create ack bit for continuos read
		 if  i = 8 then
		  if  i2cclk = '0' then
 	      if count = 32 then
	       data_dir <= '1';
			 value <= '0';
	      end if;
		  end if;	
       end if;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= data_rd2;
		 end if;
		 
		 when data_rd2 =>
		 if  i = 0 then
		  if  i2cclk = '0' then
 	      if count = 32 then
	       data_dir <= '0';
	      end if;
		  end if;	
       end if;		 
	    scl <= i2cclk;
		 timer <= 8; 
       --read data
		if i >= 0 and i < 8 then 
       if  i2cclk = '0' then
 	      if count = 40 then
	       val_buf2(7-i) <= sda;
	      end if;
		  end if;
		 end if; 
		 --create no ack bit let pull up resitor hold high
		 if  i = 8 then
		  if  i2cclk = '0' then
 	      if count = 32 then
	       data_dir <= '1';
			 value <= '1';
	      end if;
		  end if;	
       end if;
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  state <= dly2;
		 end if;
		 
		 when dly2 =>
		  if  i = 0 then
		  if  i2cclk = '0' then
 	      if count = 32 then
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
		 data_buf1 <= (others => '0');
		 data_buf2 <= (others => '0');
		 if (nxtrack(2) = '0' and nxtrack(1) = '1') then
		  done <= '1';
		  data_out <= val_buf2(3 downto 0) & val_buf1;
		  state <= idle;
		 end if;
		
		when others =>
		 data_dir <= '0';	
	    scl <= '1'; 
		 value <= '1';
		 timer <= 1;
		 data_buf1 <= (others => '0');
		 data_buf2 <= (others => '0');
		 val_buf1 <= (others => '0');
		 val_buf2 <= (others => '0');
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


--creates 400KHz clock standard mode
--this process drives the shared count variable
CLOCK: process(rst,clk)
begin
  if rst = '1' then
   count <= 0;
	auxclk <= '0';
	i2cclk <= '1';
  elsif(clk'event and clk='1') then
   count <= count + 1;
	if (count = 64) then
	 auxclk <= not auxclk;
	 i2cclk <= not i2cclk;
	 count <= 0;
	end if;
  end if;
end process CLOCK;

end Behavioral;

