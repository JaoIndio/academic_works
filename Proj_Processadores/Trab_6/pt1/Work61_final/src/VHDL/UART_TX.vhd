------------------------------------------------------------------------------
-- DESIGN UNIT  : UART TX                                                   --
-- DESCRIPTION  : Start bit/8 data bits/Stop bit                            --
--              :                                                           --
-- AUTHOR       : Everton Alceu Carara                                      --
-- CREATED      : May, 2016                                                 --
-- VERSION      : 1.0                                                       --
-- HISTORY      : Version 1.0 - May, 2016 - Everton Alceu Carara            --         
------------------------------------------------------------------------------

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity UART_TX is
    generic(
        TX_DATA_ADDR    : std_logic;
        BAUD_RATE_ADDR  : std_logic;
        RATE_FREQ_BAUD  : integer -- Frequence entering the clk input in Hz / Baud rate (bits per sencond) 
        -- Considering clk = 100MHz
        --      9600: RATE_FREQ_BAUD = 10416
        --      19200: RATE_FREQ_BAUD = 5208
        --      38400: RATE_FREQ_BAUD = 2604
        --      57600: RATE_FREQ_BAUD = 1736
        --      115200: RATE_FREQ_BAUD = 868
        --      460800: RATE_FREQ_BAUD = 217
        --      921600: RATE_FREQ_BAUD = 108
    );
    port(
        clk         : in std_logic;
        rst         : in std_logic;
        data_in     : in std_logic_vector(7 downto 0);
        data_av     : in std_logic;
        address     : in std_logic;
        tx          : out std_logic;
        ready       : out std_logic     -- When '1', module is available to send a new byte
    );
end UART_TX;

architecture behavioral of UART_TX is

     -- Keeps the baud rate value
     signal BAUD_RATE: integer;

     -- controls the transmition rate based on the programmed baud rate
     signal clkCounter: integer;

     signal bitCounter: integer range 0 to 8;
        
     type State is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
     signal currentState: State;
     
     signal tx_data: std_logic_vector(7 downto 0);
     
begin

    process(clk,rst)
    begin
        if rst = '1' then
            clkCounter <= 0;
         elsif rising_edge(clk) then
            if currentState /= IDLE then
                if clkCounter = BAUD_RATE-1 then
                    clkCounter <= 0;
                else
                    clkCounter <= clkCounter + 1;
                end if;
            else
                clkCounter <= 0;
            end if;
         end if;
    end process;

    process(clk,rst)
    begin
        if rst = '1' then
            BAUD_RATE <= RATE_FREQ_BAUD;
        elsif rising_edge(clk) then
            if data_av = '1' and address = BAUD_RATE_ADDR then
                BAUD_RATE <= TO_INTEGER(UNSIGNED(data_in));
            end if;
        end if;
    end process;
    
    
    process(clk,rst)
    begin
        if rst = '1' then
            bitCounter <= 0;
            tx_data <= (others=>'0');
            currentState <= IDLE;
        
        elsif rising_edge(clk) then
            case currentState is
                when IDLE =>
                    bitCounter <= 0;
                    if data_av = '1' and address = TX_DATA_ADDR then
                        tx_data <= data_in;
                        currentState <= START_BIT;
                    else
                        currentState <= IDLE;
                    end if;
                    
                when START_BIT =>
                    if clkCounter = RATE_FREQ_BAUD-1 then
                        currentState <= DATA_BITS;
                    else
                        currentState <= START_BIT;
                    end if;                    
                        
                when DATA_BITS =>
                    if bitCounter = 8 then
                        currentState <= STOP_BIT;
                    elsif clkCounter = RATE_FREQ_BAUD-1 then           
                        tx_data <= '0' & tx_data(7 downto 1);
                        bitCounter <= bitCounter + 1;
                        currentState <= DATA_BITS;
                    else
                        currentState <= DATA_BITS;
                    end if;
                    
                when STOP_BIT =>
                    if clkCounter = RATE_FREQ_BAUD-1 then
                        currentState <= IDLE;
                    else
                        currentState <= STOP_BIT;
                    end if;
                                      
            end case;
        end if;
    end process;
    
    tx <=   '0' when currentState = START_BIT else 
            tx_data(0) when currentState = DATA_BITS else
            '1';    -- IDLE, STOP_BIT
            
    ready <= '1' when currentState = IDLE else '0';
   
    
end behavioral;
