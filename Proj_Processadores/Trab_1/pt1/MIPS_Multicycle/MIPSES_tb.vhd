-------------------------------------------------------------------------
-- Design unit: MIPS monocycle test bench
-- Description: 
-------------------------------------------------------------------------

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MIPSES_tb is
end MIPSES_tb;

architecture structural of MIPSES_tb is

    signal clock: std_logic := '0';
    signal clk_n, reset, MemWrite, ce: std_logic;
    signal instructionAddress, dataAddress, instruction, data_i, data_o: std_logic_vector(31 downto 0);

    signal instructionAddress_mono, dataAddress_mono, instruction_mono, data_i_mono, data_o_mono: std_logic_vector(31 downto 0);

    constant MARS_INSTRUCTION_OFFSET    : std_logic_vector(31 downto 0) := x"00400000";
    constant MARS_DATA_OFFSET           : std_logic_vector(31 downto 0) := x"10010000";
    
begin

    clock <= not clock after 5 ns;
    
    clk_n <= not clock;
    
    reset <= '1', '0' after 12 ns;
                
        
    MIPS_MULTICYCLE: entity work.MIPS_multicycle(behavioral) 
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
            SIZE            => 26,                                  -- Memory depth (size of BubbleSort_code.txt)
            OFFSET          => UNSIGNED(MARS_INSTRUCTION_OFFSET),   -- MARS initial address (mapped to memory address 0x00000000)
            imageFileName   => "BubbleSort_code.txt"
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
            imageFileName   => "BubbleSort_data.txt"
        )
        port map (
            clock           => clk_n,
            wr              => MemWrite,
            ce              => ce,
            address         => dataAddress(31 downto 2),    -- Converts byte address to word address 
            data_i          => data_o,
            data_o          => data_i
        );

    MIPS_MONOCYCLE: entity work.MIPS_monocycle(behavioral) 
        generic map (
            PC_START_ADDRESS => TO_INTEGER(UNSIGNED(MARS_INSTRUCTION_OFFSET))
        )
        port map (
            clock               => clock,
            reset               => reset,
            
            -- Instruction memory interface
            instructionAddress  => instructionAddress_mono,    
            instruction         => instruction_mono,        
                 
             -- Data memory interface
            dataAddress         => dataAddress_mono,
            data_i              => data_i_mono,
            data_o              => data_o_mono,
            ce                  => ce,
            MemWrite            => MemWrite
        ); 

    INSTRUCTION_MEMORY2: entity work.Memory(BlockRAM)
        generic map (
            SIZE            => 26,                                  -- Memory depth (size of BubbleSort_code.txt)
            OFFSET          => UNSIGNED(MARS_INSTRUCTION_OFFSET),   -- MARS initial address (mapped to memory address 0x00000000)
            imageFileName   => "BubbleSort_code.txt"
        )
        port map (
            clock           => clk_n,
            ce              => '1',
            wr              => '0',
            address         => instructionAddress_mono(31 downto 2), -- Converts byte address to word address     
            data_i          => data_o_mono,
            data_o          => instruction_mono
        );
        
        
    DATA_MEMORY2: entity work.Memory(BlockRAM)
        generic map (
            SIZE            => 100,                         -- Memory depth 
            OFFSET          => UNSIGNED(MARS_DATA_OFFSET),  -- MARS initial address (mapped to memory address 0x00000000)
            imageFileName   => "BubbleSort_data.txt"
        )
        port map (
            clock           => clk_n,
            wr              => MemWrite,
            ce              => ce,
            address         => dataAddress_mono(31 downto 2),    -- Converts byte address to word address 
            data_i          => data_o_mono,
            data_o          => data_i_mono
        );   
    
end structural;
