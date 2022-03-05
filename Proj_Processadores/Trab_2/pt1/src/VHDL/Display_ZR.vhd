library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Display_ZR is
  port(
    clk     : in std_logic;
    rst     : in std_logic;
    rw      : in std_logic;
    ce      : in std_logic;
    number  : in std_logic_vector(15 downto 0);

    display_out  : out std_logic_vector(6 downto 0);
    display_enbl : out std_logic_vector(3 downto 0)
  );

end Display_ZR;

architecture Behavioral of Display_ZR is
  
  signal s_display0, s_display1, s_display2, s_display3 : std_logic_vector(6 downto 0); 
  signal RegDisp : std_logic_vector (15 downto 0);


begin

  process(clk, rst)
  begin
    if rst ='1' then
      RegDisp <= (others => '0');
    elsif rising_edge(clk) then
      if ce = '1' and rw = '1' then
        RegDisp <= number;
      end if; 
    end if;
  end process;

  DISPLAY0: entity work.BCD7_ZR(core) 
    port map(
      a              => RegDisp(3 downto 0), 
      b              => s_display0
    );


  DISPLAY1: entity work.BCD7_ZR(core) 
    port map(
      a              => RegDisp(7 downto 4), 
      b              => s_display1
    );
	
  --DISPLAY2: entity work.BCD7_ZR(core) 
  --  port map(
  --    a              => RegDisp(11 downto 8), 
  --    b              => s_display2
  --  );


  --DISPLAY3: entity work.BCD7_ZR(core) 
  --  port map(
  --    a              => RegDisp(15 downto 12), 
  --    b              => s_display3
  --  );

  DISPLAY_CONTROL: entity work.DisplayCtrl(arch1) 
    port map(
      clk            => clk, 
      rst            => rst, 
      segments       => display_out, 
      display_en_n   => display_enbl, 
      display0       => s_display0, 
      display1       => s_display1, 
      display2       => s_display2, 
      display3       => s_display3
    );

end Behavioral;

