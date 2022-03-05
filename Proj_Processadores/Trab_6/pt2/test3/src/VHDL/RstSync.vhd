-------------------------------------------------------------------------
-- Design unit: ResetSynchonizer
-- Description: Synchronizes the external reset release with clock
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;        

entity RstSync is 
    port(
        clk             : in std_logic;
        rst_in          : in std_logic; 
        rst_out         : out std_logic
    );
end RstSync;

architecture behavioral of RstSync is  
    
    signal ff1_q, ff2_q : std_logic;
    
begin
  
  rst_out <= ff2_q;
  
  process(clk,rst_in)
  begin
    if rst_in = '1' then
      ff1_q <= '1';
      ff2_q <= '1';
    
    elsif rising_edge(clk) then
      ff1_q <= '0';
      ff2_q <= ff1_q;
    end if;
  end process; 
    
end behavioral;