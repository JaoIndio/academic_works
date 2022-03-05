--======================= package ==================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package Simon_pkg is
	type sinais is record
		wrbot:    std_logic; -- botao
		mlf:      std_logic;-- aleatorio
		ms:       std_logic;-- escolhe entre botao e memoria
		mk:       std_logic;-- mux do k
		wk:       std_logic;-- escrita do k
		wrsize:   std_logic;
		wrlf:     std_logic;
		ennd:     std_logic;-- enable q deixa passar algma luz
		wrcont:   std_logic;
		mcont:    std_logic;
		rst0:     std_logic;
		wrtempo:  std_logic;-- registrador pro tempo
		rstb:     std_logic;
	end record;
	type flags is record
		fica:     std_logic;
		igual:    std_logic;-- fim do tempo
		fim:      std_logic;
		fim2:     std_logic;
		sai:      std_logic;
	end record;
end Simon_pkg;