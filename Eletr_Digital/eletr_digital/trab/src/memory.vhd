-------------------------------------------------------------------------
-- Design unit: Memory
-- Description: Parameterizable memory
--      Asynchronous read
--      Synchronous write
--      Bidirectional data bus
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity Memory is
    generic (
        DATA_WIDTH  : integer := 8;
        ADDR_WIDTH  : integer := 8
    );
    port (  
        clk         : in std_logic;
        cs          : in std_logic;     -- Chip Select
        rw          : in std_logic;     -- rw = 0: READ; rw = 1: WRITE
        address     : in std_logic_vector (ADDR_WIDTH-1 downto 0);
        data        : inout std_logic_vector (DATA_WIDTH-1 downto 0)
    );
end Memory;


architecture behavioral of Memory is

    -- Word addressed memory
    type Memory is array (0 to (2**ADDR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal memoryArray: Memory;

begin

    -- Memory read
    data <= memoryArray(TO_INTEGER(UNSIGNED(address))) when rw = '0' and cs = '1' else (others=>'Z');
    
    -- Process to store words
    process(clk)
    begin        
        if rising_edge(clk) then    -- Memory writing        
            if rw = '1' and cs = '1' then
                memoryArray(TO_INTEGER(UNSIGNED(address))) <= data; 
            end if;
        end if;
        
    end process;
        
end behavioral;