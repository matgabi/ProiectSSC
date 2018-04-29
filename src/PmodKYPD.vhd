----------------------------------------------------------------------------------
-- Company: Digilent Inc 2011
-- Engineer: Michelle Yu  
-- Create Date:    17:05:39 08/23/2011 
--
-- Module Name:    PmodKYPD - Behavioral 
-- Project Name:  PmodKYPD
-- Target Devices: Nexys3
-- Tool versions: Xilinx ISE 13.2 
-- Description: 
--	This file defines a project that outputs the key pressed on the PmodKYPD to the seven segment display
--
-- Revision: 
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PmodKYPD is
    Port ( 
	Clk : in  STD_LOGIC;
	Rst : in std_logic;
	Start: in std_logic; --start operatie
	LoadX: in std_logic;
	LoadY: in std_logic;
	Operation: in std_logic;
	
	JA : inout  STD_LOGIC_VECTOR (7 downto 0); -- PmodKYPD is designed to be connected to JA
 	An : out  STD_LOGIC_VECTOR (7 downto 0);   -- Controls which position of the seven segment display to display
    Seg : out  STD_LOGIC_VECTOR (7 downto 0); -- digit to display on the seven segment display 
	
	DepasireSup: out std_logic;
	DepasireInf: out std_logic;
	
	Ready : out std_logic);
end PmodKYPD;

architecture Behavioral of PmodKYPD is

signal Decode: STD_LOGIC_VECTOR (3 downto 0) := "0000"; 
signal DigitRead : std_logic := '0'; 
signal DigitReadDebounced : std_logic := '0';

signal TmpOperand : std_logic_vector(31 downto 0) := (others => '0');
signal DigitSelect : std_logic_vector(2 downto 0) := (others => '0');

signal X : std_logic_vector(31 downto 0) := (others => '0');
signal Y : std_logic_vector(31 downto 0) := (others => '0');

signal Result : std_logic_vector(31 downto 0) := (others => '0');
begin
	dec : entity WORK.decoder
	port map(
		Clk => Clk,
		Row => JA(7 downto 4),
		Col => JA(3 downto 0),
		DecodeOut => Decode,
		DigitRead => DigitRead
	);
	onedigit :entity WORK.debounce
	port map(
		Clk => Clk,
		Rst => Rst,
		D_IN => DigitRead,
		Q_OUT => DigitReadDebounced
	);
	loadtmp:process(Clk)
	begin
		if rising_edge(Clk) then
			if Rst = '1' then
				TmpOperand <= (others => '0');
			elsif DigitReadDebounced = '1' then
				if DigitSelect = "000" then
					TmpOperand(31 downto 28) <= Decode;
				elsif DigitSelect = "001" then
					TmpOperand(27 downto 24) <= Decode;	
				elsif DigitSelect = "010" then
					TmpOperand(23 downto 20) <= Decode;
				elsif DigitSelect = "011" then
					TmpOperand(19 downto 16) <= Decode;
				elsif DigitSelect = "100" then
					TmpOperand(15 downto 12) <= Decode;
				elsif DigitSelect = "101" then
					TmpOperand(11 downto 8) <= Decode;
				elsif DigitSelect = "110" then
					TmpOperand(7 downto 4) <= Decode;
				else 
					TmpOperand(3 downto 0) <= Decode;
				end if;
				DigitSelect <= DigitSelect + 1;
			end if;
		end if;
	end process;
	
	loadreg:process(Clk)
	begin
		if rising_edge(Clk) then
			if Rst = '1' then
				X <= (others => '0');
				Y <= (others => '0');
			elsif LoadX = '1' then
				X <= TmpOperand;
			elsif LoadY = '1' then
				Y <= TmpOperand;
			end if;
		end if;
	end process;
	
	add : entity WORK.addsubvm
	port map(
		X => X,
		Y => Y,
		Clk => Clk,
		Rst => Rst,
		Start => Start,
		Operation => Operation,
		Result => Result,
		DepasireSup => DepasireSup,
		DepasireInf => DepasireInf,
		Ready => Ready
	);
	
	dsp : entity WORK.displ7seg
	port map(
		Clk => Clk,
		Rst => Rst,
		Data => Result,
		An => An,
		Seg => Seg
	);
	

end Behavioral;

