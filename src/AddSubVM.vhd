library ieee;
use ieee.std_logic_1164.all;  
use ieee.std_logic_unsigned.all;

entity AddSubVM is
	port(
	X : in std_logic_vector(31 downto 0);
	Y : in std_logic_vector(31 downto 0);
	Clk : in std_logic;
	Rst : in std_logic;
	Start: in std_logic;
	
	Operation : in std_logic;
	
	Result: out std_logic_vector(31 downto 0);
	
	DepasireSup: out std_logic;
	DepasireInf: out std_logic;
	
	Ready : out std_logic
	);
end AddSubVM;


architecture AddSubVM of AddSubVM is

signal Xreg : std_logic_vector(31 downto 0) := (others => '0'); --incarcare op1
signal Yreg : std_logic_vector(31 downto 0)	:= (others => '0'); --incarcare op2

--control unit iesiri
signal DifExp : std_logic_vector(7 downto 0);
signal FinalExp : std_logic := '0';
signal MantisaAliniata : std_logic_vector(25 downto 0) := (others => '0');
signal DepasireMantisa : std_logic := '0'; 
signal LoadOperanzi : std_logic := '0';
signal MuxExtendMantisa1 : std_logic := '0';
signal MuxExtendMantisa2 : std_logic := '0';
signal CEMantisaAliniata : std_logic := '0';
signal LoadMantisaAliniata : std_logic := '0';
signal CEMantisa2 : std_logic := '0';

--mantise extinse pt garda si rotunjire
signal Mantisa1Ext : std_logic_vector(25 downto 0) := (others => '0'); 
signal Mantisa2Ext : std_logic_vector(25 downto 0)	:= (others => '0');	
signal Mantisa2ExtReg : std_logic_vector(25 downto 0)	:= (others => '0');

signal ExponentFinal : std_logic_vector(7 downto 0) := (others => '0');
signal MantisaFinala : std_logic_vector(25 downto 0) := (others => '0'); 
signal RezultatZero : std_logic;

signal CERealiniere : std_logic := '0';
signal MantisaRealiniata : std_logic_vector(25 downto 0) := (others => '0'); 
signal ExponentRealiniat : std_logic_vector(7 downto 0) := (others => '0');
signal DepasireSuperioara: std_logic;

signal CENormalizare : std_logic := '0';
signal LoadNormalizare : std_logic := '0';
signal NormalBit : std_logic := '0';  
signal DepasireInferioara : std_logic := '0';
signal MantisaNormalizata: std_logic_vector(25 downto 0) := (others => '0');
signal ExponentNormalizat: std_logic_vector(7 downto 0) := (others => '0');

signal CERotunjire: std_logic := '0';
signal MantisaRotunjita : std_logic_vector(22 downto 0) := (others => '0');

signal AluResult : std_logic_vector(31 downto 0);
signal SelectieRezultat : std_logic_vector(2 downto 0);
signal Sign : std_logic := '0';

signal ResultReg : std_logic_vector(31 downto 0) := (others => '0');
signal CERezultat: std_logic := '0';

signal NaNx : std_logic := '0';
signal NaNy : std_logic := '0';
signal NaN  : std_logic := '0';
begin		 
	x_reg:entity WORK.simpleregister 
	generic map(
		n => 32
	)
	port map(
		D => X,
		Clk => Clk,
		Rst => Rst,
		CE => LoadOperanzi,
		Q => Xreg
	);
	y_reg:entity WORK.simpleregister 
	generic map(
		n => 32
	)
	port map(
		D => Y,
		Clk => Clk,
		Rst => Rst,
		CE => LoadOperanzi,
		Q => Yreg
	); 
	
	nanxy:process(Xreg,Yreg) 
	variable x : std_logic := '0';
	variable y : std_logic := '0';
	begin  
		x := '0';
		y := '0';
		for i in 0 to 22 loop
			x := x or Xreg(i);
			y := y or Yreg(i);
		end loop;
		NaNx <= x;
		NaNy <= y;
	end process;
	nanf:process(NaNx,NaNy,Xreg(30 downto 23),Yreg(30 downto 23))
	begin		
		if Xreg(30 downto 23) = x"FF" and NaNx = '1' then
			NaN <= '1';
		elsif Yreg(30 downto 23) = x"FF" and NaNy = '1' then
			NaN <= '1';
		else NaN <= '0';
		end if;
	end process;
	
	comparatorexp : entity WORK.compareexp
	port map(
		Exp1 => Xreg(30 downto 23),
		Exp2 => Yreg(30 downto 23),
		FinalExp => FinalExp
	);
	
	scadereexp : entity WORK.aluexp
	port map(
		Exp1 => Xreg(30 downto 23),
		Exp2 => Yreg(30 downto 23),
		AluOp => FinalExp,
		DifExp => DifExp
	);
	
	selectmantisaalign : entity WORK.mux21extend
	generic map(
		n => 23
	)
	port map(
		I1 => Xreg(22 downto 0),
		I2 => Yreg(22 downto 0),
		Sel => MuxExtendMantisa1,
		O => Mantisa1Ext
	);
	selectmantisa2 : entity WORK.mux21extend
	generic map(
		n => 23
	)
	port map(
		I1 => Xreg(22 downto 0),
		I2 => Yreg(22 downto 0),
		Sel => MuxExtendMantisa2,
		O => Mantisa2Ext
	);
	mantisa2ext_reg:entity WORK.simpleregister 
	generic map(
		n => 26
	)
	port map(
		D => Mantisa2Ext,
		Clk => Clk,
		Rst => Rst,
		CE => CEMantisa2,
		Q => Mantisa2ExtReg
	); 
	
	alignmantise_reg : entity WORK.alignmantise
	generic map(
		n => 26
	)
	port map(
		Clk => Clk,
		Rst => Rst,
		CE => CEMantisaAliniata,
		Load => LoadMantisaAliniata,
		SRI => '0',
		D => Mantisa1Ext,
		Q => MantisaAliniata
	);
	
	alumantise_alu : entity WORK.alumantise
	generic map(
		n => 26
	)
	port map(
		Mantisa1 => MantisaAliniata,
		Mantisa2 => Mantisa2ExtReg,
		AluOp => Operation,
		MantisaFinala => MantisaFinala,
		DepasireMantisa => DepasireMantisa,
		RezultatZero => RezultatZero
	); 
	Sign <= '1' when Xreg(30 downto 23) < Yreg(30 downto 23) else '0';
	
	realign : entity WORK.realinieremantise
	port map(
		Clk => Clk,
		CE => CERealiniere,
		Realiniere => DepasireMantisa,
		Rst => Rst,
		Exponent => ExponentFinal,
		Mantisa => MantisaFinala,
		ExponentRealiniat => ExponentRealiniat,
		MantisaRealiniata => MantisaRealiniata,
		DepasireSuperioara => DepasireSuperioara
	);
	
	
	expfinal : entity WORK.mux21
	generic map(
		n => 8
	)
	port map(
		I1 => Xreg(30 downto 23),
		I2 => Yreg(30 downto 23),
		Sel => FinalExp,
		O => ExponentFinal
	);	
	
	
	normalize : entity WORK.normalizare
	port map(
		Clk => Clk,
		Rst => Rst,
		Load => LoadNormalizare,
		CE => CENormalizare,
		Mantisa => MantisaRealiniata,
		Exponent => ExponentRealiniat,
		MantisaNormalizata => MantisaNormalizata,
		ExponentNormalizat => ExponentNormalizat,
		NormalBit => NormalBit,
		DepasireInferioara => DepasireInferioara
	);	
	
	round : entity WORK.rotunjire
	port map(
		Clk => Clk,
		Rst => Rst,
		CE => CERotunjire,
		MantisaNormalizata => MantisaNormalizata,
		MantisaRotunjita => MantisaRotunjita
	);
	
	AluResult <= (Sign and Operation) & ExponentNormalizat & MantisaRotunjita;
	
	with SelectieRezultat select ResultReg <= x"00000000" when "000",
	x"FF800000" when "001",
	x"7F800000" when "010",
	x"7F810000" when "011",		 
	AluResult when others;
	
	
	finalresult : entity WORK.simpleregister
	generic map(
		n => 32
	)
	port map(
		D => ResultReg,
		Clk => Clk,
		Rst => Rst,
		CE => CERezultat,
		Q => Result
	);
	
	DepasireSup <= DepasireSuperioara;
	DepasireInf <= DepasireInferioara;
	
	control : entity WORK.controlunit
	port map(
		Start => Start,
		Clk => Clk,
		Rst => Rst,
		Operation => Operation,
		DifExp => DifExp,
		FinalExp => FinalExp,
		MantisaAliniata => MantisaAliniata,
		DepasireMantisa => DepasireMantisa,
		NormalBit => NormalBit,
		RezultatZero => RezultatZero,
		DepasireInferioara => DepasireInferioara,
		DepasireSuperioara => DepasireSuperioara,
		NaN => NaN,
		LoadOperanzi => LoadOperanzi,
		MuxExtendMantisa1 => MuxExtendMantisa1,
		MuxExtendMantisa2 => MuxExtendMantisa2,
		CEMantisaAliniata => CEMantisaAliniata,
		LoadMantisaAliniata => LoadMantisaAliniata, 
		CEMantisa2 => CEMantisa2,
		CERealiniere => CERealiniere,
		CENormalizare => CENormalizare,
		LoadNormalizare => LoadNormalizare,	
		CERotunjire => CERotunjire,	
		SelectieRezultat => SelectieRezultat,
		CERezultat => CERezultat,
		Ready => Ready
	);
		
	
end AddSubVM;