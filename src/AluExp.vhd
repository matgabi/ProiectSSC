library ieee;
use ieee.std_logic_1164.all;   
use ieee.std_logic_unsigned.all;

entity AluExp is
	port(
	Exp1 : in std_logic_vector(7 downto 0);
	Exp2 : in std_logic_vector(7 downto 0);
	AluOp: in std_logic;
	DifExp: out std_logic_vector(7 downto 0)
	);
end AluExp;									

architecture AluExp of AluExp is
begin	   
	op:process(Exp1,Exp2,AluOp)   
	begin		
		case AluOp is
			when '0' => DifExp <= Exp1 - Exp2;
			when others => DifExp <= Exp2 - Exp1;  
		end case;
	end process;
end AluExp;