-------------------------------------------------------------------------
-- Design unit: MIPS monocycle test bench
-- Description: 
-------------------------------------------------------------------------

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MIPS_monocycle_tb is
end MIPS_monocycle_tb;

architecture structural of MIPS_monocycle_tb is

    signal clock: std_logic := '0';
    signal clk_n, reset, MemWrite, ce: std_logic;
    signal instructionAddress, dataAddress, instruction, data_i, data_o: std_logic_vector(31 downto 0);

    constant MARS_INSTRUCTION_OFFSET    : std_logic_vector(31 downto 0) := x"00400000";
    constant MARS_DATA_OFFSET           : std_logic_vector(31 downto 0) := x"10010000";
    
begin

    clock <= not clock after 5 ns;
    
    clk_n <= not clock;
    
    reset <= '1', '0' after 12 ns;
                
        
    MIPS_MONOCYCLE: entity work.MIPS_monocycle(behavioral) 
        generic map (
            PC_START_ADDRESS => TO_INTEGER(UNSIGNED(MARS_INSTRUCTION_OFFSET))
        )
        port map (
            clock               => clock,
            reset               => reset,
            
            -- Instruction memory interface
            instructionAddress  => instructionAddress,    
            instruction         => instruction,        
                 
             -- Data memory interface
            dataAddress         => dataAddress,
            data_i              => data_i,
            data_o              => data_o,
            ce                  => ce,
            MemWrite            => MemWrite
        );
    
    
    INSTRUCTION_MEMORY: entity work.Memory(BlockRAM)
        generic map (
            SIZE            => 87,                                  -- Memory depth (size of BubbleSort_code.txt)
            OFFSET          => UNSIGNED(MARS_INSTRUCTION_OFFSET),   -- MARS initial address (mapped to memory address 0x00000000)
            imageFileName   => "inst_test_code.txt" --imageFileName   => "BubbleSort_code.txt"
        )
        port map (
            clock           => clk_n,
            ce              => '1',
            wr              => '0',
            address         => instructionAddress(31 downto 2), -- Converts byte address to word address     
            data_i          => data_o,
            data_o          => instruction
        );
        
        
    DATA_MEMORY: entity work.Memory(BlockRAM)
        generic map (
            SIZE            => 100,                         -- Memory depth 
            OFFSET          => UNSIGNED(MARS_DATA_OFFSET),  -- MARS initial address (mapped to memory address 0x00000000)
            imageFileName   => "inst_test_data.txt" --imageFileName   => "BubbleSort_data.txt"
        )
        port map (
            clock           => clk_n,
            wr              => MemWrite,
            ce              => ce,
            address         => dataAddress(31 downto 2),    -- Converts byte address to word address 
            data_i          => data_o,
            data_o          => data_i
        );    
    
end structural;



