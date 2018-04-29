library ieee;
use ieee.std_logic_1164.all;

entity mux21 is
	generic( n : integer);
	port (
	I1 : in std_logic_vector(n-1 downto 0);
	I2 : in std_logic_vector(n-1 downto 0);
	Sel: in std_logic;
	O  : out std_logic_vector(n-1 downto 0)
	);
end mux21;

architecture mux21 of mux21 is
begin	  
	O <= I1 when Sel = '0' else I2;
end mux21;