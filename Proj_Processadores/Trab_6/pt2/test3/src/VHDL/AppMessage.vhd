-------------------------------------------------------------------------
-- Design unit: CryptoMessage
-- Description: 
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity AppMessage is
    generic (
        FILE_NAME       : string := "UNUSED"
    );
    port ( 
        clk          : in std_logic;
        rst          : in std_logic;
        ack          : in std_logic;
        start_signal : in std_logic;
        data_out     : out std_logic_vector(7 downto 0);
        data_av      : out std_logic;
        eom          : out std_logic
    );
end AppMessage;

architecture behavioral of AppMessage is
    
    type State is (WAIT_SIGNAL, GET_LINE, GET_CHAR, SEND_CHAR, CHAR_ACK, SIGNAL_DATA_AV, CYCLE_DELAY, END_DELAY, END_OF_FILE);
    signal currentState : State;
    signal lineLength   : integer;
    signal currentByte  : integer;
    signal num1, num2   : UNSIGNED(7 downto 0);
    signal counter      : integer;
    signal MSG_INTERVAL : integer;

begin

    assert FILE_NAME /= "UNUSED"
    report "********************* entity AppMessage: missing FILE_NAME *********************"
    severity failure;
    
    data_av <= '1' when currentState = SIGNAL_DATA_AV else '0'; -- signals that a char was sent
    eom <= '1' when (currentState = END_OF_FILE) else '0'; -- signals that all the chars of a line were sent
    
    process(clk,rst)
        file messageFile          : TEXT open READ_MODE is FILE_NAME;
        variable fileLine         : line; -- Stores a read line from a text file
        variable char1            : character; -- Stores a single character
        variable char2            : character; -- Stores a single character
        variable readOK1          : boolean; -- When false indicates end of line
        variable readOK2          : boolean; -- When false indicates end of line
    begin
        if rst = '1' then
            currentState <= WAIT_SIGNAL;
            currentByte  <= 0;
            counter      <= 0;
            MSG_INTERVAL <= 10; 
            data_out <= "00000000";
            num1     <= "00000000";
            num2     <= "00000000";
            
        elsif rising_edge(clk) then

            case currentState is

                when WAIT_SIGNAL =>
                    if start_signal = '1' then
                        currentState <= GET_LINE;
                    else
                        currentState <= WAIT_SIGNAL;
                    end if;
                
                -- Get Line
                when GET_LINE =>
                     if not endfile(messageFile) then                           
                        readline(messageFile, fileLine); -- Read a file line into 'fileLine'. Each line is a message.
                        lineLength <= fileLine'length; -- Set the line number of characters    
                        currentState <= GET_CHAR;
                    else
                        currentState <= END_DELAY;
                    end if;                        
                
                -- Encrypt a character
                when GET_CHAR =>
                        
                    -- Read a character from the line
                    read(fileLine, char1, readOK1);

                    -- Read a character from the line
                    read(fileLine, char2, readOK2);

                    lineLength <= lineLength - 2;

                    currentState <= CYCLE_DELAY;

                when CYCLE_DELAY =>

                        if character'pos(char1) < 58 then
                            num1 <= TO_UNSIGNED(character'pos(char1) - 48,8);
                        else
                            num1 <= TO_UNSIGNED(character'pos(char1) - 87,8);
                        end if;

                        if character'pos(char2) < 58 then
                            num2 <= TO_UNSIGNED(character'pos(char2) - 48,8);
                        else
                            num2 <= TO_UNSIGNED(character'pos(char2) - 87,8);
                        end if;

                    if counter = MSG_INTERVAL then
                        counter <= 0; 
                        currentState <= SEND_CHAR;                     
                    else
                        counter <= counter + 1;
                        currentState <= CYCLE_DELAY;
                    end if;
                
                when SEND_CHAR =>

                  data_out <= STD_LOGIC_VECTOR( (num1 sll 4) + num2);
                	currentState <= SIGNAL_DATA_AV;

                when SIGNAL_DATA_AV =>

                    currentState <= CHAR_ACK;

                -- Wait for receiver read
                when CHAR_ACK =>

                    if ack = '1' and lineLength /= 0 then
                        currentState <= GET_CHAR;
                    elsif ack = '1' and lineLength = 0 then
                        currentState <= GET_LINE;
                    else
                        currentState <= CHAR_ACK;
                    end if;

                when END_DELAY =>
                    if counter = 20 then
                        counter <= 0; 
                        currentState <= END_OF_FILE;                     
                    else
                        counter <= counter + 1;
                        currentState <= END_DELAY;
                    end if;
                
                -- End of file. All messages were send.
                when END_OF_FILE =>
                    currentState <= END_OF_FILE;

                when others=>

            end case;
        end if;
    end process;
    
end behavioral;