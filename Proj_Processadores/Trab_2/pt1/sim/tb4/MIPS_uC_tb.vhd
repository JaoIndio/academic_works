library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MIPS_uC_tb is
end MIPS_uC_tb;

	architecture structural of MIPS_uC_tb is
  signal clock : std_logic := '0';
  signal reset : std_logic;

  signal External_World : std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZ11";
  signal Display_test : std_logic_vector(6 downto 0);
begin
  
  clock <= not clock after 5 ns;
  reset <= '0', '1' after 0.15 us, '0' after 0.16 us, '1' after 0.19 us;

  External_World(0) <= not External_World(0) after 500ns;
  External_World(1) <= not External_World(1) after 5700ns;
  --External_World(0) <= '0','1' after 5 us, '0' after 5.31 us, '1' after 5.33 us, '0' after 6.12 us, '1' after 6.13 us;
  --External_World(1) <= '0','1' after 5 ns;

  CPU_Mother_Fucker: entity work.MIPS_uC(UNION)
    port map(
      clk => clock,
      rst => reset,

      External_World => External_World,
	  Display_test => Display_test

    );
end structural;