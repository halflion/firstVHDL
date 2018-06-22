----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2018/06/19 05:25:13
-- Design Name: 
-- Module Name: frame_extension_tb - Behavioral
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
use ieee.std_logic_textio.all; 
use std.textio.all; 

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity frame_extension_tb is
--  Port ( );
end frame_extension_tb;

architecture rtl of frame_extension_tb is
 component frame_extension
   generic ( extension: std_logic_vector(6 downto 0) := "1111111"
);

  Port ( 
           rst       : in STD_LOGIC;
           clk       : in STD_LOGIC;
           data_in   : in std_logic_vector(0 downto 0);
           en_in     : in STD_LOGIC;
           sop_in    : in STD_LOGIC;
           eop_in    : in STD_LOGIC;
           data_out  : out std_logic_vector(0 downto 0);
           en_out    : out STD_LOGIC;
           sop_out   : out STD_LOGIC;
           eop_out   : out STD_LOGIC);
 end component;  
 
   signal  rst :  STD_LOGIC;   
   signal clk : std_logic;
   signal data_in : std_logic_vector(0 downto 0);
   signal en_in :  STD_LOGIC;  
   signal sop_in :   STD_LOGIC;
   signal eop_in :   STD_LOGIC;
   signal data_out:  std_logic_vector(0 downto 0);
   signal en_out :   STD_LOGIC;
   signal sop_out :  STD_LOGIC;
   signal eop_out : STD_LOGIC;
      signal en_in_reg : STD_LOGIC;
 
         
 
 
  
   constant clk_period :time :=20 ns;    
   
   begin  
     instant:frame_extension
      generic map
      (extension=> "1101101")
     port map  
     (  
       rst       =>rst        ,
       clk       =>clk        ,
       data_in   =>data_in    ,
       en_in     =>en_in_reg      ,
       sop_in    =>sop_in     ,
       eop_in    =>eop_in     ,
       data_out  =>data_out   ,
       en_out    =>en_out     ,
       sop_out   =>sop_out    ,
       eop_out   =>eop_out  
       );  
       
       clk_gen:process  
      begin      
        wait for clk_period/2;  
        clk<='0';    
        wait for clk_period/2;  
        clk<='1';  
      end process;  


    
  rst_gen:process  
  begin  
    rst<='1';  
    wait for 40 ns;  
    rst<='0';  
    wait;  
  end process;  

 en_in_gen:process  
  begin  
   en_in<='0';  
    wait for 360 ns;  
    en_in<='1';  
    wait for 640 ns;
    en_in<='0'; 
    wait for 3320 ns;
    en_in<='1'; 
    wait for 640 ns;
    en_in<='0'; 
     wait for 12800 ns;
    en_in<='1'; 
    wait for 640 ns;
    en_in<='0'; 
    wait for 8000 ns;  
    en_in<='1';  
    wait for 640 ns;
    en_in<='0'; 
    wait for 3320 ns;
    en_in<='1'; 
    wait for 640 ns;
    en_in<='0'; 
     wait for 12800 ns;
    en_in<='1'; 
    wait for 640 ns;
    en_in<='0'; 
    wait;
  end process;  
      
sop_in_gen:process  
  begin  
    sop_in<='0';  
    wait for 360 ns;  
    sop_in<='1';  
    wait for 20 ns;
    sop_in<='0'; 
    wait for 620 ns;
    wait for 3320 ns;
    sop_in<='1'; 
    wait for 20 ns;
    sop_in<='0'; 
     wait for 13420 ns;
    sop_in<='1'; 
    wait for 20 ns;
    sop_in<='0';  
    wait for 8620 ns;  
    sop_in<='1';  
    wait for 20 ns;
    sop_in<='0';  
    wait for 3940 ns;
    sop_in<='1'; 
    wait for 20 ns;
    sop_in<='0'; 
     wait for 13420 ns;
    sop_in<='1'; 
    wait for 20 ns;
    sop_in<='0';  
    wait;
  end process;  
  eop_in_gen:process  
  begin  
   eop_in<='0';  
    wait for 360 ns; 
    wait for 620 ns; 
    eop_in<='1';  
    wait for 20 ns;
    eop_in<='0'; 
    wait for 3940 ns;
    eop_in<='1'; 
    wait for 20 ns;
    eop_in<='0'; 
     wait for 13420 ns;
    eop_in<='1'; 
    wait for 20 ns;
    eop_in<='0'; 
    wait for 8000 ns;  
     wait for 620 ns; 
    eop_in<='1';  
    wait for 20 ns;
    eop_in<='0'; 
    wait for 3320 ns;
     wait for 620 ns; 
    eop_in<='1'; 
    wait for 20 ns;
    eop_in<='0'; 
     wait for 12800 ns; wait for 620 ns; 
    eop_in<='1'; 
    wait for 20 ns;
    eop_in<='0'; 
    wait;
  end process;  
  
 data_in_gen:process(clk,rst,en_in)
    file simu_din:text open read_mode is "simu.txt";
    variable line_in:line;
    variable data_in_tmp: std_logic_vector(0 downto 0);
      
     begin  
      if rst='1' then
        data_in<="0";
        en_in_reg<='0';
      elsif  rising_edge(clk) then
        if  en_in='1' then
        --elsif  clk'event and clk='1' and  en_in='1' then
           en_in_reg<='1';
       -- if en_in='1' then
          if not(endfile(simu_din)) then
             readline(simu_din,line_in);
             read(line_in,data_in_tmp);        
             data_in<=data_in_tmp;
          else
          assert false
          report "Simulation is finished!"
          severity Failure;
          end if;
        else
          data_in<="0";
          en_in_reg<='0';
        end if;
        
      end if;
  end process;  


end rtl;
