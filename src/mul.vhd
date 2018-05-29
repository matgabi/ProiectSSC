library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mul is
  Port ( 
    X 	  : in std_logic_vector(7 downto 0); 
    Y     : in std_logic_vector(7 downto 0);
    P     : out std_logic_vector(15 downto 0)
  );
end mul;

architecture Behavioral of mul is
type PP is array(0 to 7) of std_logic_vector(7 downto 0);
type S is array(0 to 7) of std_logic_vector(8 downto 0);
type Tr is array(0 to 6) of std_logic_vector(8 downto 0);

signal Partp : PP;

signal Sum : S;
signal Trans : Tr;
begin
    genand:for i in 0 to 7 generate
    Partp(i) <= X and (Y(i) & Y(i) & Y(i) & Y(i) & Y(i) & Y(i) & Y(i) & Y(i));
    end generate;
    Sum(0) <= '0' & Partp(0);
    gen: for i in 1 to 7 generate
    Sum(i)(8) <= Trans(i-1)(8);
    Trans(i-1)(0) <= '0';
    gen2: for j in 0 to 7 generate
    m: entity WORK.sume port map(
        X => Partp(i)(j),
        Y => Sum(i-1)(j + 1),
        Tin => Trans(i-1)(j),
        S => Sum(i)(j),
        Tout => Trans(i-1)(j+1)
    );
    end generate;
    end generate;
	prod:for i in 0 to 6 generate
	P(i) <= Sum(i)(0);
	P(7 + i) <= Sum(7)(i);
	end generate; 
	P(14) <= Sum(7)(7);
	P(15) <= Trans(6)(8);

end Behavioral;