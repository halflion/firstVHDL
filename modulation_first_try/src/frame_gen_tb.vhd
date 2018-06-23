library ieee;
use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;
use ieee.std_logic_textio.all; 
use std.textio.all; 

entity frame_gen_tb is
end frame_gen_tb;


architecture rtl of frame_gen_tb is
    component frame_gen
        generic ( 
                cp_num : positive := 4;
                sp_num : positive := 4
            );

        Port ( 
                reset		: in std_logic;
                clk_in		: in std_logic;
                clk_out		: in std_logic;
                data_in  	: in std_logic_vector(0 downto 0);
                valid_in 	: in std_logic;
                eop      	: in std_logic;
                sop	        : in std_logic;

                data_out_I  	: out std_logic_vector(0 downto 0);
                data_out_Q 	: out std_logic_vector(0 downto 0);
                valid_out   : out std_logic;
                data_en     : out std_logic);   
    end component;  

    signal reset :  STD_LOGIC;   
    signal clk_in : std_logic;
    signal clk_out : std_logic;
    signal data_in : std_logic_vector(0 downto 0);
    signal en_in :  STD_LOGIC;  
    signal sop :   STD_LOGIC;
    signal eop :   STD_LOGIC;
    signal data_out_I:  std_logic_vector(0 downto 0);
    signal data_out_Q:  std_logic_vector(0 downto 0);
    signal valid_out :   STD_LOGIC;
    signal data_en :  STD_LOGIC;
    signal en_in_reg : STD_LOGIC;

    constant clk_in_period :time :=10 ns;  
    constant clk_out_period :time :=10 ns;  

    begin  
        instant:frame_gen
            generic map
            (
                cp_num => 4,
                sp_num => 4)
            port map  
            (
                reset	    =>reset	     ,
                clk_in	    =>clk_in	 ,  
                clk_out	    =>clk_out    ,
                data_in     =>data_in    ,
                valid_in    =>en_in_reg  ,
                eop         =>eop        ,
                sop	        =>sop	     ,
                data_out_I    =>data_out_I   ,
                data_out_Q    =>data_out_Q   ,
                valid_out   =>valid_out  ,               
                data_en     =>data_en    
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
            clk_in<='0';    
            wait for clk_in_period/2;  
            clk_in<='1';  
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
            wait for 360 ns;  
            en_in<='1';  
            wait for 6400 ns;
            en_in<='0'; 
            wait for 3320 ns;
            wait for 12800 ns;
            en_in<='1'; 
            wait for 6400 ns;
            en_in<='0'; 
            wait for 12800 ns;
            wait for 12800 ns;
            en_in<='1'; 
            wait for 6400 ns;
            en_in<='0'; 
            wait for 12800 ns;
            wait for 8000 ns;  
            en_in<='1';  
            wait for 6400 ns;
            en_in<='0'; 
            wait for 3320 ns;
            wait for 12800 ns;
            en_in<='1'; 
            wait for 6400 ns;
            en_in<='0'; 
            wait for 12800 ns;
            wait for 12800 ns;
            en_in<='1'; 
            wait for 6400 ns;
            en_in<='0'; 
            wait;
        end process;  
      
    sop_gen:process  
        begin  
            sop<='0';  
            wait for 360 ns;  
            sop<='1';  
            wait for  clk_in_period ;
            sop<='0'; 
            wait for 12800 ns;
            wait for 6380 ns;
            wait for 3320 ns;
            sop<='1'; 
            wait for  clk_in_period ;
            sop<='0'; 
            wait for 12800 ns;
            wait for 19180 ns;
            sop<='1'; 
            wait for  clk_in_period ;
            sop<='0';  
            wait for 14380 ns;  
            wait for 12800 ns;
            sop<='1';  
            wait for  clk_in_period ;
            sop<='0';  
            wait for 12800 ns;
            wait for 9700 ns;
            sop<='1'; 
            wait for  clk_in_period ;
            sop<='0'; 
            wait for 12800 ns;
            wait for 19180 ns;
            sop<='1'; 
            wait for  clk_in_period ;
            sop<='0';  
            wait;
        end process;  

    eop_gen:process  
        begin  
            eop<='0';  
            wait for 6750 ns;
            eop<='1';  
            wait for  clk_in_period ;
            eop<='0'; 
            wait for 12800 ns;
            wait for 3940 ns;
            wait for 5760 ns;
            eop<='1'; 
            wait for  clk_in_period ;
            eop<='0'; 
            wait for 12800 ns;
            wait for 5760 ns;
            wait for 13420 ns;
            eop<='1'; 
            wait for  clk_in_period ;
            eop<='0'; 
            wait for 12800 ns;
            wait for 5760 ns;
            wait for 8000 ns;  
            wait for 620 ns; 
            eop<='1';  
            wait for  clk_in_period ;
            eop<='0'; 
            wait for 12800 ns;
            wait for 3320 ns;
            wait for 620 ns; 
            eop<='1'; 
            wait for  clk_in_period ;
            eop<='0'; 
            wait for 12800 ns;
            wait for 5760 ns;
            wait for 12800 ns; wait for 620 ns; 
            eop<='1'; 
            wait for  clk_in_period ;
            eop<='0'; 
            wait;
        end process;  
  
    data_in_gen:process(clk_in,reset,en_in)
        file simu_din:text open read_mode is "simu.txt";
        variable line_in:line;
        variable data_in_tmp: std_logic_vector(0 downto 0);
        
        begin  
            if reset='1' then
                data_in<="0";
                en_in_reg<='0';
            elsif  rising_edge(clk_in) then
                en_in_reg<=en_in;

                if  en_in='1' then
                --elsif  clk'event and clk='1' and  en_in='1' then
                
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

                end if;
            end if;
    end process;  


end rtl;