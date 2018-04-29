library ieee;
use ieee.std_logic_1164.all;

entity mux21extend is
	generic( n : integer);
	port (
	I1 : in std_logic_vector(n-1 downto 0);
	I2 : in std_logic_vector(n-1 downto 0);
	Sel: in std_logic;
	O  : out std_logic_vector(n+2 downto 0)
	);
end mux21extend;

architecture mux21extend of mux21extend is
begin	  
	O <= '1' & I1 & "00" when Sel = '0' else '1' & I2 & "00";
end mux21extend;