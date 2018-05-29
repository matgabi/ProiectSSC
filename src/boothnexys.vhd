library ieee;
use ieee.std_logic_1164.all;

entity boothnexys is 
	generic( n : integer := 4);
	port(
	X 	: in std_logic_vector(n-1 downto 0);  --s15-8
	Y 	: in std_logic_vector(n-1 downto 0);	--s7-0
	Clk : in std_logic;
	Start: in std_logic; --btnu
	Rst : in std_logic;	 --btnd
	Term: out std_logic; --dioda
	An  : out std_logic_vector (n-1 downto 0);
	Seg : out std_logic_vector (n-1 downto 0));
end boothnexys;

architecture boothnexys of boothnexys is

signal A : std_logic_vector(n-1 downto 0); 
signal Q : std_logic_vector(n-1 downto 0);
signal Data : std_logic_vector(31 downto 0);
begin
	sum: entity WORK.mulbooth generic map(n => n)
		port map(
		Clk => Clk,
		Rst => Rst,
		Start => Start,
		X => X,
		Y => Y,
		A => A,
		Q => Q,
		Term => Term
		); 
	Data <= (X & Y & A & Q);
	display: entity WORK.displ7seg port map(
		Clk => Clk,
		Rst => Rst,
		Data => Data,
		An => An,
		Seg => Seg);
end boothnexys;