library ieee;
use ieee.std_logic_1164.all;  
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



entity controlunit is
	generic ( n: integer := 4);
	port(
	Start: in std_logic;
	Rst: in std_logic;
	Clk: in std_logic;
	Q0: in std_logic;
	Qm1: in std_logic; 
	Term: out std_logic; 
	CEB: out std_logic;
	SubB: out std_logic;
	LoadA: out std_logic;
	LoadQ: out std_logic;
	CEA: out std_logic;
	CEQ: out std_logic;
	RstQm1: out std_logic;
	RstA: out std_logic
	);
end controlunit; 

architecture controlunit of controlunit is
type TIP_STARE is(idle,init,sum,depl,finish);
signal Stare: TIP_STARE;
signal Counterf : std_logic_vector(7 downto 0);
begin									  
	
	nextstate: process(Clk)	   
	variable Counter : integer := n;
	begin
	if rising_edge(Clk) then
		if Rst = '1' then
			Stare <= idle;
		else
			case Stare is
				when idle =>
				if Start = '1' then 
					Stare <= init;
				else Stare <= idle;
				end if;
				when init =>
				Stare <= sum;
				when sum =>
				Counter := Counter - 1;
				Stare <= depl;
				when depl =>
				if Counter = 0 then	
					Counter := n;
					Stare <= finish;
				else Stare <= sum;
				end if;
				when finish =>
				Stare <= idle;
				when others => Stare <= idle;
				end case;
				Counterf <= conv_std_logic_vector(Counter,8);
			end if;
		end if;
		end process;
	iesiri:process(Stare,Q0,Qm1)
	begin
	Term <= '0';
	CEB<= '0';
	SubB<= '0';
	LoadA<= '0';
	LoadQ <= '0';
	CEA<= '0';
	CEQ<= '0';
	RstQm1<= '0';
	RstA<= '0';
	case Stare is
	when init =>
	CEB <= '1';
	CEQ <= '1';
	LoadQ <= '1';
	RstA <= '1';
	RstQm1 <='1';
	when sum  =>
	if (Q0 = '1' and Qm1='0') then --scadere
	SubB <= '1';
	CEA <= '1';
	LoadA <= '1';
	elsif(Q0 = '0' and Qm1='1') then
	CEA <= '1';
	LoadA <= '1';
	else
	CEA <= '0';
	end if;
	when depl =>
	CEA <= '1';
	CEQ <= '1';	
	when finish =>
	Term <= '1';
	when others => Term <= '0';
	end case;
	end process;
	
			
	
end controlunit;