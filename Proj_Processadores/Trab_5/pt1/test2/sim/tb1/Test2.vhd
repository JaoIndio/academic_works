library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CryptoMessage_tb is
end CryptoMessage_tb;

architecture structural of CryptoMessage_tb is
  signal clock                                      : std_logic := '1';
  signal reset                                      : std_logic;
  
  signal ack0, ack1, ack2, ack3                     : std_logic := 'Z';
  signal eom0, eom1, eom2, eom3                     : std_logic;
  signal data_av0, data_av1, data_av2, data_av3     : std_logic;
  signal data_out0, data_out1, data_out2, data_out3 : std_logic_vector(7 downto 0);

  signal ack_out     : std_logic;
  signal eom_out     : std_logic;
  signal data_out    : std_logic;
  signal data_av_IN  : std_logic_vector(3 downto 0);   
  signal data_av_out : std_logic_vector(3 downto 0);

  signal sel_crypto  : std_logic_vector(1 downto 0);
  signal bus_system  : std_logic_vector(15 downto 0);
  
  signal s_clk_div2, clk_div4 : std_logic;

begin
  
  clock <= not clock after 5 ns;
  reset <= '1', '0' after 12 ns;

  sel_crypto <= "00", "01" after 1 us, "10" after 2 us, "11" after 3 us; 

  data_av_IN(0) <= data_av0(0);
  data_av_IN(1) <= data_av1(1);
  data_av_IN(2) <= data_av2(2);
  data_av_IN(3) <= data_av3(3);


  EXTERNAL_CONTROL: entity work.External_Hardware(behavioral)
    port map (  
        clk         => clock;
        rst         => reset;
        
        data0       => data_out0;
        data1       => data_out1;
        data2       => data_out2;
        data3       => data_out3;

        ack0        => ack0;
        ack1        => ack1;
        ack2        => ack2;
        ack3        => ack3;

        eom0        => eom0;
        eom1        => eom1;
        eom2        => eom2;
        eom3        => eom3;
        
        data_av_IN  => data_av_IN;

        sel_crypto  => sel_crypto;

        data_av_OUT => data_av_out;
        data_out    => data_out;
        ack_out     => ack_out;
        eom_out     => eom_out

    );

  ENCRYPTER0: entity work.CryptoMessage(behavioral)
    generic map(
      --MSG_INTERVAL => 48000,
    MSG_INTERVAL => 3000,
      FILE_NAME    => "txt0.txt",
      PUBLIC_KEY   => "00000000000000000000000100000001", -- 257
      N            => 65473
    )
    port map(
      clk => s_clk_div2,
      rst => reset,

      data_out => data_out0,
      data_av  => data_av0,
      ack      => ack0,
      eom      => eom0
    );

    ENCRYPTER1: entity work.CryptoMessage(behavioral)
    generic map(
      --MSG_INTERVAL => 48000,
    MSG_INTERVAL => 3000,
      FILE_NAME    => "txt1.txt",
      PUBLIC_KEY   => "00000000000000000000000100000001", -- 257
      N            => 65473
    )
    port map(
      clk => s_clk_div2,
      rst => reset,

      data_out => data_out1,
      data_av  => data_av1,
      ack      => ack1,
      eom      => eom1
    );

    ENCRYPTER2: entity work.CryptoMessage(behavioral)
    generic map(
      --MSG_INTERVAL => 48000,
    MSG_INTERVAL => 3000,
      FILE_NAME    => "txt2.txt",
      PUBLIC_KEY   => "00000000000000000000000100000001", -- 257
      N            => 65473
    )
    port map(
      clk => s_clk_div2,
      rst => reset,

      data_out => data_out2,
      data_av  => data_av2,
      ack      => ack2,
      eom      => eom2
    );

    ENCRYPTER3: entity work.CryptoMessage(behavioral)
    generic map(
      --MSG_INTERVAL => 48000,
    MSG_INTERVAL => 3000,
      FILE_NAME    => "txt3.txt",
      PUBLIC_KEY   => "00000000000000000000000100000001", -- 257
      N            => 65473
    )
    port map(
      clk => s_clk_div2,
      rst => reset,

      data_out => data_out3,
      data_av  => data_av3,
      ack      => ack3,
      eom      => eom3
    );
  
   -- tem q dividir o clock por dois
   CLOCK_MANAGER: entity work.ClockManager(xilinx)
    port map(
      clk_in             => clock,
      -- Clock out ports
      clk_div2           => s_clk_div2,
      clk_div4           => clk_div4
    );
  
   --bus_system <= "00000"& end_of_message & 'Z' & interrupt & data_out;
  
   --CPU_MIPS: entity work.MIPS_uC(UNION)
   -- port map(
   --   clk => clock,
   --   rst => reset,

   --   External_World => bus_system

   -- );
    
end structural;