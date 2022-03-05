library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity MIPS_uC is
  port(
    clk : in std_logic;
    rst : in std_logic;

    External_World : inout std_logic_vector(15 downto 0)
  );
end MIPS_uC;

architecture UNION of MIPS_uC is

  -- interruption syncronaized signals
  signal sync_irq0 : std_logic;
  signal sync_irq1 : std_logic;

  -- inst mem address and data output, and data memory output
  signal instructionAddress, instruction, dataMemory_o : std_logic_vector(31 downto 0);

  -- bidirectioinal port data output (back to the CPU)
  signal BidiPort_data_o                       : std_logic_vector(15 downto 0);
  signal irq                                   : std_logic_vector(15 downto 0);

  --IO_Control signals
  signal dataMemoryAddress                     : std_logic_vector(29 downto 0);
  signal registerAddress                       : std_logic_vector(3 downto 0);  -- register address for the peripherals
  signal ce_peripherals                        : std_logic_vector(16 downto 0); -- each bit activates one peripheral

  -- peripherals data outputs (back to the bidirectional port)
  signal info_out_1, info_out_2                : std_logic_vector(15 downto 0);

  -- ClockManager and rst_sync signals
  signal clk_n, s_clk_div2, clk_div4           : std_logic;
  signal s_rst, sn_rst                         : std_logic;

  -- MIPS control signals
  signal MemWrite, ce, irq_OR                  : std_logic;

  -- MIPS data input, data output, and output adresss
  signal MIPS_data_o, MIPS_data_i, dataAddress : std_logic_vector(31 downto 0);

  -- MARS address offset
  constant MARS_INSTRUCTION_OFFSET             : std_logic_vector(31 downto 0) := x"00400000";
  constant MARS_DATA_OFFSET                    : std_logic_vector(31 downto 0) := x"10010000";

begin

  CLOCK_MANAGER: entity work.ClockManager(xilinx)
    port map(
      clk_in             => clk,
      -- Clock out ports
      clk_div2           => s_clk_div2,
      clk_div4           => clk_div4
    );

  BUT_SYNC0: entity work.ButSinc(behavioral)
    port map(
      clk             => s_clk_div2,

      but_in             => External_World(0),
      but_out            => sync_irq0
    );

  BUT_SYNC1: entity work.ButSinc(behavioral)
    port map(
      clk             => s_clk_div2,

      but_in             => External_World(1),
      but_out            => sync_irq1
    );

  RST_SYNC : entity work.RstSync(behavioral)
    port map(
      clk                => s_clk_div2,
      rst_in             => rst, 
      rst_out            => s_rst
    );

  INST_MEM : entity work.Memory(BlockRAM)
    generic map (
      SIZE               => 211,                                 -- Memory depth (size of BubbleSort_code.txt)
      OFFSET             => UNSIGNED(MARS_INSTRUCTION_OFFSET),   -- MARS initial address (mapped to memory address 0x00000000)
      imageFileName      => "system_code.txt"                           --imageFileName   => "BubbleSort_code.txt"
    )
    port map (
      clock              => clk_n,
      ce                 => '1',
      wr                 => '0',
      address            => instructionAddress(31 downto 2),     -- Converts byte address to word address     
      data_i             => MIPS_data_o,
      data_o             => instruction
    );

  DATA_MEM : entity work.Memory(BlockRAM)
    generic map (
      SIZE               => 141,                           -- Memory depth 
      OFFSET             => UNSIGNED(MARS_DATA_OFFSET),   -- MARS initial address (mapped to memory address 0x00000000)
      imageFileName      => "MEM_image.txt"                    --imageFileName   => "BubbleSort_data.txt"
    )
    port map (
      clock              => clk_n,
      ce                 => ce_peripherals(16),
      wr                 => MemWrite,
      address            => dataMemoryAddress,    -- Converts byte address to word address 
      data_i             => MIPS_data_o,
      data_o             => dataMemory_o
    );

  DECODE : entity work.IO_Control(Behavioral) -- IO_Control
    port map(
      -- inputs
      dataAddress        => dataAddress,
      ce                 => ce,

      -- outputs
      registerAddress   => registerAddress,
      dataMemoryAddress => dataMemoryAddress,
      ce_peripherals    => ce_peripherals
    );

  -- Bidirectional Port ID = 0
  BID_PORT : entity work.BidirectionalPort(Behavioral)
    generic map (
      DATA_WIDTH         => 16,
      PORT_DATA_ADDR     => "10",
      PORT_CONFIG_ADDR   => "01", 
      PORT_ENABLE_ADDR   => "00",
      IRQ_ENABLE_ADDR    => "11"
    )
    port map(  
      clk                => clk_n,
      rst                => s_rst, 
        
      -- Processor interface
      data_i             => MIPS_data_o(15 downto 0),
      data_o             => BidiPort_data_o,
      irq                => irq,
      address            => registerAddress(1 downto 0),
      rw                 => MemWrite,
      ce                 => ce_peripherals(0),
        
      -- External interface
      port_io            => External_World
      --port_io            => External_World(15 downto 3) & sync_irq1 & sync_irq0 -- the interruptions need to be at high level just for a determinate time
    );

  MIPS : entity work.MIPS_multicycle(behavioral)
    generic map (
      PC_START_ADDRESS   => TO_INTEGER(UNSIGNED(MARS_INSTRUCTION_OFFSET))
    )
    port map (
      clock              => s_clk_div2,
      reset              => s_rst,
            
      -- Instruction memory interface
      instructionAddress => instructionAddress,    
      instruction        => instruction,        
                 
      -- Data memory interface
      dataAddress        => dataAddress,
      data_i             => MIPS_data_i,
      data_o             => MIPS_data_o,
      ce                 => ce,
      MemWrite           => MemWrite,

      irq                => irq_OR
    );                 

  MUX_MIPS_DATA_IN: MIPS_data_i <= "0000000000000000" & BidiPort_data_o when dataAddress(31) = '1' else
                    dataMemory_o; 

  irq_OR <= irq(0) or irq(1) or irq(2) or irq(3) or irq(4) or irq(5) or irq(6) or irq(7) or irq(8) or irq(9) or irq(10) or irq(11) or irq(12) or irq(13)  or irq(14) or irq(15);

  sn_rst <= not s_rst; 
  clk_n <= not s_clk_div2;

end UNION;


