----------------------------------------------------------------------------------
-- Company:     ABH Engineering
-- Engineer:    Aaron Howard
-- 
-- Create Date: 02/26/2014 02:16:17 PM
-- Design Name: 
-- Module Name: Training - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description:  Variable PWM for SERVO motor based on a 50MHz system
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;


entity SERVO is

  generic (
    prd : integer := 1_000_000;         --20ms at 50MHz
    N   : integer := 20          -- 20 bit couter for 20ms at 50MHz resolution
    );

  port (clk   : in  std_logic;          --50 MHZ Clock
         rst  : in  std_logic;
         pwm  : out std_logic := '0';
         duty : in  std_logic_vector (N-1 downto 0));
end SERVO;

architecture Behavioral of SERVO is

  signal count : std_logic_vector(N-1 downto 0) := (others => '0');

begin

  counter : process (clk, rst)
  begin
    if rst = '1' then
      count <= (others => '0');
    elsif clk'event and clk = '1' then
      if count = prd-1 then
        count <= (others => '0');
      else
        count <= count + 1;
      end if;
    end if;
  end process counter;

  pwmout : process (count, duty)
  begin
    
    pwm <= '0';

    if (duty <= 95000 and duty >= 55000) then  --cannot exceed 1.9ms and cannot be less than 1.1ms
      if count < duty then
        pwm <= '1';
      end if;
    end if;
  end process pwmout;





end Behavioral;
