library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MIPS_uC_tb is
end MIPS_uC_tb;

architecture structural of MIPS_uC_tb is
  signal clock : std_logic := '0';
  signal reset : std_logic;

  signal External_World : std_logic_vector(15 downto 0);
  signal LED_out_TEST : std_logic_vector(3 downto 0); 

begin
  
  clock <= not clock after 5 ns;
  reset <= '1', '0' after 1000 ns;

  CPU_Mother_Fucker: entity work.MIPS_uC(UNION)
    port map(
      clk => clock,
      rst => reset,

      External_World => External_World,
      LED_out_TEST  => LED_out_TEST

    );
end structural;