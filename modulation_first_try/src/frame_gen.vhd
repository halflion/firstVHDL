-------------------------------------------------------------------------------
-- (c) 2012 Copyright Wireless Broadband Transmission Lab
-- All Rights Reserved
-- EE Dept. at Tsinghua University.
-- Author: tan jingjing 
-- Date: 2018
-- including submodules
-- Ram_burst: write and read the data sequence.
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frame_gen is
	generic(
		sp_num : positive := 4;
		cp_num : positive := 4
		);
	port(
		reset		: in std_logic;
		clk_in		: in std_logic;
		clk_out		: in std_logic;
		data_in  	: in std_logic_vector(0 downto 0);
		valid_in 	: in std_logic;
		eop	: in std_logic;
		sop	: in std_logic;

		data_out  	: out std_logic_vector(0 downto 0);
		valid_out   : out std_logic;
		data_en     : out std_logic   
		);
end entity;

architecture rtl of frame_gen is
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

  constant sp_len : positive :=32; 
	constant cp_len : positive :=32; 
	constant lp_len : positive :=32; 
	constant frame_len : positive := 544;--255*2+34
	constant data_len : positive :=32;
	constant UW_len : positive :=32;
	constant sp_gen : std_logic_vector(0 to sp_len-1) :=
	"11111110111010100001001011011111";
	constant CP_gen : std_logic_vector(0 to cp_len-1) :=
	"11000110111010100001001011001110";
	constant LP_gen : std_logic_vector(0 to lp_len-1) :=
	"10011110001000111010001001100100";
	constant UW_gen : std_logic_vector(0 to UW_len-1) := --pn31 code+1bit=32bits
	"11000111110011010010000101011100"; --the last bit is added!! 
	constant frame_Num : positive :=20; --frame is composed by 576 syms,section is composed by 16 frames
	constant delay : positive :=32;
	-- 当前配置 数据640=32*20
	--         SP 32*4
	-- 				CP 32*4
	-- 				LP 32
	-- 				UW 32
	-- 				打包后总长度 32*9+640+32*21=1600
	
	type state_t is (idle, powerrdy, sp, cp, lp, UW1, data);
	signal state, next_state : state_t;
	-- idle :  Idle
	-- wrdata : write data into Ram
	-- waitm0 : wait for m0
	-- cp  : send cp_gen
	-- lp :  send lp_gen
	-- UW1 :  send first UW_gen
	-- data : send data
	-- UW2 : send second UW_gen
	-- state judge
	signal eop_dly, sop_dly : std_logic_vector(1 downto 0);
	signal sp_finish, cp_finish, lp_finish, UW1_finish : std_logic;
	signal UW2_finish, data_finish: std_logic;
	signal spaddress : integer range 0 to 1023;
	signal cpaddress : integer range 0 to 1023;
	signal lpaddress : integer range 0 to 1023;
	signal uw1address,uw2address : integer range 0 to 63;
	signal frame_count : integer range 0 to 63;
	signal count : integer range 0 to 1023;
	signal empty :std_logic;
	---- fifo

	signal rden_data : std_logic;
	-- tmp
	signal data_out_tmp : std_logic_vector(0 downto 0);
	signal validout_tmp : std_logic;
	signal ram_out_data : std_logic_vector(0 downto 0);
	signal dataen_reg : std_logic;
	signal flag_data : std_logic;-- data frame;
	signal cnt_cp : integer range 0 to cp_len-1;
	signal cnt_sp : integer range 0 to sp_len-1;
	signal cnt_power : integer range 0 to 1023; 
	signal power_ready,data_send : std_logic;
	
begin



	PreventMeatstable : process( clk_out, reset )
	begin
		if reset = '1' then
			eop_dly <= (others=>'0');
		elsif rising_edge (clk_out) then
			if  eop = '1' then
				eop_dly(0) <='1';
				eop_dly(1) <=eop_dly(0);
			else
				eop_dly(0) <='0';
				eop_dly(1) <=eop_dly(0);
			end if;
		end if;
	end process;
	
	PreventMeatstable2 : process( clk_out, reset )
	begin
		if reset = '1' then
			sop_dly	<= ( others => '0');
			flag_data    <= '0';
			data_send        <= '0';
		elsif rising_edge ( clk_out ) then
			sop_dly(0) <= sop;
			sop_dly(1) <= sop_dly(0);
            if sop_dly(1) = '0' and sop_dly(0) = '1' then
                data_send    <= '1';
            else
                data_send    <= '0';
            end if;
            if sop_dly(1) = '1' then
                flag_data    <= '1';
            else
                flag_data    <= flag_data;
            end if;
		end if;
	end process;
-------------------------------------finite state machine ------------------------------------
	state_reg : process( clk_out, reset )
	begin 
		if reset = '1' then
			state <= idle;
		elsif rising_edge( clk_out ) then
			state <= next_state;
		end if;
	end process;
	
	-- next state logic
	State_machine: process(state,data_send,power_ready,eop_dly(1),sop_dly,sp_finish,cp_finish,lp_finish,uw1_finish,data_finish )
	begin
		next_state <= state;
		case state is
			when idle =>
				if data_send = '1' then --needn't wait until all the data are write into Ram
					next_state <= powerrdy;
					frame_count<=0;
				end if;
			when powerrdy =>
				if power_ready =  '1' then
				    if empty = '0' then --needn't wait until all the data are write into Ram
					   next_state <= sp;
					else
					   next_state  <= idle;
					end if;
				end if;
      when sp =>
				if sp_finish = '1' then
						next_state <= cp;
				end if;
			when cp =>
				if cp_finish = '1' then
						next_state <= lp;
				end if;
			when lp =>
			  if lp_finish ='1' then
			    next_state <= UW1;
			  end if;
			when UW1 =>
			  if UW1_finish ='1' then
					if frame_finish ='1' then --UW_count ="10000000" 128
						next_state <= idle;
					else
						next_state <= data;
					end if;
			  end if;
			when data =>
			  if data_finish ='1'  then
			    next_state <= UW1;
			  end if;
			when others =>
				next_state <= idle;
		end case;
	end process;

--------------------------------------- End of FSM code ----------------------------------------
	--write data,if 4bits is needed, we can apply another Ram_burst


	fifo_burst_data : fifo_generator_0
      PORT  map(
        rst     => reset,
        wr_clk  => clk_in,
        rd_clk  => clk_out,
        din     => data_in,
        wr_en   => valid_in,
        rd_en   => rden_data,
        dout    => ram_out_data,
        full    => open,
        empty   => empty

      );
		
	process(clk_out,reset,state)
	begin
      if reset ='1' then
        data_out_tmp <= "0";
        dataen_reg <= '0';
      elsif rising_edge(clk_out) then
			  case state is
			  	when sp =>
						data_out_tmp <=sp_gen(spaddress to spaddress); -- 0 to sp_len-1
						dataen_reg <= '0';
					when cp =>
						data_out_tmp <=cp_gen(cpaddress to cpaddress); --I=Q; 0 to cp_len-1
						dataen_reg <= '0';
					when lp =>
						data_out_tmp <=LP_gen(lpaddress to lpaddress);
						dataen_reg <= '0';
					when uw1 =>
						data_out_tmp <=UW_gen(uw1address to uw1address); --I=Q;
						dataen_reg <= '0';
					when data =>
						dataen_reg <= '1';
						data_out_tmp <=ram_out_data;
					when others =>
						dataen_reg <= '0';
						data_out_tmp <= "0";
        end case;
      end if;
	end process;       

process(clk_out,reset)
begin
    if reset = '1' then
        power_ready <= '0';
        cnt_power   <= 0;
    elsif rising_edge(clk_out) then
        if state = powerrdy then
            if cnt_power < delay then
                cnt_power   <= cnt_power + 1;
            elsif cnt_power = delay then
                power_ready <= '1';
								cnt_power   <= 0;
            end if;
				end if;
    end if;
end process;
                
             
          
process(clk_out,reset) --cp_state
begin
	if reset ='1' then
        cpaddress	<= 0;
        cp_finish	<= '0';
        cnt_cp		<= 0;	
	elsif rising_edge(clk_out) then
			if state =cp then
					if cpaddress < cp_len-1 then
							cpaddress <=cpaddress+1;
					else
							cpaddress <= 0;
					end if;
					if cpaddress = cp_len - 1 then
						cnt_cp	<= cnt_cp + 1;
					end if;
					if cnt_cp = cp_num -1 and cpaddress = cp_len-2 then --308 finish =>next_state =>state
						cp_finish <= '1';
					end if;
      else
					cnt_cp	<= 0;
					cpaddress<= 0;
					cp_finish<= '0';
			end if;
	end if;
end process;

process(clk_out,reset) --sp_state
begin
	if reset ='1' then
        spaddress	<= 0;
        sp_finish	<= '0';
        cnt_sp		<= 0;	
	elsif rising_edge(clk_out) then
			if state =sp then
					if spaddress < sp_len-1 then
							spaddress <=spaddress+1;
					else
							spaddress <= 0;
					end if;
					if spaddress = sp_len - 1 then
						cnt_sp	<= cnt_sp + 1;
					end if;
					if cnt_sp = sp_num -1 and spaddress = sp_len-2 then --308 finish =>next_state =>state
						sp_finish <= '1';
					end if;
      else
					cnt_sp	<= 0;
					spaddress<= 0;
					sp_finish<= '0';
			end if;
	end if;
end process;
  
process(clk_out,reset) --lp_state
begin
	if reset ='1' then
		lpaddress <= 0;
		lp_finish <= '0';
	elsif rising_edge(clk_out) then
		if state =lp then
		    if lpaddress < lp_len-1 then
							lpaddress <=lpaddress+1;
				else
							lpaddress <= 0;
				end if;

			if lpaddress =lp_len-2 then --574 finish =>next_state =>state
				lp_finish <= '1';
			end if;
		else
			lpaddress <= 0;
			lp_finish <= '0';
		end if;
	end if;
end process;
        
process(clk_out,reset) --UW1_state
	begin
		if reset ='1' then
			uw1address <= 0;
			uw1_finish <= '0';
		elsif rising_edge(clk_out) then
			if state =uw1 then
				if uw1address =uw_len-1 then --avoid overflow!
					uw1address <=0;
				else
					uw1address <=uw1address+1;
				end if;
				if uw1address =uw_len-2 then --62 finish =>next_state =>state
					uw1_finish <= '1';
				end if;
			else
				uw1address <= 0;
				uw1_finish <= '0';
			end if;
		end if;
end process; 
--  process(clk_out,reset) --UW2_state
--  begin
--    if reset ='1' then
--      uw2address <= 0;
--      uw2_finish <= '0';
--    elsif rising_edge(clk_out) then
--      if state =uw2 then
--        if uw2address =uw_len then --avoid overflow!
--          uw2address <=0;
--        else
--          uw2address <=uw2address+1;
--        end if;
--        if uw2address =uw_len-1 then --62
--          uw2_finish <= '1';
--        end if;
--      else
--        uw2address <= 0;
--        uw2_finish <= '0';
--      end if;
--    end if;
--  end process;  
  -- process(clk_out,reset) --
	-- 	begin
	-- 		if reset ='1' then
	-- 				frame_count <=0;
	-- 				data_finish <= '0';
	-- 		elsif rising_edge(clk_out) then

	-- 				if state /= idle then
	-- 						if state = data and next_state =uw1 then
	-- 								frame_count <=frame_count+1;
	-- 						end if;
	-- 						if frame_count =frame_Num then --=60 then
	-- 						  	data_finish <='1'; 
	-- 			--        elsif frame_count =frame_Num or frame_count=frame_Num*2 or frame_count=frame_Num*(section_Num-1) then
	-- 						else
	-- 						  	data_finish <='0';
	-- 						end if;
	-- 				else
	-- 					  frame_count <= 0;
	-- 				  	data_finish <= '0';
	-- 				end if;
	-- 		end if;
  -- end process;
    
  process(clk_out,reset) --data_state
  begin
    if reset ='1' then
      count <=0;
      data_finish <= '0';
    elsif rising_edge(clk_out) then
      if state =data then
			  if count =data_len-1 then --avoid overflow!
					count <=0;
				else
					count <= count+1;
				end if;
        
        if count =data_len-2 then --62
          data_finish <= '1';
        end if;
      else
        count <= 0;
        data_finish <= '0';
      end if;
    end if;
  end process; 
      
	process(clk_out, reset)
		begin
			if reset = '1' then
							rden_data   <= '0';
			elsif rising_edge( clk_out ) then
							if next_state=data then
									if flag_data = '1' then
											rden_data   <= '1';
									end if;
							else
									rden_data   <= '0';
							end if;
			end if;
	end process;
	
	process(clk_out, reset) -- process:data_out
		begin
			if reset='1' then
					data_out		<= (others=>'0');
					data_en			<= '0';
					validout_tmp	<= '0';
					valid_out		<= '0';
			elsif rising_edge ( clk_out ) then
					valid_out		<=validout_tmp;
					if state =sp or state =cp or state=lp or state=uw1 or state=data then
							validout_tmp <= '1';
					else
							validout_tmp <= '0';
					end if;

					if validout_tmp ='1' then
							data_en			<= dataen_reg;
							data_out	<= data_out_tmp;
					else

						data_out		<= "0";
						data_en			<= '0';
					end if;
			end if;
	end process;

	
end rtl;


				-- if frame_count<frame_Num-1 then
				-- 		frame_count<=frame_count+1;
				-- else frame_count<frame_Num-1 then
				-- 		frame_count<=0;
				-- end if;    还没想好放哪里