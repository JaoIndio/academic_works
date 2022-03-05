library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MIPS_FPGA_TEST_tb2 is
end MIPS_FPGA_TEST_tb2;

architecture structural of MIPS_FPGA_TEST_tb2 is
  signal clock : std_logic := '0';
  signal reset : std_logic;

  signal display_enbl : std_logic_vector(3 downto 0);
  signal display_out  : std_logic_vector(7 downto 0); 

begin
  
  clock <= not clock after 5 ns;
  reset <= '1', '0' after 1000 ns;

  CPU_Mother_Fucker: entity work.MIPS_FPGA_TEST(UNION)
    port map(
      clk => clock,
      rst => reset,

      display_enbl => display_enbl,
      display_out  => display_out

    );
end structural;