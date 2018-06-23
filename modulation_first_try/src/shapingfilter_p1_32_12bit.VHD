--————————————————————————————
--本程序为自动生成 (17-Apr-2017)
--功能：1路并行CFIR滤波
--————————————————————————————
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity	shapingfilter_p1_32_12bit	is
	 generic(
		kInSize  : positive :=12;
		kOutSize : positive :=12);
port(
		reset	: in std_logic;
		Clk		: in std_logic;
		cDin0	: in std_logic_vector(kInSize-1 downto 0);
		cDout0	: out std_logic_vector(kOutSize-1 downto 0)
		);
end	shapingfilter_p1_32_12bit;
architecture rtl of	shapingfilter_p1_32_12bit	is 
	type IntegerArray is array (natural range <>) of integer;
	--滤波器系数
	constant kTap : IntegerArray(0 to	16)	:=(33,218,157,-156,-417,-242,420,1071,936,-362,-2215,-3091,-1388,3389,9958,15682,17951);
	--系数位宽
	constant kCoeSize : positive :=16;
	--输入数据缓存器
	type InputRegArray is array (natural range <>) of std_logic_vector(kInSize-1 downto 0);
	signal cInputReg : InputRegArray(32 downto 0);
	--求和数据缓存器，为了求和溢出，需要扩充1bit
	type SumRegArray is array (natural range <>) of signed (kInSize downto 0);
	signal cSumReg : SumRegArray(16 downto 0);
	--中间寄存器数组类型
	type InterRegArray is array (natural range <>) of signed (kCoeSize+kInSize downto 0);
	--定义中间寄存器
	signal cInterReg : InterRegArray (36 downto 0);
begin
process (reset, Clk)
	begin
		if reset='1' then
		--对输入寄存器初始化
			for i in 0 to	32 loop
				cInputReg(i)	<= (others => '0');
			end loop;
		--对求和寄存器初始化
			for i in 0 to	16 loop
				cSumReg(i)	<= (others => '0');
			end loop;
		--对中间寄存器初始化
			for i in 0 to	36 loop
				cInterReg(i)	<= (others => '0');
			end loop;
		--对输出端口初始化
			cDout0	<= (others => '0');
		elsif rising_edge(Clk) then
			--输入数据缓存

			cInputReg(0)	<=cDin0;

			cInputReg(1)	<=cInputReg(0);

			cInputReg(2)	<=cInputReg(1);

			cInputReg(3)	<=cInputReg(2);

			cInputReg(4)	<=cInputReg(3);

			cInputReg(5)	<=cInputReg(4);

			cInputReg(6)	<=cInputReg(5);

			cInputReg(7)	<=cInputReg(6);

			cInputReg(8)	<=cInputReg(7);

			cInputReg(9)	<=cInputReg(8);

			cInputReg(10)	<=cInputReg(9);

			cInputReg(11)	<=cInputReg(10);

			cInputReg(12)	<=cInputReg(11);

			cInputReg(13)	<=cInputReg(12);

			cInputReg(14)	<=cInputReg(13);

			cInputReg(15)	<=cInputReg(14);

			cInputReg(16)	<=cInputReg(15);

			cInputReg(17)	<=cInputReg(16);

			cInputReg(18)	<=cInputReg(17);

			cInputReg(19)	<=cInputReg(18);

			cInputReg(20)	<=cInputReg(19);

			cInputReg(21)	<=cInputReg(20);

			cInputReg(22)	<=cInputReg(21);

			cInputReg(23)	<=cInputReg(22);

			cInputReg(24)	<=cInputReg(23);

			cInputReg(25)	<=cInputReg(24);

			cInputReg(26)	<=cInputReg(25);

			cInputReg(27)	<=cInputReg(26);

			cInputReg(28)	<=cInputReg(27);

			cInputReg(29)	<=cInputReg(28);

			cInputReg(30)	<=cInputReg(29);

			cInputReg(31)	<=cInputReg(30);

			cInputReg(32)	<=cInputReg(31);


			--第1条支路
			--************求和以利用对称性************
			cSumReg(0)	<=signed(cInputReg(32)(kInSize-1)&cInputReg(32))+signed(cInputReg(0)(kInSize-1)&cInputReg(0));
			cSumReg(1)	<=signed(cInputReg(31)(kInSize-1)&cInputReg(31))+signed(cInputReg(1)(kInSize-1)&cInputReg(1));
			cSumReg(2)	<=signed(cInputReg(30)(kInSize-1)&cInputReg(30))+signed(cInputReg(2)(kInSize-1)&cInputReg(2));
			cSumReg(3)	<=signed(cInputReg(29)(kInSize-1)&cInputReg(29))+signed(cInputReg(3)(kInSize-1)&cInputReg(3));
			cSumReg(4)	<=signed(cInputReg(28)(kInSize-1)&cInputReg(28))+signed(cInputReg(4)(kInSize-1)&cInputReg(4));
			cSumReg(5)	<=signed(cInputReg(27)(kInSize-1)&cInputReg(27))+signed(cInputReg(5)(kInSize-1)&cInputReg(5));
			cSumReg(6)	<=signed(cInputReg(26)(kInSize-1)&cInputReg(26))+signed(cInputReg(6)(kInSize-1)&cInputReg(6));
			cSumReg(7)	<=signed(cInputReg(25)(kInSize-1)&cInputReg(25))+signed(cInputReg(7)(kInSize-1)&cInputReg(7));
			cSumReg(8)	<=signed(cInputReg(24)(kInSize-1)&cInputReg(24))+signed(cInputReg(8)(kInSize-1)&cInputReg(8));
			cSumReg(9)	<=signed(cInputReg(23)(kInSize-1)&cInputReg(23))+signed(cInputReg(9)(kInSize-1)&cInputReg(9));
			cSumReg(10)	<=signed(cInputReg(22)(kInSize-1)&cInputReg(22))+signed(cInputReg(10)(kInSize-1)&cInputReg(10));
			cSumReg(11)	<=signed(cInputReg(21)(kInSize-1)&cInputReg(21))+signed(cInputReg(11)(kInSize-1)&cInputReg(11));
			cSumReg(12)	<=signed(cInputReg(20)(kInSize-1)&cInputReg(20))+signed(cInputReg(12)(kInSize-1)&cInputReg(12));
			cSumReg(13)	<=signed(cInputReg(19)(kInSize-1)&cInputReg(19))+signed(cInputReg(13)(kInSize-1)&cInputReg(13));
			cSumReg(14)	<=signed(cInputReg(18)(kInSize-1)&cInputReg(18))+signed(cInputReg(14)(kInSize-1)&cInputReg(14));
			cSumReg(15)	<=signed(cInputReg(17)(kInSize-1)&cInputReg(17))+signed(cInputReg(15)(kInSize-1)&cInputReg(15));
			cSumReg(16)	<=signed(cInputReg(16)(kInSize-1)&cInputReg(16));
			--************与系数相乘************
			cInterReg(0)	<= cSumReg(0)*to_signed(kTap(0),kCoeSize);
			cInterReg(1)	<= cSumReg(1)*to_signed(kTap(1),kCoeSize);
			cInterReg(2)	<= cSumReg(2)*to_signed(kTap(2),kCoeSize);
			cInterReg(3)	<= cSumReg(3)*to_signed(kTap(3),kCoeSize);
			cInterReg(4)	<= cSumReg(4)*to_signed(kTap(4),kCoeSize);
			cInterReg(5)	<= cSumReg(5)*to_signed(kTap(5),kCoeSize);
			cInterReg(6)	<= cSumReg(6)*to_signed(kTap(6),kCoeSize);
			cInterReg(7)	<= cSumReg(7)*to_signed(kTap(7),kCoeSize);
			cInterReg(8)	<= cSumReg(8)*to_signed(kTap(8),kCoeSize);
			cInterReg(9)	<= cSumReg(9)*to_signed(kTap(9),kCoeSize);
			cInterReg(10)	<= cSumReg(10)*to_signed(kTap(10),kCoeSize);
			cInterReg(11)	<= cSumReg(11)*to_signed(kTap(11),kCoeSize);
			cInterReg(12)	<= cSumReg(12)*to_signed(kTap(12),kCoeSize);
			cInterReg(13)	<= cSumReg(13)*to_signed(kTap(13),kCoeSize);
			cInterReg(14)	<= cSumReg(14)*to_signed(kTap(14),kCoeSize);
			cInterReg(15)	<= cSumReg(15)*to_signed(kTap(15),kCoeSize);
			cInterReg(16)	<= cSumReg(16)*to_signed(kTap(16),kCoeSize);
			--*****************求和*****************
			--*****************pipline1*****************
			cInterReg(17)	<=cInterReg(0)+cInterReg(1)+cInterReg(2)+cInterReg(3);
			cInterReg(18)	<=cInterReg(4)+cInterReg(5)+cInterReg(6)+cInterReg(7);
			cInterReg(19)	<=cInterReg(8)+cInterReg(9)+cInterReg(10)+cInterReg(11);
			cInterReg(20)	<=cInterReg(12)+cInterReg(13)+cInterReg(14)+cInterReg(15);
			cInterReg(21)	<=cInterReg(16);
			--*****************pipline2*****************
			cInterReg(22)	<=cInterReg(17)+cInterReg(18)+cInterReg(19)+cInterReg(20);
			cInterReg(23)	<=cInterReg(21);
			--*****************pipline3*****************
			cInterReg(24)	<=cInterReg(22)+cInterReg(23);

			--输出数据
			cDout0	<= std_logic_vector(cInterReg(24)(kInSize+kCoeSize-3 downto kInSize+kCoeSize-kOutSize-2));
		end if;
	end process;
end rtl;
