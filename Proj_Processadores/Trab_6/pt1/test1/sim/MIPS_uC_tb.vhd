library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MIPS_uC_tb is
end MIPS_uC_tb;

architecture structural of MIPS_uC_tb is

  signal clock : std_logic := '1';
  signal reset, s_rst , rx_av, tx_data_o, rx_data_i : std_logic;
  signal s_clk_div2, clk_div4 : std_logic;

  signal Button      : std_logic;
  signal btnSinc     : std_logic;
  
  signal ConfigModeS : std_logic_vector(1 downto 0);

  signal rx_data_o : std_logic_vector(7 downto 0);

  signal External_World : std_logic_vector(15 downto 0) :="ZZZZZZZZZZZZZZZZ";

begin
  
  clock  <= not clock after 5 ns;
  reset  <= '1', '0' after 12 ns;
  Button <= '0', '1' after 544.3 us, '0' after 544.4 us;
  External_World(1 downto 0) <= ConfigModeS;
  --External_World(15 downto 2) <= "00000000000000";
  s_rst <= reset;

  BUT: entity work.ButSinc(Behavioral)
    port map(
      clk     => clock,
      but_in  => Button,
      but_out => btnSinc
    );

  -- tem q dividir o clock por dois
  CLOCK_MANAGER: entity work.ClockManager(xilinx)
    port map(
      clk_in             => clock,
      -- Clock out ports
      clk_div2           => s_clk_div2,
      clk_div4           => clk_div4
    );

  -- Serial Communications UART_TX ID = 2
  COM_TX: entity work.SIMPLE_TX(behavioral)
    generic map(
      RATE_FREQ_BAUD  => 217 -- 200 MHz / 921600 bps = 217
    )
    port map(
        -- Control Signals
        clk       => s_clk_div2,
        rst       => s_rst,

        -- Serial Output
        tx        => tx_data_o,

        -- Comm signals
        data_in   => rx_data_o,
        data_av   => rx_av
    );

  -- Serial Communications UART_RX ID = 3
  COM_RX: entity work.SIMPLE_RX(behavioral)
    generic map(
      RATE_FREQ_BAUD  => 217 -- 200 MHz / 921600 bps = 217
    )
    port map(
        -- Control Signals
        clk       => s_clk_div2,
        rst       => s_rst,

        -- Serial Intput
        rx        => rx_data_i,

        -- Data outputs
        data_out  => rx_data_o,
        data_av   => rx_av
    
    );

  CPU_MIPS: entity work.MIPS_uC(UNION)
    port map(
      clk => clock,
      rst => reset,

      External_World => External_World,

      tx_data_o => rx_data_i,
      rx_data_i => tx_data_o

    );

  CONFIG_MODE: entity work.ConfigMode_HW(Behavioral)
    port map(
        clk => clock,
        rst => reset,

        btn => btnSinc,

        ConfigMode => ConfigModeS
    );
end structural;
