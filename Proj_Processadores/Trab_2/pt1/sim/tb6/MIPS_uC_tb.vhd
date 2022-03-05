library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MIPS_uC_tb is
end MIPS_uC_tb;

architecture structural of MIPS_uC_tb is
  signal clock : std_logic := '0';
  signal reset : std_logic;

  signal bcd : std_logic_vector(6 downto 0);-- := "ZZZZZZZ";
  signal disp_enable: std_logic_vector(3 downto 0);-- := "ZZZZ";

  signal btn_up, btn_down : std_logic := '1'; 

  --signal External_World : std_logic_vector(15 downto 0) :="1111000011110000";
  signal External_World : std_logic_vector(15 downto 0) :="ZZZZZZZZZZZZZZZZ";

begin
  
  clock    <= not clock after 5 ns;
  reset    <= '1', '0' after 12 ns, '1' after 90 us, '0' after 1.2 ms, '1' after 1.3 ms;
  btn_up   <= not btn_up after 10 us;
  btn_down <= not btn_down after 40 us;

  --External_World <= (others => 'Z') after 1800ns;
  External_World(0) <= btn_up;
  External_World(1) <= btn_down;
  disp_enable       <= External_World(5 downto 2);
  bcd               <= External_World(12 downto 6);

  CPU_MIPS: entity work.MIPS_uC(UNION)
    port map(
      clk => clock,
      rst => reset,

      External_World => External_World

    );
end structural;
