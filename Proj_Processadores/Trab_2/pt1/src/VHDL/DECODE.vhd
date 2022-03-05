library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DECODE is
  port(
    --clk         : in std_logic;
    --rst         : in std_logic;
    dataAddress : in std_logic_vector(31 downto 0);
    --rw          : in std_logic;
    ce          : in std_logic;

    PERIPH_add  : out std_logic_vector(3 downto 0);
    MEM_add     : out std_logic_vector(29 downto 0);
    ce_out      : out std_logic_vector(16 downto 0)
    --PREVIOUS_ID : out std_logic_vector(3 downto 0)
  );
end DECODE;

architecture Behavioral of DECODE is
  
  signal s_PRVIOUS_ID   : std_logic_vector(3 downto 0);
  
  signal ce_AND_DataAdd : std_logic;
  signal s_PERIPH_add   : std_logic_vector(3 downto 0);
  signal s_MEM_add      : std_logic_vector(29 downto 0); 

begin

  --    ce_out(16)   ce_out(15)  ce_out(14)   ce_out(0)
  --   ce_MEM ce_p0    ce_p15      ce_p14 ...   ce_p0

  ce_out(16) <= ce and not(dataAddress(31));

  ce_out(15) <= ce_AND_DataAdd and dataAddress(7) and (dataAddress(6)) and (dataAddress(5)) and (dataAddress(4));               -- dataAddress = 1111 
  ce_out(14) <= ce_AND_DataAdd and dataAddress(7) and (dataAddress(6)) and (dataAddress(5)) and not(dataAddress(4));            -- dataAddress = 1110
  ce_out(13) <= ce_AND_DataAdd and dataAddress(7) and (dataAddress(6)) and not(dataAddress(5)) and (dataAddress(4));            -- dataAddress = 1101
  ce_out(12) <= ce_AND_DataAdd and dataAddress(7) and (dataAddress(6)) and not(dataAddress(5)) and not(dataAddress(4));         -- dataAddress = 1100
                                                                                                                                              
  ce_out(11) <= ce_AND_DataAdd and dataAddress(7) and not(dataAddress(6)) and (dataAddress(5)) and (dataAddress(4));            -- dataAddress = 1011
  ce_out(10) <= ce_AND_DataAdd and dataAddress(7) and not(dataAddress(6)) and (dataAddress(5)) and not(dataAddress(4));         -- dataAddress = 1010
  ce_out(9)  <= ce_AND_DataAdd and dataAddress(7) and not(dataAddress(6)) and not(dataAddress(5)) and (dataAddress(4));         -- dataAddress = 1001
  ce_out(8)  <= ce_AND_DataAdd and dataAddress(7) and not(dataAddress(6)) and not(dataAddress(5)) and not(dataAddress(4));      -- dataAddress = 1000
                                                                                                                                  
  ce_out(7)  <= ce_AND_DataAdd and not(dataAddress(7)) and (dataAddress(6)) and (dataAddress(5)) and (dataAddress(4));          -- dataAddress = 0111
  ce_out(6)  <= ce_AND_DataAdd and not(dataAddress(7)) and (dataAddress(6)) and (dataAddress(5)) and not(dataAddress(4));       -- dataAddress = 0110
  ce_out(5)  <= ce_AND_DataAdd and not(dataAddress(7)) and (dataAddress(6)) and not(dataAddress(5)) and (dataAddress(4));       -- dataAddress = 0101
  ce_out(4)  <= ce_AND_DataAdd and not(dataAddress(7)) and (dataAddress(6)) and not(dataAddress(5)) and not(dataAddress(4));    -- dataAddress = 0100
                                                                                                                               
  ce_out(3)  <= ce_AND_DataAdd and not(dataAddress(7)) and not(dataAddress(6)) and (dataAddress(5)) and (dataAddress(4));       -- dataAddress = 0011
  ce_out(2)  <= ce_AND_DataAdd and not(dataAddress(7)) and not(dataAddress(6)) and (dataAddress(5)) and not(dataAddress(4));    -- dataAddress = 0010
  ce_out(1)  <= ce_AND_DataAdd and not(dataAddress(7)) and not(dataAddress(6)) and not(dataAddress(5)) and (dataAddress(4));    -- dataAddress = 0001
  ce_out(0)  <= ce_AND_DataAdd and not(dataAddress(7)) and not(dataAddress(6)) and not(dataAddress(5)) and not(dataAddress(4)); -- dataAddress = 0000

  ce_AND_DataAdd <= ce and dataAddress(31);

  s_PERIPH_add <= dataAddress(3 downto 0);
  s_MEM_add    <= dataAddress(31 downto 2);

  --process(clk, rst, ce)
  --begin

  --  if rst = '1' then
  --    s_PRVIOUS_ID <= (others => '0');
  --  elsif rising_edge(clk) then
  --    if ce = '1' then
  --      s_PRVIOUS_ID <= dataAddress(7 downto 4);
  --      --if rw = '0' then

  --      --end if;
  --    end if;
  --  end if;
        
  --end process;

  -- PIN OUT
  PERIPH_add  <= s_PERIPH_add;
  MEM_add     <= s_MEM_add;
  --PREVIOUS_ID <= s_PRVIOUS_ID;
  
end Behavioral;

