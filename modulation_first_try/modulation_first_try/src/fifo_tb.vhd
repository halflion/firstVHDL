
library ieee;  
use ieee.std_logic_1164.all; 
use ieee.std_logic_textio.all; 
use std.textio.all;  
use ieee.numeric_std.all;

entity fifo_tb is    
end fifo_tb;  
  
  



architecture rtl of fifo_tb is  
  component fifo_generator_0

    PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC
  );

  end component;  



 signal rst	:std_logic:='0';
  signal wr_clk:std_logic:='0';
  signal rd_clk :std_logic:='1';
  signal din :std_logic_vector(0 downto 0);
  signal wr_en	:std_logic:='0';
  signal rd_en:std_logic:='0';
  signal dout:std_logic_vector(0 downto 0);
  signal full:std_logic:='0';
  signal empty:std_logic:='0';
		


 
  constant rd_clk_period :time :=20 ns;    
  constant wr_clk_period :time :=80 ns;  
  begin  
    instant:fifo_generator_0

    port map  
    (  
      rst=>rst,
      wr_clk=>wr_clk,
      rd_clk=>rd_clk,
      din=>din,
      wr_en=>wr_en,
      rd_en=>rd_en,
      dout=>dout,
      full=>full,
      empty=>empty
      );  
      
      
      
  rd_clk_gen:process  
  begin      
    wait for rd_clk_period/2;  
    rd_clk<='0';    
    wait for rd_clk_period/2;  
    rd_clk<='1';  
  end process;  

  wr_clk_gen:process  
  begin      
    wait for wr_clk_period/2;  
    wr_clk<='1';    
    wait for wr_clk_period/2;  
    wr_clk<='0';  
  end process; 
    
  rst_gen:process  
  begin  
    rst<='1';  
    wait for 40 ns;  
    rst<='0';  
    wait;  
  end process;  

 wr_en_gen:process  
  begin  
   wr_en<='0';  
    wait for 80 ns;  
    wr_en<='1';  
    wait for 2560ns;
    wr_en<='0'; 
    wait;
  end process;  
      
      
 rd_en_gen:process  
  begin  
   rd_en<='0';  
    wait for 2480 ns;  
    rd_en<='1';  
    wait for 100ns;
    rd_en<='0'; 
    wait;
  end process;  
  
 din_gen:process(wr_clk,rst,wr_en)
    file simu_din:text open read_mode is "simu.txt";
    variable line_in:line;
    variable din_tmp: std_logic_vector(0 downto 0);
      
     begin  
      if rst='1' then
        din<="0";
        else if wr_en='1' and wr_clk'event and wr_clk='1' then
        if not(endfile(simu_din)) then
        readline(simu_din,line_in);
        read(line_in,din_tmp);        
        din<=din_tmp;
        else
        assert false
        report "Simulation is finished!"
        severity Failure;
        end if;
      end if;
  end if;      
  end process;  

end rtl;  