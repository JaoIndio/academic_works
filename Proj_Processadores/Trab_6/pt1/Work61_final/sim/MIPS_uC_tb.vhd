library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MIPS_uC_tb is
end MIPS_uC_tb;

architecture structural of MIPS_uC_tb is

  signal clock                                               : std_logic := '1';
  signal s_clk_div2, clk_div4                                : std_logic;
  signal reset, s_rst                                        : std_logic;
  
  signal ack, messager_ack_0, messager_ack_1, messager_ack_2 : std_logic;
  signal eom, messager_eom_0, messager_eom_1, messager_eom_2 : std_logic;

  signal data_av, messager_data_av_0, messager_data_av_1, messager_data_av_2   : std_logic;
  signal data_out, messager_data_o_0, messager_data_o_1, messager_data_o_2     : std_logic_vector(7 downto 0);

  signal bus_system  : std_logic_vector(15 downto 0);

  signal rx_data_i, rx_av, tx_data_o : std_logic;
  signal rx_data_o : std_logic_vector(7 downto 0);

  signal Button      : std_logic;
  signal btnSinc     : std_logic;
  
  signal ConfigModeS : std_logic_vector(1 downto 0);

begin
  
  clock <= not clock after 5 ns;
  reset <= '1', '0' after 12 ns;
  s_rst <= not reset;

  messager_ack_0 <= ack when messager_eom_0 = '0' else '0';
  messager_ack_1 <= ack when messager_eom_0 = '1' else '0';
  messager_ack_2 <= ack when messager_eom_1 = '1' else '0';

  data_av  <=  messager_data_av_0 when messager_eom_0 = '0' else 
               messager_data_av_1 when messager_eom_1 = '0' else
               messager_data_av_2;

  data_out <=  messager_data_o_0  when messager_eom_0 = '0' else 
               messager_data_o_1  when messager_eom_1 = '0' else
               messager_data_o_2;

  -- bus system configuration.
  ack <= bus_system(15);
  bus_system <= "ZZZZZZZZZZZZZZ" & configModeS;

  --                                 TEM Q AJUSTAR ESSES TEMPOS
  --        | INST |         DATA                         |    EXEC
  Button <= '0', '1' after 3034.42 us, '0' after 3034.52 us, '1' after 3426.36 us, '0' after 3426.37 us;

  BUT: entity work.ButSinc(Behavioral)
  port map(
    clk     => clock,
    but_in  => Button,
    but_out => btnSinc
  );

  CONFIG_MODE: entity work.ConfigMode_HW(Behavioral)
  port map(
      clk => clock,
      rst => reset,

      btn => btnSinc,

      ConfigMode => ConfigModeS
  );

  INST_MESSAGER: entity work.AppMessage(behavioral)
  generic map(
    FILE_NAME    => "contador_text.txt"
  )
  port map(
    clk => clk_div4,
    rst => reset,
    start_signal => s_rst,
    data_out => messager_data_o_0,
    data_av  => messager_data_av_0,
    ack      => messager_ack_0,
    eom      => messager_eom_0
  );

  DATA_MESSAGER: entity work.AppMessage(behavioral)
  generic map(
    FILE_NAME    => "contador_data.txt"
  )
  port map(
    clk => clk_div4,
    rst => reset,
    start_signal => messager_eom_0,
    data_out => messager_data_o_1,
    data_av  => messager_data_av_1,
    ack      => messager_ack_1,
    eom      => messager_eom_1
  );

  EXEC_MESSAGER: entity work.AppMessage(behavioral)
  generic map(
    FILE_NAME    => "EXEC.txt"
  )
  port map(
    clk => clk_div4,
    rst => reset,
    start_signal => messager_eom_1,
    data_out => messager_data_o_2,
    data_av  => messager_data_av_2,
    ack      => messager_ack_2,
    eom      => messager_eom_2
  );
  
  -- tem q dividir o clock por dois
  CLOCK_MANAGER: entity work.ClockManager(xilinx)
    port map(
      clk_in             => clock,
      -- Clock out ports
      clk_div2           => s_clk_div2,
      clk_div4           => clk_div4
  );

  COM_RX: entity work.SIMPLE_RX(behavioral)
    generic map(
      RATE_FREQ_BAUD  => 217 -- 200 MHz / 921600 bps = 217
    )
    port map(
        -- Control Signals
        clk       => s_clk_div2,
        rst       => reset,

        -- Serial Input
        rx        => rx_data_i,

        -- Comm control signals
        data_out  => rx_data_o(7 downto 0),
        data_av   => rx_av  
    );

    -- Serial Communications UART_TX ID = 2
  COM_TX: entity work.SIMPLE_TX(behavioral)
    generic map(
      RATE_FREQ_BAUD  => 217 -- 200 MHz / 921600 bps = 217
    )
    port map(
        -- Control Signals
        clk       => s_clk_div2,
        rst       => reset,

        -- Serial Output
        tx        => tx_data_o,

        -- Comm signals
        data_in   => data_out,
        data_av   => data_av
    );

  
   CPU_MIPS: entity work.MIPS_uC(UNION)
    port map(
      clk => clock,
      rst => reset,

      External_World => bus_system,

      tx_data_o => rx_data_i,
      rx_data_i => tx_data_o

    );
    
end structural;