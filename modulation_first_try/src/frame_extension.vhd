----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2018/06/19 04:23:49
-- Design Name: 
-- Module Name: frame_extension - RTL
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity frame_extension is
     
   generic 
      (   extension: std_logic_vector(6 downto 0) := "1111111");

    Port ( 
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           data_in : in std_logic_vector(0 downto 0);
           en_in : in STD_LOGIC;
           sop_in : in STD_LOGIC;
           eop_in : in STD_LOGIC;
           data_out : out std_logic_vector(0 downto 0);
           en_out : out STD_LOGIC;
           sop_out : out STD_LOGIC;
           eop_out : out STD_LOGIC);
end frame_extension;

architecture RTL of frame_extension is

   signal en_in_reg:std_logic;
   signal count   : integer range 0 to 1024;
   signal flag:std_logic_vector(1 downto 0);  
  --  signal eop_out_reg:std_logic;
   constant extensionlen : integer := 7;
  
begin

  flag<=en_in & en_in_reg;
-------------------ÊäÈëÔÝ´æ
process(rst,clk)
begin
   if rst = '1'   then   
  --   --  data_in_reg <= "0";
      en_in_reg<= '0';
  elsif rising_edge(clk) then
      en_in_reg<=en_in;
  end if;


  if rst = '1'   then   
      data_out<="0";
      sop_out<='0';
      count<=0;
      en_out<='0';
	elsif rising_edge(clk) then
    case flag is
    when "10" =>
      data_out<=data_in;
      sop_out<='1';
      en_out<='1';
    when "11" =>
      data_out<=data_in;
      sop_out<='0';
    when "01" =>
      count<=1;eop_out<='0';
       data_out<=extension(extensionlen-1-count downto extensionlen-1-count );
    when "00" =>
      case count is
      when 1 to extensionlen-3 =>
        count<=count+1;
        data_out<=extension(extensionlen-1-count downto extensionlen-1-count);
      when extensionlen-2 =>
        count<=count+1;
        data_out<=extension(extensionlen-1-count downto extensionlen-1-count);
      when extensionlen-1 =>
        data_out<=extension(extensionlen-1-count downto extensionlen-1-count);
        count<=0;
        eop_out<='1';
        
        WHEN OTHERS =>  eop_out<='0';data_out<="0";en_out<='0';------------Êý¾Ý¹é0
      end case;
    WHEN OTHERS =>  data_out<="0";
    end case;

  end if;


end process;
end RTL;
