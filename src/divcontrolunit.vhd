					   library ieee;
use ieee.std_logic_1164.all;  
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



entity divcontrolunit is
	generic ( n: integer := 8);
	port(
	Start: in std_logic;
	Rst: in std_logic;
	Clk: in std_logic;
	An: in std_logic; 
	Y: in std_logic_vector(n-1 downto 0);
	Term: out std_logic; 
	CEB: out std_logic;
	SubB: out std_logic;
	LoadA: out std_logic;
	CEA: out std_logic;
	RstA: out std_logic;
	LoadQ: out std_logic;	
	CEQ: out std_logic;
	CEQ0: out std_logic;
	ZeroDiv: out std_logic;
	SelectInitValue: out std_logic
	);
end divcontrolunit; 

architecture divcontrolunit of divcontrolunit is
type TIP_STARE is(idle,init,depl,sub,add,finish);
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
				if Y="00000000" then
					Stare <= finish;
				else
					Stare <= depl;
				end if;
				when depl =>
				Counter := Counter - 1;
				Stare <= sub;
				when sub=>
				Stare <= add;
				when add =>
				if Counter = 0 then 
					Stare <= finish;
				else Stare <= depl;	
				end if;
				when finish =>	
				Counter := n;
				Stare <= idle;
				when others => Stare <= idle;
				end case;
				Counterf <= conv_std_logic_vector(Counter,8);
			end if;
		end if;
		end process;
	iesiri:process(Stare,An,Y)
	begin
	Term <= '0';
	CEB<= '0';
	SubB<= '0';
	LoadA<= '0';
	CEA<= '0';
	RstA<= '0';
	LoadQ <= '0';
	CEQ<= '0'; 
	CEQ0 <= '0';
	ZeroDiv <= '0';	
	SelectInitValue <= '0';
	case Stare is
	when init => 
	if Y="00000000" then
		ZeroDiv <= '1';
	else		
		CEB <= '1';
		CEQ <= '1';
		LoadQ <= '1';
		CEQ0 <= '1';
		CEA <= '1';
		LoadA <= '1';
		SelectInitValue <= '1';
	end if;
	when depl =>
	CEA <= '1';
	CEQ <= '1';
	when sub =>
	SubB <= '1';
	CEA <= '1';
	LoadA <= '1';
	when add =>
	CEQ0 <= '1';
	if An = '1' then
		CEA <= '1';
	else CEA <= '0';  
		end if;
	when finish =>
	Term <= '1';
	when others => Term <= '0';
	end case;
	end process;		
	
end divcontrolunit;