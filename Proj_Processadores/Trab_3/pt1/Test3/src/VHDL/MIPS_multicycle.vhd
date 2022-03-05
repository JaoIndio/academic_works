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

      -- interrupt signals and valus
    signal Kernel_add : UNSIGNED(31 downto 0) := x"00400060";
    signal busy       : std_logic;
    signal interrupt  : std_logic;


    signal pc, readData1, readData2, writeData, EPC: UNSIGNED(31 downto 0);
    signal signExtend, zeroExtended : std_logic_vector(31 downto 0);
    signal ALUoperand1, ALUoperand2, result: UNSIGNED(31 downto 0);
    signal branchOffset, inPC: UNSIGNED(31 downto 0);
    signal writeRegister   : std_logic_vector(4 downto 0);
    signal RegWrite : std_logic;

    -- state identifies the step of execution of an instruction in which the processor currently is
    type state is (FETCH, DECODE, EXECUTE, MEMORY, WRITEBACK);
    signal currentState: state;

    -- registers of the data path
    signal MDR, A, B, ALUOut: UNSIGNED(31 downto 0);
    signal instruction_reg : std_logic_vector(31 downto 0);
    
    -- inst_type defines the instructions decodable by the control unit
    type Instruction_type is (ERET, ADDU, SUBU, AAND, OOR, SW, LW, ADDIU, ORI, SLT, BEQ, J, JR, JAL, JALR, LUI, INVALID_INSTRUCTION, XXOR, NNOR, SSLL, SSRL, BNE, XORI, ANDI, SLTI, SLTU, SLTIU, BGEZ, BLEZ, BLTZ, BGTZ);
    
    -- Register file
    type RegisterArray is array (natural range <>) of UNSIGNED(31 downto 0);
    signal registerFile: RegisterArray(0 to 31);
    
    -- Retrieves the rs field from the instruction
    alias rs: std_logic_vector(4 downto 0) is instruction_reg(25 downto 21);
        
    -- Retrieves the rt field from the instruction
    alias rt: std_logic_vector(4 downto 0) is instruction_reg(20 downto 16);
        
    -- Retrieves the rd field from the instruction
    alias rd: std_logic_vector(4 downto 0) is instruction_reg(15 downto 11);
    
    -- ALU zero flag
    signal zero : std_logic;

    -- ALU negative flag
    signal negative : std_logic;
     
    -- Alias to identify the instructions based on the 'opcode' and 'funct' fields
    alias  opcode: std_logic_vector(5 downto 0) is instruction_reg(31 downto 26);
    alias  funct: std_logic_vector(5 downto 0) is instruction_reg(5 downto 0);
    alias  shamt: std_logic_vector(4 downto 0) is instruction_reg(10 downto 6);
    
    signal decodedInstruction: Instruction_type;
    
    
        
begin

    -- Instruction decoding
    decodedInstruction <=   ERET    when opcode = "010000" and funct = "011000" else
      
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
                               ALUOut;

    -- Selects the instruction field witch contains the register to be written
    -- In R-type instructions the destination register is in the 'rd' field
    -- MUX at the register file input (datapath diagram)
    MUX_RF: writeRegister <= rd when opcode = "000000" else 
                             "11111" when decodedInstruction = JAL else    -- $ra (31)
                             rt;
    
    -- R-type instructions, ADDIU, ORI and load store the result in the register file
    RegWrite <= '1' when currentState = WRITEBACK or (currentState = MEMORY and ( opcode = "000000" or decodedInstruction = ADDIU or decodedInstruction = LUI or decodedInstruction = SLTI or decodedInstruction = SLTIU or decodedInstruction = JAL or decodedInstruction = ANDI or decodedInstruction = XORI or decodedInstruction = ORI)) else
                '0';


    -------------------------------
    --     PC input control      --
    -------------------------------

    MUX_PC: inPC <= Kernel_add when interrupt = '1' and busy = '1' and currentState = FETCH else -- Interrupt. Jump to kernel position in memory
                    result when currentState = FETCH else
                    EPC when decodedInstruction = ERET else
                    A when decodedInstruction = JALR or decodedInstruction = JR else
                    ALUOut when currentState = EXECUTE and (decodedInstruction = BEQ or decodedInstruction = BNE or decodedInstruction = BGTZ or decodedInstruction = BLTZ or decodedInstruction = BGEZ or decodedInstruction = BLEZ) else
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

            elsif currentState = DECODE then

                    -- RegisterFile read (in A and B)
                    -- Instruction Decode
                    -- Branch Adress Calculus (stored in ALUout)

                    if ( ( busy = '0' ) and ( irq = '1' ) )then
                      interrupt <= '1';
                      busy <= '1';
                    end if;

                    A <= readData1;
                    B <= readData2;
                    ALUOut <= result;
                    currentState <= EXECUTE;

            elsif currentState = EXECUTE then

                -- if R-type instruction: execution
                -- if L/S instrucion: data memory address calculus
                -- if branch instruction: condition calculus and PC update (if condition attended)
                -- if jump intruction: PC update
                -- if JAL or JALR: ALUout <= PC and PC update

                if ( ( busy = '0' ) and ( irq = '1' ) )then
                    interrupt <= '1';
                    busy <= '1';
                end if;

                ALUOut <= result;
                
                -- If interrupt routine finished, the processor is not busy with it anymore
                if (decodedInstruction = ERET) then
                  busy <= '0';
                end if;

                if (decodedInstruction = ERET or decodedInstruction = J or decodedInstruction = JAL or decodedInstruction = JR or decodedInstruction = JALR) or (decodedInstruction = BEQ and zero = '1') or (decodedInstruction = BNE and zero = '0') or (decodedInstruction = BGEZ and negative = '0') or (decodedInstruction = BLEZ and (negative = '1' or zero = '1')) or (decodedInstruction = BLTZ and negative = '1') or (decodedInstruction = BGTZ and (negative = '0' and zero = '0')) then
                    pc <= inPC;
                end if;

                if (decodedInstruction = ERET or decodedInstruction = J or decodedInstruction = JR or decodedInstruction = BEQ or decodedInstruction = BNE or decodedInstruction = BGTZ or decodedInstruction = BLTZ or decodedInstruction = BGEZ or decodedInstruction = BLEZ)   then
                    currentState <= FETCH;
                else
                    currentState <= MEMORY;
                end if;

            elsif currentState = MEMORY then

                    -- if R-type instruction: write result on RegisterFile
                    -- if SW: Store B on memory
                    -- if LW: MDR receives data from memory
                    -- if JAL or JALR: store link adrres on RegisterFile

                    if ( ( busy = '0' ) and ( irq = '1' ) )then
                      interrupt <= '1';
                      busy <= '1';
                    end if;


                    MDR <= UNSIGNED(data_i);

                    if RegWrite = '1'  and UNSIGNED(writeRegister) /= 0 then
                        registerFile(TO_INTEGER(UNSIGNED(writeRegister))) <= writeData;
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

    readData1 <= registerFile(TO_INTEGER(UNSIGNED(rt))) when decodedInstruction = SSLL or decodedInstruction = SSRL else 
                 registerFile(TO_INTEGER(UNSIGNED(rs)));

    readData2 <= registerFile(TO_INTEGER(UNSIGNED(rt)));

    -- The first ALU operand either comes from the RegisterFile or pc
    MUX_ALU_OP1: ALUoperand1 <= A when currentState = EXECUTE and decodedInstruction /= JAL  and decodedInstruction /= JALR else
                                pc;

    MUX_ALU_OP2: ALUoperand2 <= TO_UNSIGNED(4,32) when currentState = FETCH else -- for PC++
                                branchOffset when (currentState = DECODE) and (decodedInstruction = BEQ or decodedInstruction = BNE or decodedInstruction = BGTZ or decodedInstruction = BLTZ or decodedInstruction = BGEZ or decodedInstruction = BLEZ) else
                                TO_UNSIGNED(0,27) & UNSIGNED(shamt) when decodedInstruction = SSLL or decodedInstruction = SSRL else
                                TO_UNSIGNED(0,32) when decodedInstruction = JAL or decodedInstruction = JALR else
                                B when (currentState = EXECUTE and (decodedInstruction = BEQ or decodedInstruction = BNE or decodedInstruction = BGTZ or decodedInstruction = BLTZ or decodedInstruction = BGEZ or decodedInstruction = BLEZ or opcode = "000000" or decodedInstruction = JAL)) else
                                UNSIGNED(zeroExtended) when decodedInstruction = XORI or decodedInstruction = ANDI or decodedInstruction = ORI else
                                UNSIGNED(signExtend); --  LW,  SW, LUI, ADDIU, SLT, SLTU, SLTI, SLTIU


    result <=   ALUoperand1 + ALUoperand2 when currentState = FETCH or currentState = DECODE else
                ALUoperand1 - ALUoperand2 when decodedInstruction = SUBU or decodedInstruction = BEQ or decodedInstruction = BNE else
                ALUoperand1 when decodedInstruction = BGTZ or decodedInstruction = BLTZ or decodedInstruction = BGEZ or decodedInstruction = BLEZ else
                
                ALUoperand1 xor ALUoperand2 when decodedInstruction = XXOR or decodedInstruction = XORI else
                ALUoperand1 or  ALUoperand2 when decodedInstruction = OOR or decodedInstruction = ORI else 
                ALUoperand1 and ALUoperand2 when decodedInstruction = ANDI or decodedInstruction = AAND  else
                ALUoperand1 nor ALUoperand2 when decodedInstruction = NNOR  else  
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

                ALUoperand1 + ALUoperand2;    -- default for ADDU, ADDIU, SW, LW  

    -- Generates the zero flag
    zero <= '1' when result = 0 else '0';

    -- generates the negative flag
    negative <= '1' when result(31) = '1' else '0';



    ---------------------------
    -- Data memory interface --
    ---------------------------

    -- ALU output address the data memory
    dataAddress <= STD_LOGIC_VECTOR(ALUOut);

    -- Instruction memory is addressed by the PC register
    instructionAddress <= STD_LOGIC_VECTOR(pc);
    
    -- Data to data memory comes from the B register
    data_o <= STD_LOGIC_VECTOR(B);

    -- Only SW stores on memory, in the MEMORY stage
    MemWrite <= '1' when (decodedInstruction = SW) and (currentState = MEMORY) else '0';
    
    -- chip enable
    ce <= '1' when (currentState = MEMORY or currentState = WRITEBACK) and (decodedInstruction = SW or decodedInstruction = LW) else '0';    

end behavioral;

