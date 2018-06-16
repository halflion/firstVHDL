library IEEE;
 use IEEE.STD_LOGIC_1164.ALL;
 use IEEE.STD_LOGIC_ARITH.ALL;
 use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity posedge_det is
     Port ( clk : in  STD_LOGIC;
            rst : in  STD_LOGIC;
            trigger : in  STD_LOGIC;
            rise : out  STD_LOGIC);
 end posedge_det;

architecture Behavioral of posedge_det is
 signal temp : std_logic;
 begin
  process(clk,rst)
  begin
   if (rst='0') then
    temp <= '0';
   elsif rising_edge(clk) then
    temp <= trigger;
   end if;
  end process;
  rise <= trigger and (not temp);
 end Behavioral;