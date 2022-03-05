library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BCD7 is
    Port ( a : in  STD_LOGIC_VECTOR (3 downto 0);
           b : out  STD_LOGIC_VECTOR (7 downto 0));
end BCD7;

architecture core of BCD7 is

begin
  b <= "11000000" when a="0000" else  -- nao sei se o ponto ta no inicio ou fim do vetor
       "11111001" when a="0001" else
       "10100100" when a="0010" else
       "10110000" when a="0011" else
       "10011001" when a="0100" else
       "10010010" when a="0101" else
       "10000010" when a="0110" else
       "11111000" when a="0111" else
       "10000000" when a="1000" else
       "10010000" when a="1001" else
       "10001000" when a="1010" else
       "10100001" when a="1011" else
       "11000110" when a="1100" else
       "10000011" when a="1101" else
       "10000110" when a="1110" else
       "10001110";

end core;