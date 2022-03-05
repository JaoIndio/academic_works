-- Sincronizador de botão

-- Sincroniza 270 clocks

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity ButSinc is
  port ( clk     : in  STD_LOGIC;
         --rst     : in  STD_LOGIC;
         but_in  : in  STD_LOGIC;
         but_out : out STD_LOGIC
       );
end ButSinc;

architecture Behavioral of ButSinc is
  type State is (s0,s1,s2);
  signal currentState, nextState : State;
  signal count : integer range 0 to 525;
begin

-- State Memory
  process(clk)
  begin
        
    --if rst = '1' then
      --currentState <= s0;
        
    if rising_edge(clk) then
      currentState <= nextState;
            
    end if;
  end process;

-- Next State Memory
  process (currentState, but_in, clk)
  begin
    case currentState is
      when s0 =>
        count <= 0;
        if but_in = '1' then
          nextState <= s1;
        else
          nextState <= s0;
        end if;

      when s1 =>
        if rising_edge(clk) then
          
          if count < 270 then
            count <= count + 1;
            nextState <= s1;
          
          else
            if but_in = '1' then
              nextState <= s2;
            else
              nextState <= s0;
            end if;
          end if;

        end if;

      when others =>
        if but_in = '1' then
          nextState <= s2;
        else
          nextState <= s0;
        end if;
    end case;
  end process;

-- Output Logic
  but_out <= '1' when currentState=s1 else
             '0';

end Behavioral;

