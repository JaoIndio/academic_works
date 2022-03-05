library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity External_Hardware  is
    port (  
        clk         : in std_logic;
        rst         : in std_logic;
        
        data0       : in std_logic_vector(7 downto 0);
        data1       : in std_logic_vector(7 downto 0);
        data2       : in std_logic_vector(7 downto 0);
        data3       : in std_logic_vector(7 downto 0);

        ack0        : out std_logic;
        ack1        : out std_logic;
        ack2        : out std_logic;
        ack3        : out std_logic;

        eom0        : in std_logic;
        eom1        : in std_logic;
        eom2        : in std_logic;
        eom3        : in std_logic;
        

        sel_crypto  : in std_logic_vector(1 downto 0);

        data_MIPS    : out std_logic_vector(7 downto 0);
        ack_MIPS     : in std_logic;
        eom_MIPS     : out std_logic

    );
end External_Hardware;

architecture Behavioral of External_Hardware  is

  signal sel_crypto_reg : std_logic_vector(1 downto 0);

begin

  process(clk, rst)
    begin
    
    if rst = '1' then

      sel_crypto_reg <= "00";

    elsif rising_edge(clk) then
      sel_crypto_reg <= sel_crypto;  
    end if;

  end process;

  data_MIPS <= data0 when sel_crypto_reg = "00" else
               data1 when sel_crypto_reg = "01" else
               data2 when sel_crypto_reg = "10" else
               data3;

  ack0 <= ack_MIPS when sel_crypto_reg = "00" else 'Z';
  ack1 <= ack_MIPS when sel_crypto_reg = "01" else 'Z';
  ack2 <= ack_MIPS when sel_crypto_reg = "10" else 'Z';
  ack3 <= ack_MIPS when sel_crypto_reg = "11" else 'Z';
        
  eom_MIPS  <= eom0 when sel_crypto_reg = "00" else
               eom1 when sel_crypto_reg = "01" else
               eom2 when sel_crypto_reg = "10" else
               eom3;

end  Behavioral;