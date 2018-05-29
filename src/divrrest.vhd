library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divrrest is
generic ( n: integer := 4);
port(
Clk: in std_logic;
Rst: in std_logic;
Start: in std_logic;
X : in std_logic_vector(2*n - 1 downto 0);
Y : in std_logic_vector(n-1 downto 0);
A: out std_logic_vector( n downto 0);
Q: out std_logic_vector(n-1 downto 0);
Term : out std_logic;
ZeroDiv: out std_logic
);

end divrrest;

architecture divrrest of divrrest is

signal Tout : std_logic;
signal OVF : std_logic;
signal Q0 : std_logic;
signal CEQ0 : std_logic;
signal CEB : std_logic;
signal SubB : std_logic;
signal LoadA : std_logic;
signal LoadQ : std_logic;
signal CEA : std_logic;
signal CEQ : std_logic;
signal RstA : std_logic;
signal Qfdn : std_logic_vector(n-1 downto 0);	
signal SelectInitValue: std_logic; 
signal Q0input: std_logic;


signal XorSubB : std_logic_vector(n-1 downto 0);
signal XorResult: std_logic_vector(n-1 downto 0);
signal Aqout: std_logic_vector(n downto 0);
signal Qqout: std_logic_vector(n-2 downto 0);
signal S: std_logic_vector(n-1 downto 0);
signal AcumIn : std_logic_vector(n downto 0);
begin
    control: entity WORK.divcontrolunit generic map(n => n)
    port map(
        Start => Start,
        Rst => Rst,
        Clk => Clk,
      	An => Aqout(n),
		Y => Y,
        Term =>Term,
        CEB => CEB,
        SubB => SubB,
        LoadA => LoadA,	
		CEA => CEA,	 
		RstA => RstA,
        LoadQ => LoadQ,
        CEQ => CEQ,
        CEQ0 => CEQ0,
		ZeroDiv => ZeroDiv,
		SelectInitValue => SelectInitValue
    );
    b: entity WORK.fdn generic map( n => n)
          port map(
           D => Y,
           Clk =>Clk,
           Rst => Rst,
           CE => CEB,
           Q => Qfdn
          );
    XorSubB <= (others => SubB);
    XorResult <= Qfdn xor XorSubB;
	
	AcumIn <= (Tout & S) when SelectInitValue ='0' else ('0' & X(2*n-1 downto n)) ;
    ac: entity WORK.divsrrn generic map(n => n + 1)
    port map(
    Clk => Clk,
    Rst => RstA,
    CE => CEA,
    Load => LoadA,
    SRI => Qqout(n-2),
    D => AcumIn,
    Q => Aqout
    );
   
	
    qsrn:entity WORK.divsrrn generic map(n => n - 1)
        port map(
        Clk => Clk,
        Rst => Rst,
        CE => CEQ,
        Load => LoadQ,
        SRI => Q0,
        D => X(n-1 downto 1),
        Q => Qqout
        ); 
	Q0input <= not(Aqout(n)) when SelectInitValue='0' else X(0);
    qfd: entity WORK.fd port map(
    Clk => Clk,
    D => Q0input,
    Rst => Rst,
    CE => CEQ0,
    Q => Q0
    );
    sum: entity WORK.sumbooth generic map(n => n)
    port map(
    X => Aqout(n-1 downto 0),
    Y=> XorResult,
    Tin => SubB,
    S => S,
    Tout => Tout,
    OVF =>OVF
    );
    A <= Aqout;
    Q <= Qqout & Q0;
    
end divrrest;