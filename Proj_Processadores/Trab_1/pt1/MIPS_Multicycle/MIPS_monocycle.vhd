-------------------------------------------------------------------------
-- Design unit: MIPS monocycle
-- Description: Control and data paths port map
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.MIPS_package.all;

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

architecture structural of MIPS_monocycle is
    
    signal uins: Microinstruction;

begin

     CONTROL_PATH: entity work.ControlPath(behavioral)
         port map (
             clock          => clock,
             reset          => reset,
             instruction    => instruction,
             uins           => uins
         );
         
         
     DATA_PATH: entity work.DataPath(structural)
         generic map (
            PC_START_ADDRESS => PC_START_ADDRESS
         )
         port map (
            clock               => clock,
            reset               => reset,
            
            uins                => uins,
             
            instructionAddress  => instructionAddress,
            instruction         => instruction,
             
            dataAddress         => dataAddress,
            data_i              => data_i,
            data_o              => data_o
         );
     
     MemWrite <= uins.MemWrite;
     
end structural;

architecture behavioral of MIPS_monocycle is

    signal incrementedPC, pc, readData2, writeData: UNSIGNED(31 downto 0);
    signal signExtend, zeroExtended : std_logic_vector(31 downto 0);
    signal ALUoperand1, ALUoperand2, result: UNSIGNED(31 downto 0);
    signal branchOffset, branchTarget, inPC: UNSIGNED(31 downto 0);
    signal writeRegister   : std_logic_vector(4 downto 0);
    signal RegWrite : std_logic;
    
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
    signal negative : std_logic;
     
    -- Alias to identify the instructions based on the 'opcode' and 'funct' fields
    alias  opcode: std_logic_vector(5 downto 0) is instruction(31 downto 26);
    alias  funct: std_logic_vector(5 downto 0) is instruction(5 downto 0);
    alias  shamt: std_logic_vector(4 downto 0) is instruction(10 downto 6);
    
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

                            XXOR    when opcode = "000000" and funct = "100110" else
                            NNOR    when opcode = "000000" and funct = "100111" else
                            SSLL    when opcode = "000000" and funct = "000000" else
                            SSRL    when opcode = "000000" and funct = "000010" else
                            BNE     when opcode = "000101" else
                            XORI    when opcode = "001110" else
                            ANDI    when opcode = "001100" else
                            SLTI    when opcode = "001010" else
                            SLTIU   when opcode = "001011" else
                            SLTU    when opcode = "000000" and funct = "101011" else
                            BGEZ    when opcode = "000001" and rt = "00001" else
                            BLEZ    when opcode = "000110" and rt = "00000" else
                            BLTZ    when opcode = "000001" and rt = "00000" else
                            BGTZ    when opcode = "000111" else
                            JAL     when opcode = "000011" else
                            JALR    when opcode = "000000" and funct = "001001" else
                            JR      when opcode = "000000" and funct = "001000" else

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
    MUX_RF: writeRegister <= rd when opcode = "000000" else rt;
    
    
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
    MUX_PC: inPC <= branchTarget when (decodedInstruction = BEQ and zero = '1') or (decodedInstruction = BNE and zero = '0') or (decodedInstruction = BGEZ and negative = '0') or (decodedInstruction = BLEZ and (negative = '1' or zero = '1')) or (decodedInstruction = BLTZ and negative = '1') or (decodedInstruction = BGTZ and (negative = '0' and zero = '0')) else 
            (incrementedPC(31 downto 28) & UNSIGNED(instruction(25 downto 0)) & TO_UNSIGNED(0,2)) when decodedInstruction = J or decodedInstruction = JAL else
            registerFile(TO_INTEGER(UNSIGNED(rs))) when decodedInstruction = JALR or decodedInstruction = JR else
            incrementedPC;

    -------------------------------
    -- Behavioural register file --
    -------------------------------
    readData2 <= registerFile(TO_INTEGER(UNSIGNED(rt)));
         
    -- Selects the data to be written in the register file
    -- In load instructions the data comes from the data memory
    -- MUX at the data memory output
    MUX_DATA_MEM: writeData <= UNSIGNED(data_i) when decodedInstruction = LW else result;
    
    -- R-type instructions, ADDIU, ORI and load store the result in the register file
    RegWrite <= '1' when opcode = "000000" or decodedInstruction = LW or decodedInstruction = ADDIU or decodedInstruction = ORI or decodedInstruction = LUI or decodedInstruction = SLTI or decodedInstruction = SLTIU or decodedInstruction = JAL or decodedInstruction = JALR or decodedInstruction = ANDI or decodedInstruction = XORI else '0';
    
    -- Register $0 is read-only (constant 0)
    REGISTER_FILE: process(clock, reset)
    begin
    
        if reset = '1' then
            for i in 0 to 31 loop   
                registerFile(i) <= (others=>'0');  
            end loop;
               
        elsif rising_edge(clock) then
            if RegWrite = '1' and UNSIGNED(writeRegister) /= 0 then
                if decodedInstruction = JAL then 
                    registerFile(31) <= incrementedPC; 
                elsif decodedInstruction = JALR then 
                    registerFile(TO_INTEGER(UNSIGNED(rd))) <= incrementedPC; 
        else
            registerFile(TO_INTEGER(UNSIGNED(writeRegister))) <= writeData;
                end if;
            end if;
        end if;
    end process;
    
    
    
    
    
    -- The first ALU operand always comes from the register file
    ALUoperand1 <= registerFile(TO_INTEGER(UNSIGNED(rt))) when decodedInstruction = SSLL or decodedInstruction = SSRL else 
                   registerFile(TO_INTEGER(UNSIGNED(rs)));
    
    -- Selects the second ALU operand
    -- In R-type instructions or BEQ, the second ALU operand comes from the register file
    -- In ORI instruction the second ALU operand is zeroExtended
    -- MUX at the ALU input
    MUX_ALU: ALUoperand2 <= TO_UNSIGNED(0,27) & UNSIGNED(shamt) when decodedInstruction = SSLL or decodedInstruction = SSRL else
                            readData2 when opcode = "000000" or decodedInstruction = BEQ or decodedInstruction = BNE else 
                            UNSIGNED(zeroExtended) when decodedInstruction = ORI or decodedInstruction = XORI or decodedInstruction = ANDI else -- adicionei XORI e ANDI
                            UNSIGNED(signExtend);
    
    ---------------------
    -- Behavioural ALU --
    ---------------------
    result <=   ALUoperand1 -   ALUoperand2 when decodedInstruction = SUBU  or decodedInstruction = BEQ or decodedInstruction = BNE else
                ALUoperand1 and ALUoperand2 when decodedInstruction = AAND  else 
                ALUoperand1 or  ALUoperand2 when decodedInstruction = OOR   or decodedInstruction = ORI else 
                ALUoperand1 xor ALUoperand2 when decodedInstruction = XXOR  else 
                ALUoperand1 xor ALUoperand2 when decodedInstruction = XORI  else 
                ALUoperand1 nor ALUoperand2 when decodedInstruction = NNOR  else 
                ALUoperand1 and ALUoperand2 when decodedInstruction = ANDI  else 
                ALUoperand1 sll TO_INTEGER(ALUoperand2) when decodedInstruction = SSLL  else 
                ALUoperand1 srl TO_INTEGER(ALUoperand2) when decodedInstruction = SSRL  else 
                ALUoperand2(15 downto 0) & x"0000" when decodedInstruction = LUI else

                (0=>'1', others=>'0') when decodedInstruction = SLT and (SIGNED(ALUoperand1) < SIGNED(ALUoperand2)) else
                (others=>'0') when decodedInstruction = SLT and not (SIGNED(ALUoperand1) < SIGNED(ALUoperand2)) else

                (0=>'1', others=>'0') when decodedInstruction = SLTU and ALUoperand1 < ALUoperand2 else
                (others=>'0') when decodedInstruction = SLTU and not (ALUoperand1 < ALUoperand2) else

                (0=>'1', others=>'0') when decodedInstruction = SLTI and (SIGNED(ALUoperand1) < SIGNED(ALUoperand2)) else
                (others=>'0') when decodedInstruction = SLTI and not (SIGNED(ALUoperand1) < SIGNED(ALUoperand2)) else

                (0=>'1', others=>'0') when decodedInstruction = SLTIU and (ALUoperand1 < ALUoperand2) else
                (others=>'0') when decodedInstruction = SLTIU and not (ALUoperand1 < ALUoperand2) else

                ALUoperand1 when decodedInstruction = BGEZ or decodedInstruction = BLEZ or decodedInstruction = BLTZ or decodedInstruction = BGTZ else

                ALUoperand1 + ALUoperand2;    -- default for ADDU, ADDIU, SW, LW   


    -- Generates the zero flag
    zero <= '1' when result = 0 else '0';
    negative <= '1' when result(31) = '1' else '0';
        
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