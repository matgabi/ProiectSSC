library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity Normalizare is
	port(
	Clk: in std_logic;
	Rst: in std_logic;
	Load: in std_logic;
	CE: in std_logic;
	Mantisa: in std_logic_vector(25 downto 0);
	Exponent: in std_logic_vector(7 downto 0);
	
	MantisaNormalizata: out std_logic_vector(25 downto 0);
	ExponentNormalizat: out std_logic_vector(7 downto 0);
	
	NormalBit: out std_logic;
	DepasireInferioara : out std_logic
	);
end Normalizare;  

architecture Normalizare of Normalizare is
signal Mtemp : std_logic_vector(25 downto 0) := (others => '0'); 
signal Etemp : std_logic_vector(7 downto 0) := (others => '0');

begin										
	normalizeaza:process(Clk)
	begin
		if rising_edge(Clk) then
			if Rst = '1' then
				Mtemp <= (others => '0');
				Etemp <= (others => '0');
			elsif CE = '1' then
				if load = '1' then
					Mtemp <= Mantisa;
					Etemp <= Exponent;
				else
					Mtemp <= Mtemp(24 downto 0) & '0';
					Etemp <= Etemp - 1;
				end if;
			end if;
		end if;
	end process;  
	
	DepasireInferioara <= '1' when Etemp = x"00" else '0';
	
	MantisaNormalizata <= Mtemp;
	ExponentNormalizat <= Etemp;
	NormalBit <= Mtemp(25);
end Normalizare;