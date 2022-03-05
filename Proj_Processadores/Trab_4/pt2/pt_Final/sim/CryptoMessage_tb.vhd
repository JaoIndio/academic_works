library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CryptoMessage_tb is
end CryptoMessage_tb;

architecture structural of CryptoMessage_tb is
  signal clock : std_logic := '1';
  signal ack: std_logic:= 'Z';
  signal fio : std_logic;
  signal reset : std_logic;
  signal interrupt : std_logic;
  signal end_of_message : std_logic;
  signal data_out : std_logic_vector(7 downto 0);
  
  signal bus_system : std_logic_vector(15 downto 0);
  
  signal s_clk_div2, clk_div4 : std_logic;

begin
  
  clock <= not clock after 5 ns;
  reset <= '1', '0' after 12 ns;
  --ack <= not ack after 7 ns;

  ENCRYPTER: entity work.CryptoMessage(behavioral)
    generic map(
      --MSG_INTERVAL => 48000,
		MSG_INTERVAL => 3000,
      FILE_NAME    => "EyesOfAStranger.txt",
      PUBLIC_KEY   => "00000000000000000000000100000001", -- 257
      N            => 65473
    )
    port map(
      clk => s_clk_div2,
      rst => reset,
      ack => ack,
      data_out => data_out,
      data_av => interrupt,
      eom => end_of_message
    );
	
   -- tem q dividir o clock por dois
   CLOCK_MANAGER: entity work.ClockManager(xilinx)
    port map(
      clk_in             => clock,
      -- Clock out ports
      clk_div2           => s_clk_div2,
      clk_div4           => clk_div4
    );
	
   bus_system <= "00000"& end_of_message & 'Z' & interrupt & data_out;
	ack <= bus_system(9);
	
   CPU_MIPS: entity work.MIPS_uC(UNION)
    port map(
      clk => clock,
      rst => reset,

      External_World => bus_system

    );
    
end structural;