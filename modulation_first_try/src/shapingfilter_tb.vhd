library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all; 
use std.textio.all; 

entity shapingfilter_tb is
end shapingfilter_tb;


architecture rtl of shapingfilter_tb is
    component shapingfilter
        generic ( 
            kInSize       : positive := 8;
            kOutSize       : positive := 12
            );

        Port ( 
            reset		: in  std_logic;
            clk_in			: in  std_logic;
            data_in		: in  std_logic_vector(kInSize-1 downto 0);
            clk_out		: in std_logic;           
            data_out		: out std_logic_vector(kOutSize-1 downto 0)     
            );
    end component;  

    signal reset :  STD_LOGIC;   
    signal clk_in : std_logic;
    signal clk_out : std_logic;
    signal data_in : std_logic_vector(7 downto 0);
    signal data_out:  std_logic_vector(11 downto 0);


    constant clk_in_period :time :=40 ns;  
    constant clk_out_period :time :=10 ns;  

    begin  
        instant:shapingfilter
            generic map
            (
                kInSize   => 8,
                kOutSize  => 12)
            port map  
            (
                reset	    =>reset	     ,
                clk_in	    =>clk_in	 ,  
                data_in     =>data_in    ,
                clk_out	    =>clk_out    ,

                data_out    =>data_out    
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
            wait for 35 ns;  
            reset<='0';  
            wait;  
        end process;  

   
  
    data_in_gen:process(clk_in,reset)
        file simu_din:text open read_mode is "simu.txt";
        variable line_in:line;
        variable data_in_tmp: std_logic_vector(0 downto 0);
        
        begin  
            if reset='1' then
                -- data_in_tmp<="0";
                data_in<="00000000";
            elsif  rising_edge(clk_in) then
            -- if en_in='1' then
                if not(endfile(simu_din)) then
                    readline(simu_din,line_in);
                    read(line_in,data_in_tmp);        
                    data_in<=data_in_tmp&data_in_tmp&data_in_tmp&data_in_tmp&data_in_tmp&data_in_tmp&data_in_tmp&data_in_tmp;
                else
                    assert false
                    report "Simulation is finished!"
                    severity Failure;
                end if;

            end if;
    end process;  


end rtl;