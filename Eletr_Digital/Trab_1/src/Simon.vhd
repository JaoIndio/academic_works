
library IEEE;                        
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Simon_pkg.all;

entity Simon is
	port(
		clk:         in    std_logic;
		rst:         in    std_logic;
		start:       in    std_logic;
		vermelho:    in    std_logic;
		azul:        in    std_logic;
		verde:       in    std_logic;
		amarelo:     in    std_logic;

		gameover:    out   std_logic;
		amareloluz:  out   std_logic;
		verdeluz:    out   std_logic;
		vermelholuz: out   std_logic;
		azulluz:     out   std_logic;
		
		info:        inout std_logic_vector(1 downto 0);	
		add:         out   std_logic_vector(7 downto 0);	
		ld:          out   std_logic;
		sel:         out   std_logic
	
	);
end Simon;

architecture conexaoEstrutural of Simon is
	signal snais            :sinais;
	signal flgs             :flags;
	signal ftaux,entradaaux :std_logic_vector(1 downto 0);
	signal ldaux            :std_logic;

	begin
		CONTROL: entity work.ControlPath(cp1)
			port map(
				clk       => clk,
				rst       => rst,
				start     => start,
				flgs      => flgs,
				snais     => snais,
				ld        => ldaux,
				gameover  => gameover,
				sel       => sel

			);
		DATA: entity work.DataPath(data)
			port map(
				amarelo     => amarelo,
				vermelho    => vermelho,
				verde       => verde,
				azul        => azul,
				entrada     => entradaaux,		 -- valor vindo da memoria
				rst         => rst,
				clk         => clk,
				snais       => snais,
				verdeluz    => verdeluz,
				azulluz     => azulluz,
				vermelholuz => vermelholuz,
				amareloluz  => amareloluz,
				ft          => ftaux,		        -- valor gerado pelo LFSR
				add         => add,
				flgs        => flgs
			);

		info       <= ftaux when ldaux='1' else (others=>'Z');	-- descriçao de um tri-state
		
		ld         <= ldaux;
		entradaaux <= info;

end conexaoEstrutural;

architecture behavioral of Simon is
	type State is (s0,s1,s2,s3,s4,s5,s6,s7,s9,s8,s10);
	signal ldaux:                 std_logic; 
	signal currentState:          State;
	signal k,size:                std_logic_vector(7 downto 0);	-- registradores
	signal cnt:                   std_logic_vector(2 downto 0);	-- registradores
	signal botao,cor,inDeco:      std_logic_vector(3 downto 0);	-- registradores
	signal ftaux:                 std_logic_vector(1 downto 0);	-- concatenaçao dos flips-flops
	signal ff0,ff1,ff2:           std_logic;	                -- lfsr (flip-flops)

	
	begin
	process(clk,rst)
		begin
			if rst='1' then
		
				k            <= x"00";		-- iniciar tudo no zero eh como resetar todos os registradores.
				size         <= x"00";
				cnt          <= "000";
				botao        <= "0000";
				cor          <= "0000";
				currentState <= s0;
				ff1          <= '0';
				ff0          <= '0';
				ff2          <= '0';

			elsif rising_edge(clk) then
				case currentState is
					when s0=>

						ff0 <= '1';		--|                                    |
						ff1 <= ff2;		--|geraçao do primeiro numero aleatorio|
						ff2 <= ff1 xor ff0;	--|                                    |

						if start='1' then
							currentState <= s1;
						else
							currentState <= s0;
						end if;


					when s1=>

						size         <= std_logic_vector(unsigned(size)+x"01");		-- size++
						currentState <= s2;
				

					when s2=>
						cnt<="000";

						if k=size then				-- enquanto nao tiver sido mostrada
							currentState <= s4;		-- a sequencia existente na memoria
							k            <= x"00";		-- permaneceremos entre s2 e s3.
						else
							currentState <= s3;
						end if;

						if info="01" then			--|			  |
							cor           <= "0010";	--|			  |
						elsif info="00" then			--|			  |
							cor           <= "0001";	--|decodificaçao das cores|
						elsif info="10" then			--|			  |
							cor           <= "0100";	--|			  |
						elsif info="11" then			--|			  |
							cor           <= "1000";	--|			  |
						end if;
					

					when s3=>

						cnt  <= std_logic_vector(unsigned(cnt)+"001");		        -- cnt serve pra garantir q a cor sera mostrada por algns ciclos de clock, no caso 3.

						if cnt >= "010" then						-- enquanto cnt<3 permanece no estado 3 e mostra o q esta na memoria
							k            <= std_logic_vector(unsigned(k)+x"01");	-- k++ pra buscar o proximo endereço pois queremos mem[k].
							currentState <= s2;
						else
							currentState <= s3;
						end if;

				
					when s4=>
						cnt                  <= "000";		-- zera cnt pra garantir q nao seja lido um valor errado no s5.

						if vermelho='1' then			--|			  |
							botao        <= "0010";		--|			  |
							currentState <= s5;		--|			  |
						elsif azul='1' then			--|			  |
							botao        <= "0001";		--|			  |
							currentState <= s5;		--|			  |
						elsif verde='1' then			--|			  |
							botao        <= "0100";		--|DECODIFICAÇAO DAS CORES|
							currentState <= s5;		--|			  |
						elsif amarelo='1' then			--|			  |
							botao        <= "1000";		--|			  |
							currentState <= s5;		--|			  |
						else 					--| 			  |
							currentState <= s4;		--| 			  |
						end if;					--| 			  |

						cor<="0000";


					when s5=>
						cnt                  <= std_logic_vector(unsigned(cnt)+"001");	-- o sentido de cnt em s5 eh o msm q o em s3, porem agr pra q seja mostrado
						cor                  <= botao;					-- um valor escolhido pelo usuario, e nao mais um valor existente na memoria.

						if cnt>= "010" then
							currentState <= s6;
						else
							currentState <= s5;
						end if;


					when s6=>

						if (inDeco /= cor) then					-- Se inDeco!=cor eh pq o valor de memeoria eh diferente q o escolhido pelo usuario,
							currentState <= s9;				-- logo ele errou a sequencia.
						elsif std_logic_vector(unsigned(k)+x"01")=size then	-- Caso a sequencia esteja certa, mas nao tenha mais dados pra serem lidos na memoria
							currentState <= s7;				-- significa q o usuario acertou toda a sequencia, entao podemos dar proceguimento ao jogo
						else
							currentState <= s10;				-- se nem uma das condiçoes acima tiverem sido satisfeitas eh pq o usuario esta acertando,
						end if;							-- mas ainda falta cores a serem escolhidas.


					when s7=>							-- Se chegar aqui eh pq todas as cores foram escolhidas corretamente, entao uma nova cor sera
													-- adicionada na memoria.
						k            <= std_logic_vector(unsigned(k)+x"01");	-- k++ pra garantir q uma nova cor sera adicionada numa nova posiçao de memoria.
					        size         <= std_logic_vector(unsigned(size)+x"01"); --size++ pra indicar q a sequencia aumentou em uma unidade.
						currentState <= s8;

					when s8=>				-- Neste estado sera escrita na memoria uma nova cor.

						ff0          <= ff1;		--|                                    |
						ff1          <= ff2;		--|geraçao do primeiro numero aleatorio|
						ff2          <= ff1 xor ff0;	--|                                    |
						k            <= x"00";
						currentState <= s2;		-- Volta pro estado onde eh mostrada a sequencia para o usuario(s2 e s3)

					when s9=>				-- Se chegar aqui eh pq o usuario errou algma cor, logo perdeu o jogo.

						if start='1'then		-- Permanece no s9 ate q start seja apertado.
							currentState <= s0;
						else 
							currentState <= s9;
						end if;

					when s10=>
			
						k            <= std_logic_vector(unsigned(k)+x"01");	-- k++ pra q seja buscada a proxima cor na memoria
						currentState <= s4;
				
				end case;
			end if;
		end process;

		ftaux(0)    <= ff0;						-- concatenaçao do bit 0 da LFSR
		ftaux(1)    <= ff1; 						-- concatenaçao do bit 1 da LFSR
		info        <= ftaux when ldaux='1' else (others=>'Z');		-- descriçao do tri-state
		ld          <= ldaux;
		sel         <= '1' when currentState=s0 or (currentState=s2 and k/=size)  or currentState=s6 or currentState=s8 else '0'; -- condiçoes em q sel=1
		ldaux       <= '1' when currentState=s0 or currentState=s8 else '0';                                                      -- condiçoes em q ld=1
		gameover    <= '1' when currentState=s9 else '0';
		add         <= k;													  -- saida add recebe k, add eh o endereço a ser buscado ou escrito

		vermelholuz <= '1' when cor="0010" and (currentState=s3 or currentState=s5) else 'Z';	--|     			         |
		verdeluz    <= '1' when cor="0100" and (currentState=s3 or currentState=s5) else 'Z';	--|CONDIÇOES PRA Q ALGMA COR SEJA ATIVADA|
		azulluz     <= '1' when cor="0001" and (currentState=s3 or currentState=s5) else 'Z';	--|				         |
		amareloluz  <= '1' when cor="1000" and (currentState=s3 or currentState=s5) else 'Z';	--|				         |

		inDeco      <= "0001" when info="00" else	--|					      |
			       "0010" when info="01" else	--|DECODIFICAÇAO DOS VALORES VINDOS DA MEMORIA|
                               "0100" when info="10" else	--|				              |
                               "1000" when info="11"; 		--|					      |
 
end behavioral;