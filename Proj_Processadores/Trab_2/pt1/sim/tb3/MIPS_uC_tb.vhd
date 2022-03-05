library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MIPS_uC_tb is
end MIPS_uC_tb;

	architecture structural of MIPS_uC_tb is
  signal clock : std_logic := '0';
  signal reset : std_logic;

  signal External_World : std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZZ1";

begin
  
  clock <= not clock after 5 ns;
  reset <= '1', '0' after 12 ns;

  External_World(0) <= not External_World(0) after 700ns;

  CPU_Mother_Fucker: entity work.MIPS_uC(UNION)
    port map(
      clk => clock,
      rst => reset,

      External_World => External_World

    );
end structural;