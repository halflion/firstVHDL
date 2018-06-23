library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
---------------------------------------------
entity shapingfilter is 
    generic(
      kInSize       : positive := 8;
      kOutSize       : positive := 12
    );

    port (
      reset		: in  std_logic;
      clk_in			: in  std_logic;
      data_in		: in  std_logic_vector(kInSize-1 downto 0);
      clk_out		: in std_logic;
      
      data_out		: out std_logic_vector(kOutSize-1 downto 0)     
     );
end shapingfilter;

architecture rtl of shapingfilter is
--------------------------------------------
	
	component	shapingfilter_p1_32_12bit	is
	generic(
			kInSize  : positive :=8;
			kOutSize : positive :=12);
	port(
			reset	: in std_logic;
			Clk		: in std_logic;
			cDin0		: in std_logic_vector(kInSize-1 downto 0);

			cDout0	: out std_logic_vector(kOutSize-1 downto 0)
			);
	end	component;
	
	signal cDin0,cDin1,cDin2,cDin3,data_out_d : std_logic_vector(kInSize-1 downto 0);
	signal data_out_shap : std_logic_vector(kOutSize-1 downto 0);
	
	signal counter  : integer range 0 to 3;
	
begin
	process( reset , clk_out )
	begin
		if reset = '1' then
			counter <= 0;
		elsif rising_edge ( clk_out ) then
			if counter = 3 then
				counter <= 0;
			else
				counter <= counter+1;
			end if;
		end if;
	end process;
	
	process( reset , clk_in )
	begin
		if reset = '1' then
			cDin0 <= ( others=>'0');
			cDin1 <= ( others=>'0');
			cDin2 <= ( others=>'0');
			cDin3 <= ( others=>'0');
		elsif rising_edge ( clk_in ) then
				cDin0 <= data_in;
				cDin1 <= ( others=>'0');
				cDin2 <= ( others=>'0');
				cDin3 <= ( others=>'0');	
		end if;
	end process;
		
	shapingfilter_p1_32_12bit_inst : shapingfilter_p1_32_12bit
	generic map(
		8,
		12)
	port map(
		reset	=> reset,
		Clk		=> clk_out,
		cDin0		=> data_out_d,

		cDout0	=> data_out_shap
		);	
		
--------------------------------------------
	process( reset , clk_out )
	begin
		if reset = '1' then
			data_out <= (others=>'0');
		elsif rising_edge( clk_out) then
				data_out <= data_out_shap;
		end if;
	end process;
	
	process( reset , clk_out )
	begin
		if reset = '1' then
			data_out_d <= (others=>'0');
		elsif rising_edge( clk_out) then
			case counter is
				when 2 =>
					data_out_d <= cDin0;
				when 3 =>
					data_out_d <= cDin1;
				when 0 =>
					data_out_d <= cDin2;
				when 1 =>
					data_out_d <= cDin3;
				when others =>
					data_out_d <= cDin0;
		    end case;
		end if;
	end process;
				
end rtl;
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
					
	