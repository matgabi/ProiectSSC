library ieee;
use ieee.std_logic_1164.all;   
use ieee.std_logic_unsigned.all;

entity AluMantise is
	generic ( n : integer);
	port(
	Mantisa1 : in std_logic_vector(n-1 downto 0);
	Mantisa2 : in std_logic_vector(n-1 downto 0);
	AluOp	 : in std_logic;
	MantisaFinala : out std_logic_vector(n-1 downto 0);
	DepasireMantisa: out std_logic;
	RezultatZero : out std_logic
	);
end AluMantise;					   

architecture AluMantise of AluMantise is
signal TempMantisa : std_logic_vector(n downto 0) := (others => '0');

begin
TempMantisa <= ('0' & Mantisa1) + ('0' & Mantisa2) when AluOp = '0' else ('0' & Mantisa2) - ('0' & Mantisa1);
MantisaFinala <= TempMantisa(n-1 downto 0);
DepasireMantisa <= TempMantisa(n);

RezultatZero <= AluOp when (Mantisa1 = Mantisa2) else '0';

end AluMantise;
