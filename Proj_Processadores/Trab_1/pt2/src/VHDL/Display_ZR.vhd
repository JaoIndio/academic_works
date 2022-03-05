library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Display_ZR is
  port(
    clk     : in std_logic;
    rst     : in std_logic;
    ctrl_en : in std_logic;
    number  : in std_logic_vector(15 downto 0);

    display_out      : out std_logic_vector(6 downto 0);
    display_enbl : out std_logic_vector(3 downto 0)
  );

end Display_ZR;

architecture Behavioral of Display_ZR is
  
  signal s_display0, s_display1, s_display2, s_display3 : std_logic_vector(6 downto 0); 
  signal RegDisp : std_logic_vector (15 downto 0);

  component BCD7_ZR is 
    port(
      a : in  std_logic_vector(3 downto 0);
      b : out std_logic_vector(6 downto 0)
    );
  end component; 

  component DisplayCtrl is 
    port(
      clk             : in std_logic;
      rst             : in std_logic;
      segments        : out std_logic_vector(6 downto 0);    
      display_en_n    : out std_logic_vector(3 downto 0);
        
      display0        : in std_logic_vector(6 downto 0);  -- Right most display
      display1        : in std_logic_vector(6 downto 0);
      display2        : in std_logic_vector(6 downto 0);
      display3        : in std_logic_vector(6 downto 0)   -- Left most display
    );
  end component;

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if ctrl_en = '1' then
        RegDisp <= number;
      end if; 
    end if;
  end process;

  DISPLAY0: BCD7_ZR port map(RegDisp(3 downto 0), s_display0);
  DISPLAY1: BCD7_ZR port map(RegDisp(7 downto 4), s_display1);
  DISPLAY2: BCD7_ZR port map(RegDisp(11 downto 8), s_display2);
  DISPLAY3: BCD7_ZR port map(RegDisp(15 downto 12), s_display3);

  DISPLAY_CONTROL: DisplayCtrl port map(clk, rst, display_out, display_enbl, s_display0, s_display1, s_display2, s_display3);

end Behavioral;

