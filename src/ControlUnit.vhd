library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity ControlUnit is
	port(
	Start: in std_logic;
	Clk: in std_logic;
	Rst: in std_logic;
	Operation: in std_logic;	   --adunare sau scadere
	
	DifExp : in std_logic_vector(7 downto 0); --diferenta exponentilor(ma ajuta la starea in care se aliniaza mantisele)
	FinalExp: in std_logic; --vine de la comparatorul de exponenti si selecteaza exponentul final
	
	MantisaAliniata: in std_logic_vector(25 downto 0); --mantisa finala aliniata ..ca sa o verific sa nu fie 0;
	
	DepasireMantisa: in std_logic; --vine de la alu pt mantise
	
	NormalBit: in std_logic;  
	
	RezultatZero: in std_logic;
	DepasireInferioara: in std_logic;
	DepasireSuperioara: in std_logic; 
	NaN : in std_logic;
	
	LoadOperanzi: out std_logic; --merge la registrii de sus in care se incarca operanzii
	
	
	MuxExtendMantisa1: out std_logic; --selecteaza mantisa care va fi shiftata dreapta
	MuxExtendMantisa2: out std_logic; --selecteaza mantisa 2 care va merege direct la alu
	CEMantisaAliniata: out std_logic; --clk enable pe registrul de shiftare dreapta pt aliniere
	LoadMantisaAliniata: out std_logic; --incarca in registru mantisa de aliniat
	CEMantisa2 : out std_logic; --pentru registrul care va tine mantisa ce nu trebuie aliniata
	
	CERealiniere : out std_logic;
	
	CENormalizare: out std_logic;
	LoadNormalizare: out std_logic;
	
	CERotunjire: out std_logic;	 
	SelectieRezultat : out std_logic_vector(2 downto 0);
	
	CERezultat: out std_logic;
	
	Ready: out std_logic --operatia s-a finalizat
	);
end ControlUnit;								  

architecture ControlUnit of ControlUnit is 
type Stare is (idle,load,setcontoraliniere,aliniere,realiniere,setnormalizare,normalizare,rotunjire,final,rezultat0,depinferioara,depsuperioara,nanstate);
signal St : Stare;
begin			
	control:process(Clk)
	variable ContorAliniere: integer := 0;
	begin
		if rising_edge(Clk) then
			if Rst = '1' then
				St <= idle;
			else
				case St is  
					when idle =>
					if Start = '1' then
						St <= load;
					end if;
					when load =>
					St <= setcontoraliniere;
					when setcontoraliniere =>
					if NaN = '1' then
						St <= nanstate;
					else
						ContorAliniere := to_integer(unsigned(DifExp));
						if ContorAliniere = 0 then
							St <= realiniere;
						else St <= aliniere; 
						end if;	
					end if;
					when aliniere =>
					if ContorAliniere = 1 then
						St <= realiniere;
					else
						ContorAliniere := ContorAliniere - 1;
						St <= aliniere;
					end if;	
					when realiniere =>
					if RezultatZero = '1' then
						St <= rezultat0;
					else St <= setnormalizare;
					end if;
					when setnormalizare =>
					if DepasireSuperioara = '1' then
						St <= depsuperioara;
					else St <= normalizare;
					end if;
					when normalizare =>
					if NormalBit = '1' then
						St <= rotunjire;
					else St <= normalizare;
					end if;	 
					when rotunjire =>
					if DepasireInferioara ='1' then
						St <= depinferioara;
					else St <= final;
					end if;
					when final => St <= idle;
					when rezultat0 => St <= idle;
					when depinferioara => St <= idle;
					when depsuperioara => St <= idle; 
					when others => St <= idle; --others aka nanstate
		 		end case;
			end if;
		end if;
	end process;
	
	iesiri:process(St,FinalExp,NormalBit)
	begin	
	LoadOperanzi <= '0';
		
	MuxExtendMantisa1 <= '0';
	MuxExtendMantisa2 <= '0';
	CEMantisaAliniata <= '0';
	LoadMantisaAliniata <= '0';
	CEMantisa2 <= '0';
	
	CERealiniere <= '0';
	
	CENormalizare <= '0';
	LoadNormalizare <= '0';
	
	CERotunjire <= '0';
	SelectieRezultat <= "111";
	
	CERezultat <= '0';
	
	Ready <= '0'; 
	case St is
		when idle => Ready <= '1';
		when load => LoadOperanzi <= '1';
	    when setcontoraliniere	=>
		MuxExtendMantisa1 <= not(FinalExp);
		MuxExtendMantisa2 <= FinalExp;
		CEMantisaAliniata <= '1';
		LoadMantisaAliniata <= '1';
		CEMantisa2 <= '1';
		when aliniere =>
		CEMantisaAliniata <= '1';
		when realiniere =>
		CERealiniere <= '1';
		when setnormalizare =>
		CENormalizare <= '1';
		LoadNormalizare <= '1';
		when normalizare =>
		CENormalizare <= not(NormalBit); 
		when rotunjire =>
		CERotunjire <= '1';
		when final => 
		Ready <= '1';
		SelectieRezultat <= "111"; 
		CERezultat <= '1';
		when rezultat0 =>
		Ready <= '1';
		SelectieRezultat <= "000"; 
		CERezultat <= '1';
		when depsuperioara =>
		Ready <= '1';
		SelectieRezultat <= "010";
		CERezultat <= '1';
		when depinferioara =>
		Ready <= '1';
		SelectieRezultat <= "001";
		CERezultat <= '1';
		when others => 
		Ready <= '1'; --nan	
		SelectieRezultat <= "011";
		CERezultat <= '1';
	end case;
end process;
	
end ControlUnit;