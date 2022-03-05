%-------------------------------------------------------------------------%
%               UFSM - Universidade Federal de Santa Maria                %
%              Curso de Engenharia de Controle e Automacao                %
%            ELC 1032 - Fundamentos de Eletronica de Potencia             %
%                                                                         %
%   Programadores:                                                        %
%       Rafael C. Beltrame                                                %
%                                                                         %
%   Versao: 1.0                                             06/12/2021    %
%=========================================================================%
%                        Descricao do Programa                            %
%=========================================================================%
%	Projeto do conversor CC-CC elevador de tensao (Boost) em modo CCM.      %
%                                                                         %
%   v1.0 - Versao inicial.                                                %
%-------------------------------------------------------------------------%
close all                                   % Fecha todos os graficos
clear all                                   % Exclui todas as variaveis
clc                                         % Limpa a tela
format short eng                            % Formato para exibicao numerica

%-------------------------------------------------------------------------%
% Especificacoes                                                          %
%-------------------------------------------------------------------------%
Po   = 500;                               % Potencia de saida (W)
Vin  = 178.7070;                          % Tensao de entrada (V)
Vo   = 350;                                 % Tensao de saida (V)
fs   = 1.4e3;                                % Frequencia de chaveamento (Hz)
DILp = 20/100;                              % Ondulacao (ripple) de corrente no indutor (%)
DVop = 2.5/100;                               % Ondulacao (ripple) de tensao no capacitor (%)

%% -----------------------------------------------------------------------%
% Projeto                                                                 %
%-------------------------------------------------------------------------%
Ts = 1/fs;                                  % Periodo de chaveamento (s)

Ro = Vo^2/Po                                % Ressitencia de carga (Ohms)
D  = 1-Vin/Vo                               % Razao-ciclica (duty-cycle)

Pin = Po;                                   % Potencia de entrada (n = 100%) (W)
Iin = Pin/Vin;                              % Corrente media na entrada (A)
IL  = Iin;                                  % Corrente media no indutor (A)
Io  = Po/Vo;                                % Corrente media na saida (A)

DIL = DILp*IL;                              % Ondulacao (ripple) de corrente no indutor (A)
DVo = DVop*Vo;                              % Ondulacao (ripple) de tensao no capacitor (V)

L = (Vin*D)/(DIL*fs)                        % Indutor (H)
C = (Io*D)/(DVo*fs)                         % Capacitor (F)

%% -----------------------------------------------------------------------%
% Simulacao no PSIM                                                       %
%-------------------------------------------------------------------------%
% OBS: Sempre simular por multiplos de Ts
Ts_rede = 1/60
Time_step  = Ts_rede/400                        % Passo de simulacao (s)
Total_time = 15*Ts_rede                           % Tempo total de simulacao (s)
Print_time = 0*Ts_rede                           % Tempo inicial para exibicao (s)

NP = (Total_time-Print_time)/Time_step      % Numero de pontos de simulacao

%% -----------------------------------------------------------------------%
% Validacao do projeto                                                    %
%-------------------------------------------------------------------------%
% OBS: Dados extraidos do PSIM

% INDUTOR
IL_avg = 2.79433;                         % Corrente media no indutor (A)
IL_max = 3.07378;                         % Corrente maxima (pico) no indutor (A)
IL_min = 2.5149;                         % Corrente minima (vale) no indutor (A)
                                            % Ondulacao (ripple) de corrente no indutor (%)
DILp_psim = (IL_max-IL_min)/IL_avg * 100

% CAPACITOR
Vo_avg = 349.991;                         % Tensao media no capacitor (V)
Vo_max = 354.381;                         % Tensao maxima (pico) no capacitor (V)
Vo_min = 345.641;                         % Tensao minima (vale) no capacitor (V)
                                            % Ondulacao (ripple) de tensao no capacitor (%)
DVop_psim = (Vo_max-Vo_min)/Vo_avg * 100