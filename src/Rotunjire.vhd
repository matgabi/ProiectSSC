library ieee;
use ieee.std_logic_1164.all;

entity Rotunjire is
	port(
	Clk: in std_logic;
	Rst: in std_logic;
	CE: in std_logic;
	MantisaNormalizata: in std_logic_vector(25 downto 0);
	MantisaRotunjita: out std_logic_vector(22 downto 0)
	);
end Rotunjire; 

architecture Rotunjire of Rotunjire is
begin		  
	rotunjire: process(Clk)
	begin		
		if rising_edge(Clk) then
			if Rst = '1' then 
				MantisaRotunjita <= (others => '0');
			elsif CE = '1' then
				MantisaRotunjita <= MantisaNormalizata(24 downto 2);
			end if;
		end if;
	end process;
end Rotunjire;