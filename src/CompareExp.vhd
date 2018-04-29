library ieee;
use ieee.std_logic_1164.all;

entity CompareExp is  
	port(
	Exp1: in std_logic_vector(7 downto 0);
	Exp2: in std_logic_vector(7 downto 0);
	FinalExp: out std_logic
	);
end CompareExp;					 

architecture CompareExp of CompareExp is
begin		   
FinalExp <= '1' when Exp2 > Exp1 else'0';
end CompareExp;