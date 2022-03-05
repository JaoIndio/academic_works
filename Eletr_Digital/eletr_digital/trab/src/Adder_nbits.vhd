-------------------------------------------------------------------------
-- Design unit: Adder_nbits
-- Description: Parameterizable adder
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;    -- Definição de operações aritméticas sobre os tipos std_logic/std_logic_vector


-- Adder interface definition. 
entity Adder_nbits is
    generic(
        WIDTH       : integer := 8
    );
    port(
        A           : in std_logic_vector(WIDTH-1 downto 0);    -- A input
        B           : in std_logic_vector(WIDTH-1 downto 0);    -- B input
        CarryIn     : in std_logic;                        -- Carry in 
        Sum         : out std_logic_vector(WIDTH-1 downto 0); -- Sum
        CarryOut    : out std_logic                     -- Carry out
    );
end Adder_nbits;


-- Adder structural architecture version2.
architecture structural_generic of Adder_nbits is

    -- Signal used to propagate the carry out beteen the full adders
    signal Carry: std_logic_vector(WIDTH downto 0);
    
begin            
    
    Carry(0) <= CarryIn;        -- Sets the full adder bit 0 carry in (CarryIn input)
    CarryOut <= Carry(WIDTH);    -- Sets the adder carry out (full adder bit 7 carry out)
    
    --AdderBit: for i in 0 to WIDTH-1 generate
    AdderBit: for i in A'reverse_range generate
        FullAdder: Entity work.FullAdder(arch4) port map (
            A    => A(i),
            B    => B(i),
            Ci   => Carry(i),
            S    => Sum(i),
            Co   => Carry(i+1)
        );    
    end generate;        
        
end structural_generic;


-- Adder behavioral architecture.
architecture behavioral_generic of Adder_nbits is

    -- Signals used to extend the inputs/outputs
    signal a_s, b_s, sum_s : std_logic_vector(WIDTH downto 0);
    
begin
    
    -- Extends the inputs in 1 bit
    a_s <= '0' & a;    
    b_s <= '0' & b;
    
    -- Generates the sum
    sum_s <= a_s + b_s + CarryIn;
    
    -- Outputs only WIDTH bits
    Sum <= sum_s(WIDTH-1 downto 0);
    
    -- Outputs the carry out
    CarryOut <= sum_s(WIDTH);
        
end behavioral_generic;

