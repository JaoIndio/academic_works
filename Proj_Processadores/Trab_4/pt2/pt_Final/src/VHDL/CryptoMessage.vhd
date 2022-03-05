-------------------------------------------------------------------------
-- Design unit: CryptoMessage
-- Description: 
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity CryptoMessage is
    generic (
        MSG_INTERVAL    : integer;    -- Clock cycles
        FILE_NAME       : string := "UNUSED";
        PUBLIC_KEY      : std_logic_vector(31 downto 0);
        N               : integer
    );
    port ( 
        clk         : in std_logic;
        rst         : in std_logic;
        ack         : in std_logic;
        data_out    : out std_logic_vector(7 downto 0);
        data_av     : out std_logic;
        eom         : out std_logic
    );
end CryptoMessage;

architecture behavioral of CryptoMessage is
    
    type State is (WAITING, CRYPT_CHAR, SEND_CHAR1, SEND_CHAR2, CHAR_ACK_1, CHAR_ACK_0, END_OF_FILE);
    signal currentState : State;
    
    signal lineLength : integer; 
    signal counter    : integer;
    signal crypted    : std_logic_vector(31 downto 0) := "00000000000000000000000000000000"; -- encryption of two chars
    signal send_char  : boolean; -- true if there remains a char to be sent

    --signal temp : std_logic_vector(31 downto 0);
    
    function ExpMod(a,b: in std_logic_vector(31 downto 0); n: in integer) return std_logic_vector is
        variable f : integer := 1;
        variable i : integer range 0 to 31 := 0;
        variable index : integer range 0 to 31 := 31;
    begin
        
        for i in 31 downto 0 loop
            f := TO_INTEGER( ( TO_UNSIGNED(f,32) * TO_UNSIGNED(f,32) ) mod TO_UNSIGNED(n,32) );
            
            if b(index) = '1' then 
                f := (f * TO_INTEGER(UNSIGNED(a))) mod n;
            end if;

            if index = 0 then
            	exit;
            end if;
            index := index - 1;
        end loop;
        
        return STD_LOGIC_VECTOR(TO_UNSIGNED(f,32));
        
    end ExpMod;

begin

    assert FILE_NAME /= "UNUSED"
    report "********************* entity CryptoMessage: missing FILE_NAME *********************"
    severity failure;
    
    data_av <= '1' when currentState = CHAR_ACK_1 else '0'; -- signals that a char was sent
    eom <= '1' when (currentState = CHAR_ACK_1 or currentState = CHAR_ACK_0) and lineLength = 0 and not send_char else '0'; -- signals that all the chars of a line were sent
    
    process(clk,rst)
        file messageFile          : TEXT open READ_MODE is FILE_NAME;
        variable fileLine         : line; -- Stores a read line from a text file
        variable char1            : character; -- Stores a single character
        variable char2            : character; -- Stores a single character
        variable readOK1          : boolean; -- When false indicates end of line
        variable readOK2          : boolean; -- When false indicates end of line
    begin
        if rst = '1' then
            counter <= 0;
            currentState <= WAITING;
            data_out <= "00000000";
            
        elsif rising_edge(clk) then
            case currentState is
                
                -- Wait message interval
                when WAITING =>
                    if counter = MSG_INTERVAL then
                        counter <= 0;
                        if not endfile(messageFile) then                           
                            readline(messageFile, fileLine); -- Read a file line into 'fileLine'. Each line is a message.
                            lineLength <= fileLine'length; -- Set the line number of characters    
                            currentState <= CRYPT_CHAR;
                        else
                            currentState <= END_OF_FILE;
                        end if;                        
                    else
                        counter <= counter + 1;
                        currentState <= WAITING;
                    end if;
                
                -- Encrypt a character
                when CRYPT_CHAR =>
                        
                    -- Read a character from the line
                    read(fileLine, char1, readOK1);
                    
                    if readOK1 then -- Verifies if the end of line was reached

                        -- Read a character from the line
                   		read(fileLine, char2, readOK2);

                   		--temp <="0000000000000000" & STD_LOGIC_VECTOR(TO_UNSIGNED(character'pos(char1),8)) & STD_LOGIC_VECTOR(TO_UNSIGNED(character'pos(char2),8));
                   		send_char <= true;

                   		currentState <= SEND_CHAR1;

                   		if readOK2 then

                   			crypted <= ExpMod("0000000000000000" & STD_LOGIC_VECTOR(TO_UNSIGNED(character'pos(char1),8)) & STD_LOGIC_VECTOR(TO_UNSIGNED(character'pos(char2),8)), PUBLIC_KEY, N);
                   			lineLength <= lineLength - 2;

                   		else

                   		    --temp <="0000000000000000" & STD_LOGIC_VECTOR(TO_UNSIGNED(character'pos(char1),8)) & "00000000";
                        	crypted <= ExpMod("0000000000000000" & STD_LOGIC_VECTOR(TO_UNSIGNED(character'pos(char1),8)) & "00000000", PUBLIC_KEY, N);
                        	lineLength <= lineLength - 1;

                   		end if;


                    else -- End of line (all characters were read) 

                    	currentState <= WAITING;

                    end if;
                
                -- Send the first byte
                when SEND_CHAR1 =>
                	data_out <= crypted(15 downto 8);
                	currentState <= CHAR_ACK_1;

                 -- Send the second byte
                when SEND_CHAR2 =>
                	data_out <= crypted(7 downto 0);
                	send_char <= false;
                	currentState <= CHAR_ACK_1;

                -- Wait for receiver read
                when CHAR_ACK_1 =>

                    if ack = '1' then
                        currentState <= CHAR_ACK_0;
                    else
                        currentState <= CHAR_ACK_1;
                    end if;

                when CHAR_ACK_0 =>

                	if ack = '0' then
                    	if lineLength = 0 and not send_char then
                        	currentState <= WAITING;
                        else
                        	if send_char then
                        		currentState <= SEND_CHAR2;
                        	else
                        	    currentState <= CRYPT_CHAR;
                        	end if;
                        end if;
                    else
                        currentState <= CHAR_ACK_0;
                    end if;
                
                -- End of file. All messages were send.
                when END_OF_FILE =>
                    currentState <= END_OF_FILE;

                when others=>

            end case;
        end if;
    end process;
    
end behavioral;