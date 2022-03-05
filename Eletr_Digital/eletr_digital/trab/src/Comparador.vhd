--                               COMPARADOR
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity compara is
	generic (
		WIDTH		: integer := 8;
		INIT_VALUE	: integer := 0 
	);
	port(
  		a:      in  std_logic_vector (WIDTH-1 downto 0);
		b:      in  std_logic_vector (WIDTH-1 downto 0);

		amaior: out  std_logic;
		bmaior: out  std_logic;
		igual:  out  std_logic
	);
end compara;

architecture comport of compara is
	signal sa,sb: signed(WIDTH-1 downto 0);
	begin
		sa<=signed(a);
		sb<=signed(b);

		amaior<= '1' when sa>sb else '0';
		bmaior<= '1' when sa<sb else '0';
		igual<= '1' when a=b else '0';
end comport;