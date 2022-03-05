library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity Periph_aux is
  port(
    clk     : in std_logic;
    rst     : in std_logic;
    ce      : in std_logic;
    rw      : in std_logic; -- 0=read; 1=write
    add     : in std_logic_vector(3 downto 0);
    info_in : in std_logic_vector(15 downto 0);

    info_out : out std_logic_vector(15 downto 0)
  );
end Periph_aux;

architecture Behavioral of Periph_aux is
  signal Reg_0, Reg_1, Reg_2, Reg_3 : std_logic_vector(15 downto 0);

begin

  process(clk, rst)
  begin
    if rst = '1' then
      info_out <= (others => 'Z');

      Reg_0 <= (others => '0');
      Reg_1 <= (others => '0');
      Reg_2 <= (others => '0');
      Reg_3 <= (others => '0');

    elsif rising_edge(clk) then
    
      if ce = '1' then
        if rw = '1' then
        
          if add = "0000" then
            Reg_0 <= info_in;
          elsif add = "0001" then
            Reg_1 <= info_in;
          elsif add = "0010" then
            Reg_2 <= info_in;
          else
            Reg_3 <= info_in;
          end if;

        else 

          if add = "0000" then
            info_out <= Reg_0;
          elsif add = "0001" then
            info_out <= Reg_1;
          elsif add = "0010" then
            info_out <= Reg_2;
          else
            info_out <= Reg_3;
          end if;
          
        end if;

      end if;
      
    end if;
  end process;
end Behavioral;

