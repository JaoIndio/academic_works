library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity IO_Control is
  port(
    dataAddress : in std_logic_vector(31 downto 0);
    ce          : in std_logic;

    registerAddress   : out std_logic_vector(3 downto 0);
    dataMemoryAddress : out std_logic_vector(29 downto 0);
    ce_peripherals    : out std_logic_vector(16 downto 0)
  );
end IO_Control;

architecture Behavioral of IO_Control is
  
  signal periph_access   : std_logic;

  signal instRegionStart : std_logic_vector(31 downto 0);
  signal instRegionEnd   : std_logic_vector(31 downto 0);

  signal dataRegionStart : std_logic_vector(31 downto 0);
  signal dataRegionEnd   : std_logic_vector(31 downto 0);

  -- extra protection for execution time dinamic programming of memories.
  -- the signals receive 1 when the dataAddress is within the respective programmable region.
  signal instRegionOK    : std_logic;
  signal dataRegionOK    : std_logic;

begin

  instRegionStart <= x"00400000";
  instRegionEnd   <= x"004019A0";

  dataRegionStart <= x"10010000";
  dataRegionEnd   <= x"80000000";

  --    ce_out(16)   ce_out(15)  ce_out(14)   ce_out(0)
  --   ce_MEM ce_p0    ce_p15      ce_p14 ...   ce_p0

  instRegionOK <= '1' when ( UNSIGNED(instRegionEnd) > UNSIGNED(dataAddress) and  UNSIGNED(dataAddress) >= UNSIGNED(instRegionStart) ) else '0';
  dataRegionOK <= '1' when ( UNSIGNED(dataRegionEnd) > UNSIGNED(dataAddress) and  UNSIGNED(dataAddress) >= UNSIGNED(dataRegionStart) ) else '0';

  -- data MEM access
  ce_peripherals(16) <= ce and not(dataAddress(31)) and dataRegionOK;

  -- inst MEM write control
  ce_peripherals(15) <= ce and instRegionOK;

  -- periph access control
  periph_access <= ce and dataAddress(31);

  --ce_peripherals(15) <= periph_access and      dataAddress(7) and    (dataAddress(6)) and    (dataAddress(5)) and    (dataAddress(4)); -- ID = 1111 
  ce_peripherals(14) <= periph_access and      dataAddress(7) and    (dataAddress(6)) and    (dataAddress(5)) and not(dataAddress(4)); -- ID = 1110
  ce_peripherals(13) <= periph_access and      dataAddress(7) and    (dataAddress(6)) and not(dataAddress(5)) and    (dataAddress(4)); -- ID = 1101
  ce_peripherals(12) <= periph_access and      dataAddress(7) and    (dataAddress(6)) and not(dataAddress(5)) and not(dataAddress(4)); -- ID = 1100                                                                                                                                           
  ce_peripherals(11) <= periph_access and      dataAddress(7) and not(dataAddress(6)) and    (dataAddress(5)) and    (dataAddress(4)); -- ID = 1011
  ce_peripherals(10) <= periph_access and      dataAddress(7) and not(dataAddress(6)) and    (dataAddress(5)) and not(dataAddress(4)); -- ID = 1010
  ce_peripherals(9)  <= periph_access and      dataAddress(7) and not(dataAddress(6)) and not(dataAddress(5)) and    (dataAddress(4)); -- ID = 1001
  ce_peripherals(8)  <= periph_access and      dataAddress(7) and not(dataAddress(6)) and not(dataAddress(5)) and not(dataAddress(4)); -- ID = 1000                                                                                                                                
  ce_peripherals(7)  <= periph_access and not(dataAddress(7)) and    (dataAddress(6)) and    (dataAddress(5)) and    (dataAddress(4)); -- ID = 0111
  ce_peripherals(6)  <= periph_access and not(dataAddress(7)) and    (dataAddress(6)) and    (dataAddress(5)) and not(dataAddress(4)); -- ID = 0110
  ce_peripherals(5)  <= periph_access and not(dataAddress(7)) and    (dataAddress(6)) and not(dataAddress(5)) and    (dataAddress(4)); -- ID = 0101
  ce_peripherals(4)  <= periph_access and not(dataAddress(7)) and    (dataAddress(6)) and not(dataAddress(5)) and not(dataAddress(4)); -- ID = 0100                                                                                                                             
  ce_peripherals(3)  <= periph_access and not(dataAddress(7)) and not(dataAddress(6)) and    (dataAddress(5)) and    (dataAddress(4)); -- ID = 0011
  ce_peripherals(2)  <= periph_access and not(dataAddress(7)) and not(dataAddress(6)) and    (dataAddress(5)) and not(dataAddress(4)); -- ID = 0010
  ce_peripherals(1)  <= periph_access and not(dataAddress(7)) and not(dataAddress(6)) and not(dataAddress(5)) and    (dataAddress(4)); -- ID = 0001
  ce_peripherals(0)  <= periph_access and not(dataAddress(7)) and not(dataAddress(6)) and not(dataAddress(5)) and not(dataAddress(4)); -- ID = 0000

  -- PIN OUT
  registerAddress  <= dataAddress(3 downto 0);
  dataMemoryAddress    <= dataAddress(31 downto 2);
  
end Behavioral;



