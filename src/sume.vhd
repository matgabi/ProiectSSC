library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sume is
    Port ( X : in STD_LOGIC;
           Y : in STD_LOGIC;
           Tin : in STD_LOGIC;
           S : out STD_LOGIC;
           Tout : out STD_LOGIC);
end sume;

architecture Behavioral of sume is

begin
    S <= X xor Y xor Tin;
    Tout <= (X and Y) or ((X or Y) and Tin);

end Behavioral;
