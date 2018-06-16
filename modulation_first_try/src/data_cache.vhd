library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity data_cache is

generic (rate : integer := 4;
         framelen:integer:=2048
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
end entity;

architecture rtl of data_cache is

component fifo_generator_0 IS
  PORT (
    rst           : IN STD_LOGIC;
    wr_clk        : IN STD_LOGIC;
    rd_clk        : IN STD_LOGIC;
    din           : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    wr_en         : IN STD_LOGIC;
    rd_en         : IN STD_LOGIC;
    dout          : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    full          : OUT STD_LOGIC;
    empty         : OUT STD_LOGIC
  );
END component;

-- component posedge_det IS
--   PORT (
--             clk : in  STD_LOGIC;
--             rst : in  STD_LOGIC;
--             trigger : in  STD_LOGIC;
--             rise : out  STD_LOGIC
--   );
-- END component;

--constant framelen:integer:=2048;  
--signal counter : integer range 0 to 16384;
--signal validout_reg,validout_reg1,valid_reg0,valid_reg1,rd_ena : std_logic;
--signal empty,rd_ena_reg : std_logic;

signal data_out_reg,data_out_reg1	: std_logic_vector(0 downto 0);
signal rd_en   : std_logic;
signal rd_en_reg   : std_logic;
signal empty      : std_logic;
signal en_out_reg : std_logic;
signal valid_out_reg1,valid_out_reg : std_logic;
signal framelen_inst: integer range 0 to 16192;
signal wr_en: std_logic;
signal count_rd:integer range 0 to 16192;
signal count_rd_reg:integer range 0 to 16192;
signal count_wr: integer range 0 to 16192;
signal count_wr_reg: integer range 0 to 16192;
signal count_base:integer range 0 to 16192;
signal count_base_bit:bit_vector(13 downto 0);
signal done_wr:std_logic;
signal wait_rd:std_logic;
signal sop_reg,sop_reg1:std_logic;
signal eop_reg,eop_reg1:std_logic;
signal data_in_reg,data_in_reg1:std_logic_vector(0 downto 0);
signal count_wr_to_rd:integer range 0 to 16192;
--signal rst_mid:std_logic;


begin

fifo_1to1_diffclk_data_inst : fifo_generator_0
  PORT map(
    rst		=> reset, --or s_Reset_mid,
    wr_clk	=> clk_in,
    rd_clk	=> clk_out,
    din		=> data_in_reg1,
    wr_en	=> wr_en,--en_in,
    rd_en	=> rd_en,
    dout	=> data_out_reg1,
    full	=> open,
    empty	=> empty); 

-- posedge_det_inst : posedge_det
--   PORT map(
--   clk      => clk_out,
--   rst      => reset, --or s_Reset_mid,
--   trigger  =>  en_out,
--   rise =>rise
--  ); 
  
  ------------组合逻辑直接赋值，之后要尽量全改掉----------
   data_out<=data_out_reg;    
   count_wr	<= count_wr_reg;
   
   
process(reset,clk_out)
begin

	if reset = '1'   then   
    valid_out_reg1<= '0';
		sop_reg1<='0';
		sop_reg<='0';
		eop_reg1<='0';	

    rd_en_reg   <=  '0';
		wait_rd<='0';
		count_rd_reg<=0;
		count_rd<=0;


------------------------读取-----------------
	elsif rising_edge(clk_out) then
	  sop_reg<=sop_reg1;
    count_rd	<= count_rd_reg;
	  sop<=sop_reg;
		if (done_wr='1' or (count_wr_to_rd >= count_base and count_wr_to_rd <= framelen_inst)) and en_out_reg='1' then	-----写完或者正在写，可以保证不读空
			rd_en_reg<='1';	
			
		elsif  count_wr_to_rd < count_base  and en_out_reg='1'  then---------------正在写，不能读，等待
		  wait_rd <='1';
		  
		elsif  wait_rd ='1' and count_wr_to_rd = count_base then      ---------等待完毕，开始读
		  wait_rd <='0';
		  rd_en_reg<='1';

		end if;
    
 
		if rd_en='0' and rd_en_reg='1'  then
        sop_reg1<='1';	
    else
        sop_reg1<='0';
	  end if;

    if rd_en_reg='1' and count_rd=0 then
		valid_out_reg1<= '1';
    end if;


    
		-------------------读取计数并结束-------------------------
		if rd_en='1' or eop_reg='1' then

     case count_rd is 
      when  0 =>	  count_rd_reg<=count_rd_reg+1;		
      when  1 =>		count_rd_reg<=count_rd_reg+1;sop_reg<=sop_reg1;sop<=sop_reg;
      WHEN framelen-3 =>eop_reg1<='1';rd_en_reg<='0';count_rd_reg<=count_rd_reg+1;
      WHEN framelen-2 =>eop_reg1<='0';valid_out_reg1<= '0';count_rd_reg<=count_rd_reg+1;
		  WHEN framelen-1 =>count_rd_reg<=0;
      WHEN OTHERS =>  	  	count_rd_reg<=count_rd_reg+1;
     end case;	
	   end if;

   end if;
    
end process;
		
		
		




---------------写入------------------

process(reset,clk_in)
begin

	if reset = '1'   then   
		count_wr_reg	<= 0;
    wr_en<='0';

  elsif rising_edge(clk_in) and (en_in='1' or wr_en='1') then
     case count_wr_reg is 
      when  0 =>	  count_wr_reg<=count_wr+1;wr_en<='1';
      when  framelen=>		count_wr_reg <= 0;wr_en<='0';
		  WHEN OTHERS =>  	count_wr_reg<=count_wr+1;wr_en<='1';
     end case;
	end if;
	
end process;

process(reset,clk_in)
begin

	if reset = '1'  or rd_en_reg='1' then   
    done_wr<='0';

  elsif rising_edge(clk_in) and  count_wr_reg=framelen-1 and wr_en='1' and rd_en='0' then
      done_wr<='1' ;     
	end if;
	
end process;




------------------------时钟同步等------------------


process(reset,clk_out)
    begin
	    if reset = '1'  then   
         framelen_inst   <=  0;
         count_wr_to_rd<=0;
         
       elsif en_in='1' then
         framelen_inst<=framelen;
         count_wr_to_rd<=count_wr;
         
       end if;
end process;

process(reset,clk_out)
    begin
	    if reset = '1'  then                   
           data_out_reg<="0";
           en_out_reg<='0';
           rd_en<='0';
           eop_reg<='0';
           eop<='0';
           valid_out_reg<='0';
           valid_out<='0';
           --data_out_reg1<="0";
      elsif  rising_edge(clk_out) then
           data_out_reg<=data_out_reg1;
           en_out_reg<=en_out;
           rd_en<=rd_en_reg;
           eop_reg<=eop_reg1;
           eop<=eop_reg;
           valid_out_reg<=valid_out_reg1;
           valid_out<=valid_out_reg;
                  
      end if;
end process;

process(reset,clk_in)
    begin
	    if reset = '1'  then                   
            data_in_reg<="0";
            data_in_reg1<="0";
      elsif  rising_edge(clk_in) then
            data_in_reg1<=data_in;
            data_in_reg<=data_in_reg1;
      end if;
end process;
		
				

process(reset,clk_out)
   begin
     if reset = '1'  then 
       count_base <= 0;
     else
       count_base_bit<= to_bitvector(std_logic_vector(conv_unsigned(framelen, 14))); 
       CASE rate IS
         WHEN 2 =>  count_base <=framelen- conv_integer( unsigned(to_stdlogicvector( count_base_bit srl 1)))+rate;
         WHEN 4 =>  count_base <=framelen- conv_integer( unsigned(to_stdlogicvector( count_base_bit srl 2)))+rate;
         WHEN 8 =>  count_base <=framelen- conv_integer( unsigned(to_stdlogicvector( count_base_bit srl 3)))+rate;
         WHEN OTHERS => count_base <= 1;
       END CASE;
    end if;
end process;


end rtl;

			