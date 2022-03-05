-------------------------------------------------------------------------
-- Design unit: MIPS multicycle
-- Description: Control and data paths port map
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MIPS_multicycle is
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
        MemWrite            : out std_logic;

        -- interrupts
        irq                 : in std_logic
    );
end MIPS_multicycle;

architecture behavioral of MIPS_multicycle is

    -- interrupt signals
    signal ISR_ADDR                 : UNSIGNED(31 downto 0);
    signal interrupt                : std_logic;

    -- trap signals
    signal ESR_ADDR                 : UNSIGNED(31 downto 0);
    signal CAUSE                    : UNSIGNED(31 downto 0);

    -- exception signals
    signal exception                : std_logic;
    signal overflow                 : std_logic;
    signal invalidInstruction       : std_logic;
    signal divZero                  : std_logic;

    -- indicates if processor is busy, on kernel
    signal busy                     : std_logic;

    -- ULA signals 
    signal readData1, readData2     : UNSIGNED(31 downto 0);
    signal ALUoperand1, ALUoperand2 : UNSIGNED(31 downto 0);
    signal branchOffset             : UNSIGNED(31 downto 0);
    signal signExtend, zeroExtended : std_logic_vector(31 downto 0);

    -- ALU result and flags
    signal result                   : UNSIGNED(63 downto 0);
    signal zero                     : std_logic;
    signal negative                 : std_logic;

    -- state identifies the step of execution of an instruction in which the processor currently is
    type state is (FETCH, DECODE, EXECUTE, MEMORY, WRITEBACK);
    signal currentState: state;

    -- PC signals
    signal pc   : UNSIGNED(31 downto 0);
    signal inPC : UNSIGNED(31 downto 0);
    signal EPC  : UNSIGNED(31 downto 0);

    -- registers of the data path
    signal MDR, A, B       : UNSIGNED(31 downto 0);
    signal instruction_reg : std_logic_vector(31 downto 0);
    signal ALUOut          : UNSIGNED(63 downto 0);

    -- Special Registers
    signal hi, lo : UNSIGNED(31 downto 0);
    
    -- inst_type defines the instructions decodable by the control unit
    type Instruction_type is (SYSCALL, ADD, ADDI, SUB, MFC0, MTC0, ERET, MULTU, DIVU, MFHI, MFLO, ADDU, SUBU, AAND, OOR, SW, LW, ADDIU, ORI, SLT, BEQ, J, JR, JAL, JALR, LUI, INVALID_INSTRUCTION, XXOR, NNOR, SSLL, SSRL, BNE, XORI, ANDI, SLTI, SLTU, SLTIU, BGEZ, BLEZ, BLTZ, BGTZ);
    
    -- Register file signals
    type RegisterArray is array (natural range <>) of UNSIGNED(31 downto 0);
    signal registerFile: RegisterArray(0 to 31);
    signal writeRegister                            : std_logic_vector(4 downto 0);
    signal writeData                                : UNSIGNED(31 downto 0);
    signal RegWrite                                 : std_logic;
    
    -- Retrieves the rs field from the instruction
    alias rs: std_logic_vector(4 downto 0) is instruction_reg(25 downto 21);
        
    -- Retrieves the rt field from the instruction
    alias rt: std_logic_vector(4 downto 0) is instruction_reg(20 downto 16);
        
    -- Retrieves the rd field from the instruction
    alias rd: std_logic_vector(4 downto 0) is instruction_reg(15 downto 11);
     
    -- Alias to identify the instructions based on the 'opcode' and 'funct' fields
    alias  opcode: std_logic_vector(5 downto 0) is instruction_reg(31 downto 26);
    alias  funct: std_logic_vector(5 downto 0) is instruction_reg(5 downto 0);
    alias  shamt: std_logic_vector(4 downto 0) is instruction_reg(10 downto 6);
    
    signal decodedInstruction: Instruction_type;
        
begin

    -- Instruction decoding
    decodedInstruction <=   SYSCALL when opcode = "000000" and funct = "001100" else

                            ADD     when opcode = "000000" and funct = "100000" else
                            SUB     when opcode = "000000" and funct = "100010" else
                            ADDI    when opcode = "001000" else

                          MFC0    when opcode = "010000" and rs = "00000" and instruction_reg(10 downto 0) = "00000000000" else   
                          MTC0    when opcode = "010000" and rs = "00100" and instruction_reg(10 downto 0) = "00000000000" else 

                            ERET    when opcode = "010000" and funct = "011000" else
      
                            MULTU   when opcode = "000000" and funct = "011001" else        
                            DIVU    when opcode = "000000" and funct = "011011" else
                            MFHI    when opcode = "000000" and funct = "010000" else
                            MFLO    when opcode = "000000" and funct = "010010" else

                            ADDU    when opcode = "000000" and funct = "100001" else
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
                            JALR    when opcode = "000000" and funct = "001001" else                         
                            LUI     when opcode = "001111" and rs = "00000" else

                            XXOR    when opcode = "000000" and funct = "100110" else
                            NNOR    when opcode = "000000" and funct = "100111" else
                            SSLL    when opcode = "000000" and funct = "000000" and instruction_reg(25 downto 6) /= "00000000000000000000" else
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
                            INVALID_INSTRUCTION ;    -- Invalid or not implemented instruction
            
    assert not (decodedInstruction = INVALID_INSTRUCTION and reset = '0')    
    report "******************* INVALID INSTRUCTION *************"
    severity error;

    -- Sign extends the low 16 bits of instruction
    -- Below the register file (datapath diagram)
    SIGN_EX: signExtend <= x"FFFF" & instruction_reg(15 downto 0) when instruction_reg(15) = '1' else 
                           x"0000" & instruction_reg(15 downto 0);

    -- Zero extends the low 16 bits of instruction 
    -- Not present in datapath diagram
    ZERO_EX: zeroExtended <= x"0000" & instruction_reg(15 downto 0);
                                
    -- Converts the branch offset from words to bytes (multiply by 4) 
    -- Hardware at the second Branch ADDER input (datapath diagram)
    SHIFT_L: branchOffset <= UNSIGNED(signExtend(29 downto 0) & "00");


    --------------------------------------
    -- Behavioural RegisterFile Control --
    --------------------------------------

    -- Selects the data to be written in the register file
    -- In load instructions the data comes from the data memory
    -- MUX at the data memory output
    MUX_DATA_MEM: writeData <= MDR when decodedInstruction = LW else
                               ALUOut(31 downto 0);

    -- Selects the instruction field witch contains the register to be written
    -- In R-type instructions the destination register is in the 'rd' field
    -- MUX at the register file input (datapath diagram)
    MUX_RF: writeRegister <= rd when opcode = "000000" or decodedInstruction = MTC0 else 
                             "11111" when decodedInstruction = JAL else    -- $ra (31)
                             rt;
    
    -- R-type instructions, ADDIU, ORI and load store the result in the register file
    RegWrite <= '1' when currentState = WRITEBACK or (currentState = MEMORY and ( opcode = "000000" or decodedInstruction = MFC0 or decodedInstruction = MTC0 or decodedInstruction = ADDIU or decodedInstruction = LUI or decodedInstruction = SLTI or decodedInstruction = SLTIU or decodedInstruction = JAL or decodedInstruction = ANDI or decodedInstruction = XORI or decodedInstruction = ORI)) else
                '0';


    -------------------------------
    --     PC input control      --
    -------------------------------

    MUX_PC: inPC <= ESR_ADDR when interrupt = '1' and busy = '1' and currentState = FETCH and CAUSE /= 0 else -- Internal Interrupt. Jump to ESR
                    ISR_ADDR when interrupt = '1' and busy = '1' and currentState = FETCH else                -- External Interrupt. Jump to ISR
                    result(31 downto 0) when currentState = FETCH else
                    EPC when decodedInstruction = ERET else
                    A when decodedInstruction = JALR or decodedInstruction = JR else
                    ALUOut(31 downto 0) when currentState = EXECUTE and (decodedInstruction = BEQ or decodedInstruction = BNE or decodedInstruction = BGTZ or decodedInstruction = BLTZ or decodedInstruction = BGEZ or decodedInstruction = BLEZ) else
                    (pc(31 downto 28) & UNSIGNED(instruction_reg(25 downto 0)) & TO_UNSIGNED(0,2)); -- when currentState = EXECUTE and (decodedInstruction = J or decodedInstruction = JAL)


    -------------------------------
    -- Behavioural State Machine --
    -------------------------------

    STATE_MACHINE: process(clock, reset)
    begin
    
        if reset = '1' then
            currentState <= FETCH;

            for i in 0 to 31 loop   
                registerFile(i) <= (others=>'0');  
            end loop;

            pc <= TO_UNSIGNED(PC_START_ADDRESS,32);

            CAUSE <= TO_UNSIGNED(0,32);

            busy <= '0';
            interrupt <= '0';
               
        elsif rising_edge(clock) then

            if currentState = FETCH then

                -- PC++
                -- instruction fetch
                -- interrupt detection

                pc <= inPC;
                instruction_reg <= instruction;

                -- If an interruption occours, jump to kernel and perform FETCH again to fetch the new instruction
                if interrupt = '1' and busy = '1' then
                    currentState <= FETCH;
                    EPC <= Pc;
                else
                    currentState <= DECODE;
                end if;

                --Only detect new interrupts if processor is not busy attending one
                if ( ( busy = '0' ) and ( irq = '1' ) )then
                    interrupt <= '1';
                    busy <= '1';
                else
                    interrupt <= '0';
                end if;

                -- Guarantees that division by zero does not happen 
                B <= TO_UNSIGNED(1,32);

            elsif currentState = DECODE then

                    -- RegisterFile read (in A and B)
                    -- Instruction Decode
                    -- Branch Adress Calculus (stored in ALUout)

                    if ( ( busy = '0' ) and ( irq = '1' ) )then
                      interrupt <= '1';
                      busy <= '1';
                    end if;

                    ALUOut <= result;
                    currentState <= EXECUTE;

                    A <= readData1;
                    if decodedInstruction = DIVU and readData2 = 0 then
                      B <= TO_UNSIGNED(1,32);
                    else
                      B <= readData2;
                    end if;

            elsif currentState = EXECUTE then

                -- if R-type instruction: execution
                -- if L/S instrucion: data memory address calculus
                -- if branch instruction: condition calculus and PC update (if condition attended)
                -- if jump intruction: PC update
                -- if JAL or JALR: ALUout <= PC and PC update

                ALUOut <= result;

                -- detects external and internal interrupts
                if ( ( busy = '0' ) and ( irq = '1' ) ) or (exception = '1') then
                    interrupt <= '1';
                    busy <= '1';
                end if;

                -- keeps the cause of interruption, if any occurred
                if invalidInstruction = '1' then
                    CAUSE <= TO_UNSIGNED(1,32);
                elsif overflow = '1' then
                    CAUSE <= TO_UNSIGNED(12,32);
                elsif divZero = '1' then 
                    CAUSE <= TO_UNSIGNED(15,32);
                elsif decodedInstruction = SYSCALL then
                    CAUSE <= TO_UNSIGNED(8,32);
                elsif decodedInstruction = ERET then
                    CAUSE <= TO_UNSIGNED(0,32);
                else
                    CAUSE <= CAUSE; -- external interrupt
                end if;
                
                -- If interrupt routine finished, the processor is not busy with it anymore
                if (decodedInstruction = ERET) then
                  busy <= '0';
                end if;

                -- if instruction performs a jump
                if (decodedInstruction = ERET or decodedInstruction = J or decodedInstruction = JAL or decodedInstruction = JR or decodedInstruction = JALR) or (decodedInstruction = BEQ and zero = '1') or (decodedInstruction = BNE and zero = '0') or (decodedInstruction = BGEZ and negative = '0') or (decodedInstruction = BLEZ and (negative = '1' or zero = '1')) or (decodedInstruction = BLTZ and negative = '1') or (decodedInstruction = BGTZ and (negative = '0' and zero = '0')) then
                    pc <= inPC;
                end if;

                if (exception = '1' or decodedInstruction = ERET or decodedInstruction = J or decodedInstruction = JR or decodedInstruction = BEQ or decodedInstruction = BNE or decodedInstruction = BGTZ or decodedInstruction = BLTZ or decodedInstruction = BGEZ or decodedInstruction = BLEZ)   then
                    currentState <= FETCH;
                else
                    currentState <= MEMORY;
                end if;

            elsif currentState = MEMORY then

                    -- if R-type instruction: write result on RegisterFile or Special Register
                    -- if SW: Store B on memory
                    -- if LW: MDR receives data from memory
                    -- if JAL or JALR: store link adrres on RegisterFile

                    -- keeps the loaded data from memory
                    MDR <= UNSIGNED(data_i);

                    -- External interrupt detection
                    if ( ( busy = '0' ) and ( irq = '1' ) )then
                      interrupt <= '1';
                      busy <= '1';
                    end if;

                    if RegWrite = '1' then 
                        
                        if decodedInstruction = MULTU or decodedInstruction = DIVU then
                            hi <= ALUOut(63 downto 32);
                            lo <= ALUOut(31 downto 0);
                        elsif decodedInstruction = MTC0 and TO_INTEGER(UNSIGNED(writeRegister)) = 31 then
                            ISR_ADDR <= writeData;
                        elsif decodedInstruction = MTC0 and TO_INTEGER(UNSIGNED(writeRegister)) = 30 then
                            ESR_ADDR <= writeData;
                        elsif decodedInstruction = MFC0 then
                            registerFile(TO_INTEGER(UNSIGNED(writeRegister))) <= writeData;
                        elsif UNSIGNED(writeRegister) /= 0 then
                            registerFile(TO_INTEGER(UNSIGNED(writeRegister))) <= writeData;
                        end if;

                    end if;

                    if decodedInstruction = LW then
                        currentState <= WRITEBACK;
                    else
                        currentState <= FETCH;
                    end if;

            else -- if currentState = WRITEBACK THEN

                    -- Store loaded word on RegisterFile

                    if RegWrite = '1' and UNSIGNED(writeRegister) /= 0 then
                        registerFile(TO_INTEGER(UNSIGNED(writeRegister))) <= writeData;
                    end if;
                    currentState <= FETCH;

            end if;

        end if;
    end process;


    ---------------------
    -- Behavioural ALU --
    ---------------------

    -- A register input
    readData1 <= registerFile(TO_INTEGER(UNSIGNED(rt))) when decodedInstruction = SSLL or decodedInstruction = SSRL else 
                 registerFile(TO_INTEGER(UNSIGNED(rs)));

    -- B register input
    readData2 <= registerFile(TO_INTEGER(UNSIGNED(rt)));

    -- The first ALU operand either comes from the RegisterFile or pc
    MUX_ALU_OP1: ALUoperand1 <= A when currentState = EXECUTE and decodedInstruction /= JAL  and decodedInstruction /= JALR else
                                pc;

    MUX_ALU_OP2: ALUoperand2 <= TO_UNSIGNED(4,32) when currentState = FETCH else -- for PC++

                                            -- calculating branch target 
                                branchOffset when (currentState = DECODE) and (decodedInstruction = BEQ or decodedInstruction = BNE or decodedInstruction = BGTZ or decodedInstruction = BLTZ or decodedInstruction = BGEZ or decodedInstruction = BLEZ) else

                                -- special registers or coprocessor registers
                                EPC when decodedInstruction =  MFC0 and TO_INTEGER(UNSIGNED(rd)) = 14 else
                                CAUSE when decodedInstruction = MFC0 and TO_INTEGER(UNSIGNED(rd)) = 13 else
                                ESR_ADDR when decodedInstruction = MFC0 and TO_INTEGER(UNSIGNED(rd)) = 30 else
                                hi when decodedInstruction = MFHI else
                                lo when decodedInstruction = MFLO else

                                -- jump and link instructions
                                TO_UNSIGNED(0,32) when decodedInstruction = JAL or decodedInstruction = JALR else

                                -- shift instructions
                                TO_UNSIGNED(0,27) & UNSIGNED(shamt) when decodedInstruction = SSLL or decodedInstruction = SSRL else

                                -- for R type instructions, MTC0, branch instructions
                                B when (opcode = "000000" or decodedInstruction = MTC0 or decodedInstruction = BEQ or decodedInstruction = BNE or decodedInstruction = BGTZ or decodedInstruction = BLTZ or decodedInstruction = BGEZ or decodedInstruction = BLEZ) else

                                -- for immediate logic operations
                                UNSIGNED(zeroExtended) when decodedInstruction = XORI or decodedInstruction = ANDI or decodedInstruction = ORI else

                                UNSIGNED(signExtend); --  LW,  SW, LUI, ADDIU, SLT, SLTU, SLTI, SLTIU
    

    result <=  x"00000000" & ALUoperand1 + ALUoperand2 when currentState = FETCH or currentState = DECODE else                            -- calculating branch target

               x"00000000" & ALUoperand2 when (decodedInstruction = MFC0 or decodedInstruction = MFLO or decodedInstruction = MFHI) else  -- when reading special register or coprocessor
               (ALUoperand1 mod ALUoperand2) & (ALUoperand1 / ALUoperand2) when decodedInstruction = DIVU and currentState = EXECUTE else -- DIVU
               ALUoperand1 * ALUoperand2 when decodedInstruction = MULTU else                                                             -- MULTU
               x"00000000" & (ALUoperand1 xor ALUoperand2) when decodedInstruction = XXOR or decodedInstruction = XORI else               -- logic XOR
               x"00000000" & (ALUoperand1 or  ALUoperand2) when decodedInstruction = OOR or decodedInstruction = ORI else                 -- logic OR
               x"00000000" & (ALUoperand1 and ALUoperand2) when decodedInstruction = ANDI or decodedInstruction = AAND  else              -- logic AND
               x"00000000" & (ALUoperand1 nor ALUoperand2) when decodedInstruction = NNOR  else                                           -- logic NOT
               x"00000000" & ALUoperand1 sll TO_INTEGER(ALUoperand2) when decodedInstruction = SSLL  else                                 -- shift left
               x"00000000" & ALUoperand1 srl TO_INTEGER(ALUoperand2) when decodedInstruction = SSRL  else                                 -- shift right
               x"00000000" & ALUoperand2(15 downto 0) & x"0000" when decodedInstruction = LUI else                                        -- Load Immediate

               -- SUB, SUBU and branch condition (BEQ and BNE)
               x"00000000" & (ALUoperand1 - ALUoperand2) when decodedInstruction = SUBU or decodedInstruction = SUB or decodedInstruction = BEQ or decodedInstruction = BNE else

               -- branch condition (other types of branches)
               x"00000000" & ALUoperand1 when decodedInstruction = BGTZ or decodedInstruction = BLTZ or decodedInstruction = BGEZ or decodedInstruction = BLEZ else

               -- set less than
               (0=>'1', others=>'0') when decodedInstruction = SLT and (SIGNED(ALUoperand1) < SIGNED(ALUoperand2)) else
               (others=>'0') when decodedInstruction = SLT and not (SIGNED(ALUoperand1) < SIGNED(ALUoperand2)) else

               (0=>'1', others=>'0') when decodedInstruction = SLTU and ALUoperand1 < ALUoperand2 else
               (others=>'0') when decodedInstruction = SLTU and not (ALUoperand1 < ALUoperand2) else
 
               (0=>'1', others=>'0') when decodedInstruction = SLTI and (SIGNED(ALUoperand1) < SIGNED(ALUoperand2)) else
               (others=>'0') when decodedInstruction = SLTI and not (SIGNED(ALUoperand1) < SIGNED(ALUoperand2)) else

               (0=>'1', others=>'0') when decodedInstruction = SLTIU and (ALUoperand1 < ALUoperand2) else
               (others=>'0') when decodedInstruction = SLTIU and not (ALUoperand1 < ALUoperand2) else

               -- default for ADDU, ADDIU, ADD, ADDI, SW, LW, ect
               x"00000000" & ALUoperand1 + ALUoperand2;  

    ---------------------
    -- Auxiliary Flags --
    ---------------------

    -- Generates the zero flag
    zero <= '1' when result = 0 else '0';

    -- generates the negative flag
    negative <= '1' when result(31) = '1' and decodedInstruction /= MULTU else 
    '1' when result(63) = '1' and decodedInstruction = MULTU else
    '0';

    -- detects division by zero
    divZero <= '1' when decodedInstruction = DIVU and readData2 = 0 and currentState = EXECUTE else '0';

    -- detects overflow for ADD, ADDI and SUB instructions
    overflow <= '1' when ( (result(31) = '1' and ALUoperand1(31) = '0' and ALUoperand2(31) = '0') or (result(31) = '0' and ALUoperand1(31) = '1' and ALUoperand2(31) = '1') ) and ( decodedInstruction = ADD or decodedInstruction = ADDI) and (currentState = EXECUTE) else 
                '1' when ( (result(31) = '0' and ALUoperand1(31) = '1' and ALUoperand2(31) = '0') or (result(31) = '1' and ALUoperand1(31) = '0' and ALUoperand2(31) = '1') ) and (decodedInstruction = SUB) and (currentState = EXECUTE) else
                '0';

    -- detects invalid instructions
    invalidInstruction <= '1' when decodedInstruction = INVALID_INSTRUCTION and currentState = EXECUTE else '0';

    -- exception detection
    exception <= '1' when divZero = '1' or overflow = '1' or invalidInstruction = '1' or decodedInstruction = SYSCALL else '0';

    ---------------------------
    -- Data memory interface --
    ---------------------------

    -- ALU output address the data memory
    dataAddress <= STD_LOGIC_VECTOR(ALUOut(31 downto 0));

    -- Instruction memory is addressed by the PC register
    instructionAddress <= STD_LOGIC_VECTOR(pc);
    
    -- Data to data memory comes from the B register
    data_o <= STD_LOGIC_VECTOR(B);

    -- Only SW stores on memory, in the MEMORY stage
    MemWrite <= '1' when (decodedInstruction = SW) and (currentState = MEMORY) else '0';
    
    -- chip enable
    ce <= '1' when (currentState = MEMORY or currentState = WRITEBACK) and (decodedInstruction = SW or decodedInstruction = LW) else '0';    

end behavioral;

