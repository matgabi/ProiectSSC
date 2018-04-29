library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity RealiniereMantise is
	port(
	Clk : in std_logic;
	CE  : in std_logic;
	Realiniere: in std_logic;
	Rst : in std_logic;
	Exponent: in std_logic_vector(7 downto 0);
	Mantisa: in std_logic_vector(25 downto 0);
	ExponentRealiniat: out std_logic_vector(7 downto 0);
	MantisaRealiniata: out std_logic_vector(25 downto 0);
	DepasireSuperioara: out std_logic
	);
end RealiniereMantise;

architecture RealiniereMantise of RealiniereMantise is 
signal Mtemp : std_logic_vector(25 downto 0);
signal Etemp : std_logic_vector(7 downto 0);

begin				  
	realing: process(Clk)
	begin
		if rising_edge(Clk) then
			if Rst = '1' then
				Mtemp <= (others => '0');
				Etemp <= (others => '0');
			elsif CE = '1' then
				if Realiniere = '1' then
					Mtemp <= '1' & Mantisa(25 downto 1);
					Etemp <= Exponent + 1;
				else
					Mtemp <= Mantisa;
					Etemp <= Exponent; 
				end if;
			end if;
		end if;
	end process;  
	MantisaRealiniata <= Mtemp;
	ExponentRealiniat <= Etemp;
	
	DepasireSuperioara <= '1' when Etemp = x"FF" else '0';
end RealiniereMantise;