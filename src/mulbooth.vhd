library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mulbooth is
generic ( n: integer := 4);
port(
Clk: in std_logic;
Rst: in std_logic;
Start: in std_logic;
X : in std_logic_vector(n-1 downto 0);
Y : in std_logic_vector(n-1 downto 0);
A: out std_logic_vector( n - 1 downto 0);
Q: out std_logic_vector(n-1 downto 0);
Term : out std_logic
);

end mulbooth;

architecture Behavioral of mulbooth is

signal Tout : std_logic;
signal OVF : std_logic;
signal Q0 : std_logic;
signal Qm1 : std_logic;
signal CEB : std_logic;
signal SubB : std_logic;
signal LoadA : std_logic;
signal LoadQ : std_logic;
signal CEA : std_logic;
signal CEQ : std_logic;
signal RstQm1 : std_logic;
signal RstA : std_logic;
signal Qfdn : std_logic_vector(n-1 downto 0);

signal XorSubB : std_logic_vector(n-1 downto 0);
signal XorResult: std_logic_vector(n-1 downto 0);
signal Aqout: std_logic_vector(n-1 downto 0);
signal Qqout: std_logic_vector(n-1 downto 0);
signal S: std_logic_vector(n-1 downto 0);
begin
	Q0 <= Qqout(0);
    control: entity WORK.controlunit generic map(n => n)
    port map(
        Start => Start,
        Rst => Rst,
        Clk => Clk,
        Q0 => Qqout(0),
        Qm1 => Qm1,
        Term =>Term,
        CEB => CEB,
        SubB => SubB,
        LoadA => LoadA,
        LoadQ => LoadQ,
        CEA => CEA,
        CEQ => CEQ,
        RstQm1 => RstQm1,
        RstA => RstA
    );
    b: entity WORK.fdn generic map( n => n)
          port map(
           D => X,
           Clk =>Clk,
           Rst => Rst,
           CE => CEB,
           Q => Qfdn
          );
    XorSubB <= (others => SubB);
    XorResult <= Qfdn xor XorSubB;
    
    ac: entity WORK.srrn generic map(n => n)
    port map(
    Clk => Clk,
    Rst => RstA,
    CE => CEA,
    Load => LoadA,
    SRI => Aqout(n-1),
    D => S,
    Q => Aqout
    );
   
	
    qsrn:entity WORK.srrn generic map(n => n)
        port map(
        Clk => Clk,
        Rst => Rst,
        CE => CEQ,
        Load => LoadQ,
        SRI => Aqout(0),
        D => Y,
        Q => Qqout
        );
    qfd: entity WORK.fd port map(
    Clk => Clk,
    D => Qqout(0),
    Rst => RstQm1,
    CE => CEQ,
    Q => Qm1
    );
    sum: entity WORK.sumbooth generic map(n => n)
    port map(
    X => Aqout,
    Y=> XorResult,
    Tin => SubB,
    S => S,
    Tout => Tout,
    OVF =>OVF
    );
    A <= Aqout;
    Q <= Qqout;
    
end Behavioral;