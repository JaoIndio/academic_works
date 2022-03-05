

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity MIPS_FPGA_TEST is
  port(
    clk : in std_logic;
    rst : in std_logic;

    display_enbl : out std_logic_vector(3 downto 0);
    display_out  : out std_logic_vector(6 downto 0);
    LED_out_TEST : out std_logic_vector(3 downto 0)

  );
end MIPS_FPGA_TEST;

architecture UNION of MIPS_FPGA_TEST is
  signal clk_not: std_logic;
  signal clk_n, s_clk_div2, clk_div4, s_rst, sn_rst, MemWrite, ce: std_logic;
  signal s_display_enbl : std_logic_vector(3 downto 0);
  signal instructionAddress, dataAddress, instruction, s_data_i, s_data_o: std_logic_vector(31 downto 0);
  
  signal and_ce_RegDisp  : std_logic;
  signal and_ce_DATA_RAM : std_logic;

  constant MARS_INSTRUCTION_OFFSET    : std_logic_vector(31 downto 0) := x"00400000";
  constant MARS_DATA_OFFSET           : std_logic_vector(31 downto 0) := x"10010000";

  component ClockManager is port(clk_in            : in     std_logic;
                                 clk_div2          : out    std_logic;
                                 clk_div4          : out    std_logic
                                ); 
  end component;

  component RstSync is port(clk     : in  std_logic;
                            rst_in  : in  std_logic;
                            rst_out : out std_logic
                           );
  end component;

  component Display_ZR is port(clk     : in std_logic;
                            rst     : in std_logic;
                            ctrl_en : in std_logic;
                            number  : in std_logic_vector(15 downto 0);

                            display_out  : out std_logic_vector(6 downto 0);
                            display_enbl : out std_logic_vector(3 downto 0) 
                          );
  end component; 

  component MIPS_multicycle is 
    generic( PC_START_ADDRESS : integer := 0 );
    
    port(clock              : in std_logic; 
         reset              : in std_logic;
        
        -- Instruction memory interface
        instructionAddress  : out std_logic_vector(31 downto 0);
        instruction         : in  std_logic_vector(31 downto 0);
        
        -- Data memory interface
        dataAddress         : out std_logic_vector(31 downto 0);
        data_i              : in  std_logic_vector(31 downto 0);      
        data_o              : out std_logic_vector(31 downto 0);
        ce                  : out std_logic;
        MemWrite            : out std_logic
        );

  end component;

  component Memory is
    generic (
        SIZE            : integer := 100;    -- Memory depth
        imageFileName   : string  := "UNUSED";        -- Memory content to be loaded
        OFFSET          : UNSIGNED(31 downto 0) := x"00000000"
      );
    port(clock           : in std_logic;
         ce              : in std_logic; -- Enable the memory
         wr              : in std_logic;  -- Write enable
         address         : in std_logic_vector (29 downto 0); 
         data_i          : in std_logic_vector (31 downto 0);
         data_o          : out std_logic_vector (31 downto 0)
        ); 
  end component;

begin

  SINC_RST : RstSync 
    port map(s_clk_div2, rst, s_rst);

  DCM : ClockManager
    port map(clk, s_clk_div2, clk_div4);

  SHOW_NUMBER: Display_ZR port map(s_clk_div2, sn_rst, and_ce_RegDisp, s_data_o(15 downto 0), display_out, s_display_enbl);

  CPU : MIPS_multicycle 
    generic map (TO_INTEGER(UNSIGNED(MARS_INSTRUCTION_OFFSET)))
    port map(s_clk_div2, sn_rst, instructionAddress, instruction, dataAddress, s_data_i, s_data_o, ce, MemWrite);

  INST_MEM : Memory 
    generic map(18, "Display_number_code.txt", UNSIGNED(MARS_INSTRUCTION_OFFSET))
    port map(clk_n, '1', '0', instructionAddress(31 downto 2), s_data_o, instruction);

  DATA_MEM : Memory
    generic map(3, "Display_number_data.txt", UNSIGNED(MARS_DATA_OFFSET))
    port map(clk_n, and_ce_DATA_RAM, MemWrite, dataAddress(31 downto 2), s_data_o, s_data_i);
        
  and_ce_DATA_RAM <= not(dataAddress(31)) and ce;
  and_ce_RegDisp  <= MemWrite and ce and dataAddress(31);
  clk_n <= not s_clk_div2;
  
  LED_out_TEST <= "0000";
  display_enbl <= s_display_enbl;
  --display_enbl <= "1110";
  sn_rst <= not s_rst; -- se nao for assim a placa ZR processará que o botao esta precionado. Ou seja sem sn_rst, para a cpu funcionar o botao
                       -- deve estar precionado
  
end UNION;

