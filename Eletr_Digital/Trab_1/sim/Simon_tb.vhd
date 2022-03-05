--			TESTE BENCH DO SIMON


library IEEE;                        
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Simon_pkg.all;

entity testesimon is
end testesimon;

architecture tb of testesimon is
	
	constant Data_Width: integer:= 2;
	constant Add_Width:  integer:= 8;
	
	signal clk:              std_logic := '0';
    	signal rst:              std_logic := '1';
	signal start:            std_logic := '0';
	signal vermelhoB:        std_logic := '0';
	signal azulB:            std_logic := '0';
	signal verdeB:           std_logic := '0';
	signal amareloB:         std_logic := '0';

--         		    MEMORIA E
		
	signal infoE:         std_logic_vector(1 downto 0);
	signal csE, rwE:       std_logic;
	signal addE:           std_logic_vector(7 downto 0);

--         		    MEMORIA C
		
	signal infoC:         std_logic_vector(1 downto 0);
	signal csC, rwC:       std_logic;
	signal addC:           std_logic_vector(7 downto 0);

	begin

		SIMON1: entity work.Simon(conexaoEstrutural)
			port map(
				-- entradas do simon
	
				clk      => clk,
				rst      => rst,
				start    => start,
				vermelho => vermelhoB,
				azul     => azulB,
				verde    => verdeB,
				amarelo  => amareloB,

			--  saidas do simon ligadas a memoria
				info     => infoE,
				ld       => rwE,
				sel      => csE,
				add      => addE
			);
		MEM1: entity work.Memory
			generic map(
				DATA_WIDTH => DATA_WIDTH,
            			ADDR_WIDTH => Add_WIDTH
			)
			port map(
				clk     => clk,
            			rw      => rwE,
            			cs      => csE,
            			data    => infoE,
            			address => addE
			);

		SIMON2: entity work.Simon(behavioral)
			port map(
				-- entradas do simon
	
				clk      => clk,
				rst      => rst,
				start    => start,
				vermelho => vermelhoB,
				azul     => azulB,
				verde    => verdeB,
				amarelo  => amareloB,

			--  saidas do simon ligadas a memoria
				info     => infoC,
				ld       => rwC,
				sel      => csC,
				add      => addC
			);
		MEM2: entity work.Memory
			generic map(
				DATA_WIDTH => DATA_WIDTH,
            			ADDR_WIDTH => Add_WIDTH
			)
			port map(
				clk     => clk,
            			rw      => rwC,
            			cs      => csC,
            			data    => infoC,
            			address => addC
			);


		
		clk<= not clk after 20 ns;
		rst<= '0' after 25 ns;
		process
          		begin
				start <= '0';
               
				wait until  clk = '1';
               			wait until  clk = '1';
               			start<= '1';
               			wait until clk = '1';
               			start <= '0';

--  rodada 1
                    
	       			for i in 0 to 5 loop
               				wait until clk = '1';
	       			end loop;
               			vermelhoB <= '1';
	       			wait until clk='1';
	      			vermelhoB<='0';
-- rodada 2

				for i in 0 to 14 loop
               				wait until clk = '1';
	       			end loop;
               			vermelhoB <= '1';
	       			wait until clk='1';
	      			vermelhoB<='0';
		
				for i in 0 to 4 loop
               				wait until clk = '1';
	       			end loop;
               			vermelhoB <= '1';
	       			wait until clk='1';
	      			vermelhoB<='0';
	
--  rodada 3

				for i in 0 to 18 loop
               				wait until clk = '1';
	       			end loop;
               			vermelhoB <= '1';
	       			wait until clk='1';
	      			vermelhoB<='0';
			
				for i in 0 to 4 loop
               				wait until clk = '1';
	       			end loop;
               			vermelhoB <= '1';
	       			wait until clk='1';
	      			vermelhoB<='0';
	
				for i in 0 to 4 loop
               				wait until clk = '1';
	       			end loop;
               			verdeB <= '1';
	       			wait until clk='1';
	      			verdeB<='0';  

-- rodada 4
				for i in 0 to 23 loop
               				wait until clk = '1';
	       			end loop;
               			vermelhoB <= '1';
	       			wait until clk='1';
	      			vermelhoB<='0';
		
				for i in 0 to 4 loop
               				wait until clk = '1';
	       			end loop;
               			vermelhoB <= '1';
	       			wait until clk='1';
	      			vermelhoB<='0';

				for i in 0 to 4 loop
               				wait until clk = '1';
	       			end loop;
               			verdeB <= '1';
	       			wait until clk='1';
	      			verdeB<='0'; 
		
				for i in 0 to 4 loop
               				wait until clk = '1';
	       			end loop;
               			verdeB <= '1';
	       			wait until clk='1';
	      			verdeB<='0';

				for i in 0 to 7 loop
               				wait until clk = '1';
	       			end loop;
               			start <= '1';
	       			wait until clk<='1';
				wait until clk<='1';
               			start <= '0';
	       	wait;    -- Suspend process          
               
	end process;
end tb;