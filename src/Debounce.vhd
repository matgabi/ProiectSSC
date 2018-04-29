library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debounce is
    port(
            Clk: in std_logic;
            Rst: in std_logic;
            D_IN: in std_logic;
            Q_OUT: out std_logic
        );
end debounce;

architecture Behavioral of debounce is

signal Q1, Q2, Q3 : std_logic;

begin
--**Insert the following after the 'begin' keyword**
process(Clk)
begin
   if (Clk'event and Clk = '1') then
      if (Rst = '1') then
         Q1 <= '0';
         Q2 <= '0';
         Q3 <= '0';
      else
         Q1 <= D_IN;
         Q2 <= Q1;
         Q3 <= Q2;
      end if;
   end if;
end process;

Q_OUT <= Q1 and Q2 and (not Q3);


end Behavioral;