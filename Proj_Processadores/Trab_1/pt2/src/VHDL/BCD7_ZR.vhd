library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BCD7_ZR is
    Port ( a : in  STD_LOGIC_VECTOR (3 downto 0);
           b : out  STD_LOGIC_VECTOR (6 downto 0));
end BCD7_ZR;

architecture core of BCD7_ZR is

begin
  b <= "0111111" when a="0000" else  -- bit 1 liga o display. numero 0
       "0000110" when a="0001" else
       "1011011" when a="0010" else
       "1001111" when a="0011" else
       "1100110" when a="0100" else
       "1101101" when a="0101" else
       "1111101" when a="0110" else
       "0000111" when a="0111" else
       "1111111" when a="1000" else
       "1101111" when a="1001" else
       "1110111" when a="1010" else
       "1011110" when a="1011" else
       "0111001" when a="1100" else
       "1111100" when a="1101" else
       "1111001" when a="1110" else
       "1110001";

end core;