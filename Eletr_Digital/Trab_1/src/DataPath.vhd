--================================ DATA SIMON ===================

library IEEE;                        
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Simon_pkg.all;

entity DataPath is
	port(
		amarelo:     in    std_logic;
		vermelho:    in    std_logic;
		verde:       in    std_logic;
		azul:        in    std_logic;
		rst:         in    std_logic;
		clk:         in    std_logic;
		entrada:     in    std_logic_vector(1 downto 0); -- memoria
		snais:       in    sinais;

		verdeluz:    out   std_logic;
		azulluz:     out   std_logic;
		vermelholuz: out   std_logic;
		amareloluz:  out   std_logic;
		flgs: 	     out   flags;
		
		add:         out   std_logic_vector(7 downto 0); -- memoria
		ft:          out   std_logic_vector(1 downto 0)  -- saida do LFSR
	);
end DataPath;
architecture data of DataPath is
	
	signal saidaBotao,concatCores,saidaDeco0,muxTemp  :std_logic_vector(3 downto 0); 
	signal resetBotao,Asai,fimAux,fim2Aux		  :std_logic;
	signal addAux,sizeAux,SomaSize,kPls,muxK,kmais1   :std_logic_vector(7 downto 0);
	signal muxCont,somaCont,cont		          :std_logic_vector(2 downto 0);
	signal igualt					  :std_logic;
	signal muxCor1			                  :std_logic_vector(3 downto 0);
	signal mux1,q0,q1,q2,xor2                         :std_logic_vector(1 downto 0);
	
	begin

		concatCores(0) <= azul;		--|			 |
		concatCores(1) <= vermelho;	--|CONCATENAÇAO DAS CORES|
		concatCores(2) <= verde;	--| 			 |
		concatCores(3) <= amarelo;	--|			 |

		resetBotao     <= snais.rst0 or snais.wrlf or snais.rstb;	-- Botao precisa ser restado algmas vezes pra garantir q nem um valor erronio sera mostrado para o usuario.
	
		flgs.fica      <= ((not amarelo)and(not vermelho)and(not azul)and(not verde));	-- Se nem um botao for apertado entao o circuito ficara esperando isso ocorrer.

--                            ====REGISTRADOR BOTAO====

		botao: entity work.RegisterNbits(behavioral)
			generic map(
				width => 4
			)
			port map(
				clk => clk,
				rst => resetBotao,
				ce  => snais.wrbot,
				d   => concatCores,
				q   => saidaBotao		-- saidaBotao recebe a concatenaçao das botoes de cores.
			);

--                           =======REGISTRADOR K==========

		k: entity work.RegisterNbits(behavioral)
			generic map(
				width => 8
			)
			port map(
				clk => clk,
				rst => snais.rst0,
				ce  => snais.wk,
				d   => muxK,			-- k podera receber 0 ou k++.
				q   => addAux			-- Saida do registrador eh conectada com a entrada do somador que faz k++.
		);
		add<=addAux;					-- add eh o endereço a ser acessado na memori.

--                        ===========REGISTRADOR SIZE===========

		regsize: entity work.RegisterNbits(behavioral)	-- size registra quantos numeros o usuario precisa apertar na rodada, ou seja tamanho da sequencia.
			generic map(
				width => 8
			)
			port map(
				clk => clk,
				rst => snais.rst0,
				ce  => snais.wrsize,
				d   => SomaSize,
				q   => sizeAux
			);

--                        =========== COMPARADOR SAI ===========
		compSai: entity work.compara(comport)
			generic map(
				WIDTH=>4
			)
			port map(
				a     => saidaBotao,
				b     => saidaDeco0,
				igual => Asai		-- Auxiliar de sai.
			);

		flgs.sai   <= not Asai;			-- Quando flgs.sai=1 significa q o valor existente na memoria eh diferente do que o usuario escolheu, logo ele perdeu o jogo.
		
		saidaDeco0 <= "0001" when entrada = "00" else	--|					      |
			      "0010" when entrada = "01" else	--|DECODIFICAÇAO DOS VALROES VINDOS DA MEMORIA|
			      "0100" when entrada = "10" else	--|					      |
		              "1000";


--                       =========== COMPARADOR FIM ===========
		compFim: entity work.compara(comport)
			generic map(
				WIDTH=>8
			)
			port map(
				a     => sizeAux,
				b     => addAux,
				igual => fimAux		-- Qndo fimAux=1 significa q o circuito mostrou toda a sequencia para o usuario.
			);

--                      =========== COMPARADOR FIM 2===========
		compFim2: entity work.compara(comport)		-- Qndo fim2Aux=1 significa q o usuario acertou toda a sequencia de cores.
			generic map(				-- ou seja (k+1)=size;
				WIDTH=>8			-- Tem q fazer k+1 pq size começa em em 1, e k começa em 0.
			)					-- Exemplo: qndo size=1 siginifica q existe uma sequencia de uma cor. Ao mesmo tempo k=0, tbm significa q
			port map(				-- existe uma sequencia de uma cor, logo pra sabermos se chegamos ao fim da sequencia, usando k e size, precisamos
				a     => sizeAux,		-- fazer k+1 antes, ou tbm size-1; tanto faz.
				b     => kmais1,			
				igual => fim2Aux
			);			

		kmais1    <= std_logic_vector(signed(addAux)+"00000001");	-- k+1 usado em fim2Aux.
		flgs.fim2 <= fim2Aux;
		flgs.fim  <= fimAux;

		muxTemp   <= saidaBotao when snais.ms='0' else saidaDeco0;	-- mux que escolhe entre valores vindos da memoria ou cores escolhidas pelo usuario.

--				===== SOMADOR SIZE ======
		addSize: entity work.Adder_nbits(behavioral_generic)
			generic map(
				WIDTH=>8
			)
			port map(
				A       => x"01",
        			B       => sizeAux,
        			CarryIn => '0',
        			Sum     => SomaSize		-- Somador pra fazer size++, indicando q a sequencia precisa aumentar em uma unidade.
			);
--				  ==== SOMADOR K ====
		addK: entity work.Adder_nbits(behavioral_generic)
			generic map(
				WIDTH=>8
			)
			port map(
				A       => x"01",
        			B       => addAux,
        			CarryIn => '0',
        			Sum     => kPls			-- k++ pra verificar a proxima posiçao  de memoria.
			);
		
		muxK         <= kPls when snais.mk='1' else x"00";


--			============= PARTE PRA GARANTIR TEMPO ==============
		muxCont      <= "000" when snais.mcont='0' else somaCont;	-- A contagem começa no 0 e vai ate 3, qndo em 3 siginifica q a co,r vinda da memoria ou 
										-- vinda do usuario, foi mostrada por 3 ciclos. 
		flgs.igual   <= igualt;	  					-- igual indica q a contagem acabou

		somaCont     <= std_logic_vector(unsigned(cont)+"001");	-- cont++
		

		verdeluz    <= '1' when muxCor1 = "0100" and snais.ennd='1' else 'Z';	-- garante q apenas uma das luzes serao acesas, do contrario estarao em alta empedancia
		amareloluz  <= '1' when muxCor1 = "1000" and snais.ennd='1' else 'Z';
		vermelholuz <= '1' when muxCor1 = "0010" and snais.ennd='1' else 'Z';
		azulluz     <= '1' when muxCor1 = "0001" and snais.ennd='1' else 'Z';

--				==== contador de tempo ====
		cnt: entity work.RegisterNbits(behavioral)
			generic map(
				width => 3
			)
			port map(
				clk => clk,
				rst => snais.rst0,
				ce  => snais.wrcont,
				d   => muxCont,
				q   => cont
			);

--				=== REGISTRADOR DE COR ===
		mx: entity work.RegisterNbits(behavioral)
			generic map(
				width => 4
			)
			port map(
				clk => clk,
				rst => snais.rst0,
				ce  => snais.wrtempo,
				d   => muxTemp,
				q   => muxCor1				-- muxCor1 registra o valor vindo do muxTemp, o qual deixa passar, ou valores de memoria ou valores do usuario.
			);
-- 				=== MARCA O FIM DO TEMPO ===
		comptemp: entity work.compara(comport)
			generic map(
				WIDTH=>3
			)
			port map(
				a     => cont,
				b     => "010",
				igual => igualt				-- Quando igualt=1 quer dizer q a cor foi mostrada por tempo suficiente. 
			);

--			============= PARTE PRA GARANTIR TEMPO ==============

--			               ===== LFSR =====
		ff0:entity work.RegisterNbits(behavioral) 
			generic map(
				WIDTH =>2,
				INIT_VALUE=>0
			)
			port map(
				clk => clk,
				rst => rst,
				ce  => snais.wrlf,
				q   => q0,
				d   => mux1
			);

		ff1:entity work.RegisterNbits(behavioral) 
			generic map(
				WIDTH =>2,
				INIT_VALUE=>0
			)
			port map(
				clk => clk,
				rst => rst,
				ce  => snais.wrlf,
				q   => q1,
				d   => q2
			);

		ff2:entity work.RegisterNbits(behavioral) 
			generic map(
				WIDTH =>2,
				INIT_VALUE=>0	
			)
			port map(
				clk => clk,
				rst => rst,
				ce  => snais.wrlf,
				q   => q2,
				d   => xor2
			);

		mux1  <= "01" when snais.mlf='0' else q1;	--|				    |
		xor2  <= q0 xor q1;				--|LOGICA PRA GERAR NUMERO ALEATORIO|
		ft(0) <= q0(0);					--|				    |
		ft(1) <= q1(0);					--|			            |

end data;