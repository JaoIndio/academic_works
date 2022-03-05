library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Test2_tb is
end Test2_tb;

architecture structural of Test2_tb is
  signal clock                : std_logic := '1';
  signal reset                : std_logic;

  signal bus_system           : std_logic_vector(15 downto 0);
  
  signal rx_data_o            : std_logic_vector(7 downto 0);
  signal rx_data_i, rx_av     : std_logic;

  signal s_clk_div2, clk_div4 : std_logic;

begin
  
  clock <= not clock after 5 ns;
  reset <= '1', '0' after 12 ns; 
  

   -- tem q dividir o clock por dois
   CLOCK_MANAGER: entity work.ClockManager(xilinx)
    port map(
      clk_in             => clock,
      -- Clock out ports
      clk_div2           => s_clk_div2,
      clk_div4           => clk_div4
    );
  
  bus_system <= 'Z' & "ZZ" & 'Z' & "ZZZZ" &  "ZZZZZZZZ";

  SERIAL_COMM: entity work.UART_RX(behavioral)
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

  
   CPU_MIPS: entity work.MIPS_uC(UNION)
    port map(
      clk => clock,
      rst => reset,

      External_World => bus_system,

      tx_data_o => rx_data_i

    );
    
end structural;