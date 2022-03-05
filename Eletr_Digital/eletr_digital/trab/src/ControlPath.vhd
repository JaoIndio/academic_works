
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.Simon_pkg.all;

entity ControlPath is
	port(
		clk:      in std_logic;
		rst:      in std_logic;
		start:    in std_logic;
		flgs:     in flags;

		gameover: out std_logic;
		ld:       out std_logic;
		sel:      out std_logic;
		snais:    out sinais
	);
end ControlPath;

architecture cp1 of ControlPath is
	type State is (s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10);
	signal estadoAtual,proxEstado: State;

	begin
--=================================================================
	process(clk,rst)-- REGISTRADOR DE ESTADOS
		begin

			if rst='1' then
				estadoAtual<= s0;
			elsif rising_edge(clk) then
				estadoAtual<=proxEstado;
			end if;

	end process;


--=================================================================
	process(estadoAtual,flgs.fim,flgs.igual,flgs.fica,start,flgs.sai,flgs.fim2)-- PRXIMO ESTADO
	begin
		case estadoAtual is
			when s0 =>

				if start='0' then			-- Espera q o usuario começe a jogar.
					proxEstado <= s0;
				else
					proxEstado <= s1;
				end if;


			when s1 =>					-- serve pra fazer size++.
				proxEstado <= s2;


			when s2 =>					-- Estado que vai escolher mem[k] pra dps mostrar para o usuario 

				if flgs.fim='0' then			-- Indica q ainda exsitem numeros da memoria a serem mostrados. 
					proxEstado <= s3;
				else
					proxEstado <= s4;		-- Caso contrario, toda a sequencia foi mostrada e agr eh a vez do usuario acertar as cores
				end if;


			when s3=>

				if flgs.igual='1' then			-- igual indica q o tempo de 3 ciclos foi respeitado.
					proxEstado <= s2;		-- Nesse estado eh mostrado a cor existente da memoria 
				else
					proxEstado <= s3;		-- Se os 3 ciclos nao foram alcançados, entao ainda precisamos mostrar por mais tempo a cor.
				end if;


			when s4=>

				if flgs.fica='0' then			-- Enquanto flgs.fica=1 quer dizer q o circuito esta esperando o usuario escolher algma cor.
					proxEstado <= s5;
				else
					proxEstado <= s4;
				end if;


			when s5=>

				if flgs.igual='1' then			-- Mesma logica que a explicada em s3, porem agra sera mostrado nao um valor de memoria, mas sim aquele escolhido
					proxEstado <= s6;		-- pelo usuario.
				else
					proxEstado <= s5;
				end if;


			when s6=>

				if (flgs.fim2='0'and flgs.sai='0') then		-- Se satisfeita, significa que o usuario acertou a cor q esta em mem[k], porem ainda falta outras cores
										-- a serem acertadas
					proxEstado <= s10;

				elsif flgs.sai='1' then				-- Se entrar neste else eh pq o usuario errou a cor q esta em mem[k].

					proxEstado <=s9;

				elsif flgs.fim2='1' then			-- Do contratio, se entrar aqui eh pq ele acertou toda a sequencia, agr uma nova cor precisa ser adicionada
										-- na sequencia.
					proxEstado <= s7;

				end if;


			when s7 =>						-- No estado s7 eh feito size++ e k++.
				proxEstado <= s8;


			when s8 =>						-- Em s8 eh salvo um valor aleatorio em mem[k].
				proxEstado <= s2;				-- Volta pra s2, onde a sequencia sera mostrada novamente para o usuario.


			when s9 =>

				if start='1' then				-- Se chegar em s9 eh pq o usuario perdeu o jogo (Game Over),o circuito fica em s9 ate q 
					proxEstado <= s0;			-- start seja precionado, levando para s0.

				else
					proxEstado <= s9;

				end if;


			when s10 =>						-- Faz k++ pra que a proxima cor seja buscada na memoria.
				proxEstado <= s4;

		end case;
	end process;



--=================================================================
--                 		 SINAIS

	snais.wrbot   <= '1' when  estadoAtual=s4 else '0';
	snais.mlf     <= '1' when  estadoAtual=s8 else '0'; 
	snais.ms      <= '1' when  estadoAtual=s2 else '0';
	snais.mk      <= '1' when  estadoAtual=s7  or (estadoAtual=s3 and flgs.igual='1') or estadoAtual=s10 else '0';
	snais.wk      <= '1' when  estadoAtual=s10 or (estadoAtual=s2 and flgs.fim='1')   or (estadoAtual=s3 and flgs.igual='1') or estadoAtual=s7 or estadoAtual=s8 else '0';
	snais.wrsize  <= '1' when  estadoAtual=s1  or  estadoAtual=s7 else '0';
	snais.wrlf    <= '1' when  estadoAtual=s0  or  estadoAtual=s8 else '0';
	snais.ennd    <= '1' when  estadoAtual=s3  or  estadoAtual=s5 else '0';
	snais.wrcont  <= '1' when  estadoAtual=s3  or  estadoAtual=s5 or estadoAtual=s2 or estadoAtual=s4 else '0';
	snais.mcont   <= '1' when  estadoAtual=s3  or  estadoAtual=s5 else '0';
	snais.rst0    <= '1' when  estadoAtual=s0 else '0';
	snais.rstb    <= '1' when  estadoAtual=s10 else '0';
	snais.wrtempo <= '1' when  estadoAtual=s2  or  estadoAtual=s4 or estadoAtual=s5 else '0';
        ld            <= '1' when  estadoAtual=s0  or  estadoAtual=s8 else '0'; --rw read=0
	sel           <= '1' when  estadoAtual=s0  or  estadoAtual=s8 or estadoAtual=s2 or estadoAtual=s6 else '0'; --cs
	gameover      <= '1' when  estadoAtual=s9 else '0';
end cp1;