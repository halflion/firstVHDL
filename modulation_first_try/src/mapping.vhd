-- use rotation,not mirror mapping
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mapping is 
  generic(
      kDataWidth  : positive := 14);
  port(
		reset    : in std_logic;
		clk       : in std_logic;   --I and Q are both 2 bits,needn't serial to parial
		data_en   : in std_logic;  ----0:when SP,LP,UW is modulated; 1:when data is modulated
		
		Datain_I  : in std_logic_vector(1 downto 0); 
		Datain_Q  : in std_logic_vector(1 downto 0); 
		validin   : in std_logic;
			
		DataOutRdy   : out std_logic; 
		DataOut_I    : out std_logic_vector(kDataWidth-1 downto 0); 
		DataOut_Q    : out std_logic_vector(kDataWidth-1 downto 0)		              
      );
end entity;

architecture rtl of mapping is
constant cons_Qpsk : positive := 784; --3134= N*sqrt(2)/2
	
	signal sPosition : std_logic_vector(1 downto 0);
	signal smapping_I : signed(kDataWidth-1 downto 0);
	signal smapping_Q : signed(kDataWidth-1 downto 0);

begin	
	sPosition <= Datain_I(0) & Datain_Q(0);
	
	process(Clk,reset)
	begin
		if (reset='1') then
			DataOutRdy <= '0';
			smapping_I <= (others =>'0');
			smapping_Q <= (others =>'0');	
		elsif rising_edge(Clk) then
			if validin = '1' then
                DataOutRdy <= '1';
                if data_en ='1' then 
			  		  case sPosition is 
						when "00" =>
							smapping_I <= to_signed(-cons_Qpsk, kDataWidth);
							smapping_Q <= to_signed(-cons_Qpsk, kDataWidth);					   
						when "01" =>
							smapping_I <= to_signed(-cons_Qpsk, kDataWidth);
							smapping_Q <= to_signed(cons_Qpsk, kDataWidth);	
						when "11" =>
							smapping_I <= to_signed(cons_Qpsk, kDataWidth);
							smapping_Q <= to_signed(cons_Qpsk, kDataWidth);	
						when others => --10
							smapping_I <= to_signed(cons_Qpsk, kDataWidth);
							smapping_Q <= to_signed(-cons_Qpsk, kDataWidth);				   
					  end case;
                end if;
			else
				DataOutRdy <= '0';
				smapping_I <= to_signed(0, kDataWidth);
				smapping_Q <= to_signed(0, kDataWidth);				 
			end if;
		end if;
	end process;   
	
	DataOut_I <= std_logic_vector(smapping_I); 
	DataOut_Q <= std_logic_vector(smapping_Q); 

end rtl;
