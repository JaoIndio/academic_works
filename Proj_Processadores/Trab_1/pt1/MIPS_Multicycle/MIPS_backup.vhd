-------------------------------------------------------------------------
-- Design unit: MIPS monocycle
-- Description: Control and data paths port map
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MIPS_monocycle is
    generic (
        PC_START_ADDRESS    : integer := 0 
    );
    port ( 
        clock, reset        : in std_logic;
        
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
end MIPS_monocycle;

architecture behavioral of MIPS_monocycle is

    signal incrementedPC, pc, readData2, writeData: UNSIGNED(31 downto 0);
    signal signExtend, zeroExtended : std_logic_vector(31 downto 0);
    signal ALUoperand1, ALUoperand2, result: UNSIGNED(31 downto 0);
    signal branchOffset, branchTarget, inPC: UNSIGNED(31 downto 0);
    signal writeRegister   : std_logic_vector(4 downto 0);
    signal RegWrite : std_logic;
    
    -- inst_type defines the instructions decodable by the control unit
    type Instruction_type is (ADDU, SUBU, AAND, OOR, SW, LW, ADDIU, ORI, SLT, BEQ, J, JR, JAL, LUI, INVALID_INSTRUCTION);
    
    -- Register file
    type RegisterArray is array (natural range <>) of UNSIGNED(31 downto 0);
    signal registerFile: RegisterArray(0 to 31);
    
    -- Retrieves the rs field from the instruction
    alias rs: std_logic_vector(4 downto 0) is instruction(25 downto 21);
        
    -- Retrieves the rt field from the instruction
    alias rt: std_logic_vector(4 downto 0) is instruction(20 downto 16);
        
    -- Retrieves the rd field from the instruction
    alias rd: std_logic_vector(4 downto 0) is instruction(15 downto 11);
    
    -- ALU zero flag
    signal zero : std_logic;
     
    -- Alias to identify the instructions based on the 'opcode' and 'funct' fields
    alias  opcode: std_logic_vector(5 downto 0) is instruction(31 downto 26);
    alias  funct: std_logic_vector(5 downto 0) is instruction(5 downto 0);
    
    signal decodedInstruction: Instruction_type;
    
    
        
begin

    -- Instruction decoding
    decodedInstruction <=   ADDU    when opcode = "000000" and funct = "100001" else
                            SUBU    when opcode = "000000" and funct = "100011" else
                            AAND    when opcode = "000000" and funct = "100100" else
                            OOR     when opcode = "000000" and funct = "100101" else
                            SLT     when opcode = "000000" and funct = "101010" else
                            SW      when opcode = "101011" else
                            LW      when opcode = "100011" else
                            ADDIU   when opcode = "001001" else
                            ORI     when opcode = "001101" else
                            BEQ     when opcode = "000100" else
                            J       when opcode = "000010" else
                            JR      when opcode = "000000" and funct = "001000" else
                            JAL     when opcode = "000011" else                         
                            LUI     when opcode = "001111" and rs = "00000" else
                            INVALID_INSTRUCTION ;    -- Invalid or not implemented instruction
            
    assert not (decodedInstruction = INVALID_INSTRUCTION and reset = '0')    
    report "******************* INVALID INSTRUCTION *************"
    severity error;    
    

    -- incrementedPC points the next instruction address
    -- ADDER above the PC register (datapath diagram)
    ADDER_PC: incrementedPC <= pc + 4;
    
    -- Register PC --
    REG_PC: process(clock,reset)
    begin
        if reset = '1' then
            pc <= TO_UNSIGNED(PC_START_ADDRESS,32);
        
        elsif rising_edge(clock) then
            pc <= inPC;
        end if;
    end process;
    
    -- Instruction memory is addressed by the PC register
    instructionAddress <= STD_LOGIC_VECTOR(pc);
    
    
    
    -- Selects the instruction field witch contains the register to be written
    -- In R-type instructions the destination register is in the 'rd' field
    -- MUX at the register file input (datapath diagram)
    MUX_RF: writeRegister <= rd when opcode = "000000" else 
                             "11111" when decodedInstruction = JAL else    -- $ra (31)
                             rt;
    
    
    -- Sign extends the low 16 bits of instruction
    -- Below the register file (datapath diagram)
    SIGN_EX: signExtend <= x"FFFF" & instruction(15 downto 0) when instruction(15) = '1' else 
                           x"0000" & instruction(15 downto 0);
                           
    -- Zero extends the low 16 bits of instruction 
    -- Not present in datapath diagram
    ZERO_EX: zeroExtended <= x"0000" & instruction(15 downto 0);
                                
    -- Converts the branch offset from words to bytes (multiply by 4) 
    -- Hardware at the second Branch ADDER input (datapath diagram)
    SHIFT_L: branchOffset <= UNSIGNED(signExtend(29 downto 0) & "00");
    
    
    -- Branch target address
    -- Branch ADDER above the ALU (datapath diagram)
    ADDER_BRANCH: branchTarget <= incrementedPC + branchOffset;
      
      
    -- MUX which selects the PC value
    -- Top right MUXes(datapath diagram)
    MUX_PC: inPC <= branchTarget when decodedInstruction = BEQ and zero = '1' else 
            (incrementedPC(31 downto 28) & UNSIGNED(instruction(25 downto 0)) & TO_UNSIGNED(0,2)) when decodedInstruction = J or decodedInstruction = JAL else
            ALUoperand1 when decodedInstruction = JR else
            incrementedPC;
            
    

    
    
    
    -------------------------------
    -- Behavioural register file --
    -------------------------------
    readData2 <= registerFile(TO_INTEGER(UNSIGNED(rt)));
         
    -- Selects the data to be written in the register file
    -- In load instructions the data comes from the data memory
    -- MUX at the data memory output
    MUX_DATA_MEM: writeData <= UNSIGNED(data_i) when decodedInstruction = LW else 
                               incrementedPC when decodedInstruction = JAL else
                               result;
    
    -- R-type instructions, ADDIU, ORI and load store the result in the register file
    RegWrite <= '1' when opcode = "000000" or decodedInstruction = LW or decodedInstruction = ADDIU or decodedInstruction = ORI or decodedInstruction = LUI or decodedInstruction = JAL else '0';
    
    -- Register $0 is read-only (constant 0)
    REGISTER_FILE: process(clock, reset)
    begin
    
        if reset = '1' then
            for i in 0 to 31 loop   
                registerFile(i) <= (others=>'0');  
            end loop;
               
        elsif rising_edge(clock) then
            if RegWrite = '1' and UNSIGNED(writeRegister) /= 0 then
                registerFile(TO_INTEGER(UNSIGNED(writeRegister))) <= writeData;
            end if;
        end if;
    end process;
    
    
    
    
    
    -- The first ALU operand always comes from the register file
    ALUoperand1 <= registerFile(TO_INTEGER(UNSIGNED(rs)));
    
    -- Selects the second ALU operand
    -- In R-type instructions or BEQ, the second ALU operand comes from the register file
    -- In ORI instruction the second ALU operand is zeroExtended
    -- MUX at the ALU input
    MUX_ALU: ALUoperand2 <= readData2 when opcode = "000000" or decodedInstruction = BEQ else 
                            UNSIGNED(zeroExtended) when decodedInstruction = ORI else
                            UNSIGNED(signExtend);
    
    ---------------------
    -- Behavioural ALU --
    ---------------------
    result <=   ALUoperand1 - ALUoperand2 when decodedInstruction = SUBU or decodedInstruction = BEQ else
                ALUoperand1 and ALUoperand2    when decodedInstruction = AAND     else 
                ALUoperand1 or  ALUoperand2    when decodedInstruction = OOR or decodedInstruction = ORI else 
                (0=>'1', others=>'0') when decodedInstruction = SLT and ALUoperand1 < ALUoperand2 else
                ALUoperand2(15 downto 0) & x"0000" when decodedInstruction = LUI else
                (others=>'0') when decodedInstruction = SLT and not (ALUoperand1 < ALUoperand2) else
                ALUoperand1 + ALUoperand2;    -- default for ADDU, ADDIU, SW, LW   


    -- Generates the zero flag
    zero <= '1' when result = 0 else '0';
      


      
    ---------------------------
    -- Data memory interface --
    ---------------------------
    
    -- ALU output address the data memory
    dataAddress <= STD_LOGIC_VECTOR(result);
    
    -- Data to data memory comes from the second read register at register file
    data_o <= STD_LOGIC_VECTOR(readData2);
    
    MemWrite <= '1' when decodedInstruction = SW else '0';
    
    ce <= '1' when decodedInstruction = SW or decodedInstruction = LW else '0';
    
end behavioral;