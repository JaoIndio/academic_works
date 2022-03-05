library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ConfigMode_HW is
  port( clk : in std_logic;
        rst : in std_logic;

        btn : in std_logic;

        --Interruption        : out std_logic;
        ConfigMode          : out std_logic_vector(1 downto 0)
    );
end ConfigMode_HW;

architecture Behavioral of ConfigMode_HW is
  
  type state is (InstMODE, DataMODE, ExecMODE);
  signal currentState: state;
  signal ConfigModeS : std_logic_vector(1 downto 0);
 
  begin

  process(clk, rst)
    begin
    
    if rst = '1' then

      currentState <= InstMODE;
      ConfigModeS  <= "00";
      --Interruption <= '1';

    elsif rising_edge(clk) then
      if btn = '1' then

        --Interruption <= '1';

        if currentState = InstMODE then
          currentState <= DataMODE;  
          ConfigModeS  <= "01";
        
        elsif currentState = DataMODE then
          currentState <= ExecMODE;
          ConfigModeS  <= "10";
        
        else
          currentState <= InstMODE;
          ConfigModeS  <= "00";
        end if;

      --else
        --Interruption <= '0';
      
      end if;

    end if;

  end process;

  ConfigMode <= ConfigModeS;

end Behavioral;