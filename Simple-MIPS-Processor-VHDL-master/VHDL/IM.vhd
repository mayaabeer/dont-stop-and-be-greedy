--**********************
--*                    *
--*                    *
--*       ---         *
--*    --|(0)|---     *
--*      |---|        *
--*    --|(1)|---     *
--*       |---|        *
--*    --|(2)|-->     *
--*      |---|        *
--*         .          *
--          .          *
--*                   *
--**********************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library STD;
use STD.textio.all;

entity IM is
generic(N: integer);
port(I1: in std_ulogic_vector(31 downto 0);
     O1: out std_ulogic_vector(31 downto 0));
end IM;

architecture IM1 of IM is
type MEMORY is array (0 to (N-1)) of std_ulogic_vector(31 downto 0); --N*4 byte memory
signal M1: MEMORY := (others => (others => '0'));
signal D1: std_ulogic_vector(29 downto 0) := (others => '0');
signal R1: std_ulogic_vector(31 downto 0) := (others => '0');
begin
    D1 <= I1(31 downto 2); --PC/4    

	M1(0) <= x"00000000";
	M1(1) <= x"00000000";
	M1(2) <= x"00000000";
	M1(3) <= x"00000000";
	M1(4) <= x"0AA80000"; --load, first time
	M1(5) <= x"04010002";
	M1(6) <= x"0AAA0000"; --load, no stall because the data is already in cache
	M1(7) <= x"04220002";
	M1(8) <= x"04430002";
	M1(9) <= x"08760000"; --load, different data, stall
	M1(10) <= x"04640002";
	M1(11) <= x"04850002";

    R1 <= M1(to_integer(unsigned(D1))) when to_integer(unsigned(D1)) < (N-1) else
          std_ulogic_vector(to_signed(-1, 32)) when to_integer(unsigned(D1)) > (N-1);
    
    O1 <= R1;
end IM1;