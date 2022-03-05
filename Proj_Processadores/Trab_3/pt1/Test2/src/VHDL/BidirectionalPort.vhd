library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity BidirectionalPort  is
    generic (
        DATA_WIDTH          : integer;    -- Port width in bits
        PORT_DATA_ADDR      : std_logic_vector(1 downto 0);     -- NÃO ALTERAR!
        PORT_CONFIG_ADDR    : std_logic_vector(1 downto 0);     -- NÃO ALTERAR! 
        PORT_ENABLE_ADDR    : std_logic_vector(1 downto 0);      -- NÃO ALTERAR!
        IRQ_ENABLE_ADDR     : std_logic_vector(1 downto 0)
    );
    port (  
        clk         : in std_logic;
        rst         : in std_logic; 
        
        -- Processor interface
        data_i      : in std_logic_vector (DATA_WIDTH-1 downto 0);
        data_o      : out std_logic_vector (DATA_WIDTH-1 downto 0);
        irq         : out std_logic_vector (DATA_WIDTH-1 downto 0);
        address     : in std_logic_vector (1 downto 0);     -- NÃO ALTERAR!
        rw          : in std_logic; -- 0: read; 1: write
        ce          : in std_logic;
        
        -- External interface
        port_io     : inout std_logic_vector (DATA_WIDTH-1 downto 0)
    );
end BidirectionalPort;


architecture Behavioral of BidirectionalPort  is

    signal PortData, PortConfig, PortEnable, IrqEnable: std_logic_vector(DATA_WIDTH-1 downto 0);

    signal Synch_1, Synch_2: std_logic_vector(DATA_WIDTH-1 downto 0);

    signal tri_state : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal slt_1, slt_2: std_logic_vector(DATA_WIDTH-1 downto 0);

    signal in_PortData: std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    slt_1 <= PortEnable and not PortConfig;

    slt_2 <= PortEnable and PortConfig; 

    MUX_DATA_OUT: data_o <= PortData   when address = PORT_DATA_ADDR   else
    	                    PortConfig when address = PORT_CONFIG_ADDR else
    	                    PortEnable when address = PORT_ENABLE_ADDR else
    	                    IrqEnable;

    --in_PortData <= (Synch_2 and (not slt_1) ) or (data_in and slt_1);

    MUX_PORT_DATA: for i in 0 to (DATA_WIDTH-1) generate
        in_PortData(i) <= data_i(i) when slt_1(i) = '1' and ce = '1' and rw = '1' else 
                          PortData(i) when slt_1(i) = '1' else
                          Synch_2(i);
    end generate;


    TRI_STATE_1_OUT: for i in 0 to (DATA_WIDTH-1) generate
        port_io(i) <= PortData(i) when slt_1(i) = '1' else 'Z';
    end generate;


    TRI_STATE_2_OUT: for i in 0 to (DATA_WIDTH-1) generate
        tri_state(i) <= port_io(i) when slt_2(i) = '1' else 'Z';
    end generate;

    irq <= PortData and PortConfig and PortEnable and IrqEnable; 

    CLOCK_PROCESS: process(clk, rst)
    begin

        if rst = '1' then

        	PortData   <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, DATA_WIDTH));
        	PortConfig <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, DATA_WIDTH));
        	PortEnable <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, DATA_WIDTH));
        	Synch_1    <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, DATA_WIDTH));
        	Synch_2    <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, DATA_WIDTH));
               
        elsif rising_edge(clk) then

            if ce = '1' and rw = '1' then

                if address = PORT_CONFIG_ADDR then

                    PortConfig <= data_i;

                elsif address = PORT_ENABLE_ADDR then

                	PortEnable <= data_i;

                else

                	IrqEnable <= data_i;

                end if;

            end if;

            PortData <= in_PortData;

            Synch_1 <= tri_state;
            Synch_2 <= Synch_1;

        end if;

    end process;


end Behavioral;
