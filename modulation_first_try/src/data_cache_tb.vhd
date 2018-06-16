
library ieee;  
use ieee.std_logic_1164.all; 
use ieee.std_logic_textio.all; 
use std.textio.all;  
use ieee.numeric_std.all;

entity data_cache_tb is    
end data_cache_tb;  
  
architecture rtl of data_cache_tb is  
  component data_cache
    generic (rate : integer := 4;
         framelen:integer:=32
);


 port(
   reset	  : in std_logic;
		clk_in	: in std_logic;
		clk_out	: in std_logic;
		data_in	: in std_logic_vector(0 downto 0);
		en_in   : in std_logic;
    en_out  : in std_logic;
    
		valid_out     : out std_logic;
		data_out      : out std_logic_vector(0 downto 0);
		sop           : out std_logic;
		eop           : out std_logic
		); 
  end component;  



 signal reset	:std_logic:='0';
  signal clk_in	:std_logic:='0';
  signal clk_out :std_logic:='1';
  signal data_in :std_logic_vector(0 downto 0);
  signal en_in	:std_logic:='0';
  signal en_out:std_logic:='0';
  signal valid_out:std_logic:='0';
  signal data_out:std_logic_vector(0 downto 0);
  signal sop:std_logic:='0';
  signal eop:std_logic:='0';
  signal rate : integer := 4;
 signal  framelen:integer:=32;

		


 
  constant clk_out_period :time :=20 ns;    
  constant clk_in_period :time :=80 ns;  
  begin  
    instant:data_cache 
     generic map
     (rate => 4,
         framelen => 32)
    port map  
    (  
      reset=>reset,
      clk_in=>clk_in,
      clk_out=>clk_out,
      data_in=>data_in,
      en_in=>en_in,
      en_out=>en_out,
      valid_out=>valid_out,
      data_out=>data_out,
      sop=>sop,
      eop=>eop
      );  
      
      
      
  clk_out_gen:process  
  begin      
    wait for clk_out_period/2;  
    clk_out<='0';    
    wait for clk_out_period/2;  
    clk_out<='1';  
  end process;  

  clk_in_gen:process  
  begin      
    wait for clk_in_period/2;  
    clk_in<='1';    
    wait for clk_in_period/2;  
    clk_in<='0';  
  end process; 
    
  reset_gen:process  
  begin  
    reset<='1';  
    wait for 40 ns;  
    reset<='0';  
    wait;  
  end process;  

 en_in_gen:process  
  begin  
   en_in<='0';  
    wait for 80 ns;  
    en_in<='1';  
    wait for 2560ns;
    en_in<='0'; 
    wait for 3320ns;
    en_in<='1'; 
    wait for 2560ns;
    en_in<='0'; 
     wait for 12800ns;
    en_in<='1'; 
    wait for 2560ns;
    en_in<='0'; 
    wait;
  end process;  
      
      
 en_out_gen:process  
  begin  
   en_out<='0';  
    wait for 400 ns;  --需要等待
    --wait for 2300 ns;  --未存完，但是可以直接读 valid_out 差一个时钟
    --wait for 2860 ns;  --已存完，直接读
    en_out<='1'; 
    wait for 30ns;
    en_out<='0';  
    wait for 13440ns;
    en_out<='1';
     wait for 30ns;
    en_out<='0';  
    wait for 70800ns;
    en_out<='1';
     wait for 30ns;
    en_out<='0';  
    wait;
  end process;  
  
 data_in_gen:process(clk_in,reset,en_in)
    file simu_din:text open read_mode is "simu.txt";
    variable line_in:line;
    variable data_in_tmp: std_logic_vector(0 downto 0);
      
     begin  
      if reset='1' then
        data_in<="0";
        elsif  clk_in'event and clk_in='1' and  en_in='1' then
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
      end if;
  end process;  

end rtl;  