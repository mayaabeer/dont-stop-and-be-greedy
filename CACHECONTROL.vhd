-- manage memory read and write
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY CC IS
	PORT (
		I1, I2 : IN STD_ULOGIC_VECTOR(31 DOWNTO 0);
		O1, O2 : OUT STD_ULOGIC_VECTOR(31 DOWNTO 0);
		O3, O4, O5, O6, O7 : OUT STD_ULOGIC;
		I3, I4, C1, C2 : IN STD_ULOGIC);
END CC;

ARCHITECTURE CC1 OF CC IS
COMPONENT MSHR IS
PORT (
	clk, reset, miss : IN STD_LOGIC;
	Address, Data : IN STD_ULOGIC_VECTOR(31 DOWNTO 0);
	O1 : OUT STD_ULOGIC_VECTOR(31 DOWNTO 0));
END COMPONENT;

	SIGNAL Datain, D1, D2, D7, D8, addressIn, addressOut : STD_ULOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	SIGNAL D3, D4, D5, D6, D9, D10, D11, D12, D13, clock, rst, cacheMiss : STD_ULOGIC := '0';
BEGIN

MSHR1: MSHR port map(clock, rst, cacheMiss, addressIn, DataIn, addressOut);

	D1 <= I1; --data or address read from memory, assigns input port I1 to D1
	D2 <= I2; --(write back)
	D3 <= I3; --ready in L1
	D4 <= I4; --hit (check whether cache hit?)
	D5 <= C1; --memwrite (signal to control write operations)
	D6 <= C2; --memread (control read)

	control : PROCESS (D1, D2, D3, D4, D5, D6)
		VARIABLE WRITEFLAG : STD_ULOGIC := '0';
	BEGIN
		D7 <= D1; --data read
		D8 <= D2; --data write back
		WRITEFLAG := '0';

		IF (D3 = '1' AND D4 = '1' AND D5 = '0' AND D6 = '1') THEN --Cache read successful. from L1
			D10 <= '0';
			D11 <= '0';
			D12 <= '1';
		ELSE
			IF (D3 = '1' AND D4 = '0' AND D5 = '0' AND D6 = '1') THEN --Cache read unsuccessful -> Read from memory.
				D10 <= '0';
				D11 <= '1';
				D12 <= '0';
				cacheMiss <= '1';
				addressIn <= D7;
			ELSE
				IF (D3 = '1' AND D4 = '1' AND D5 = '1' AND D6 = '0') THEN --Write successful.
					WRITEFLAG := '1';
				ELSE
					IF (D3 = '1' AND D4 = '0' AND D5 = '1' AND D6 = '0') THEN --Write unsuccessful (writeback).
						D10 <= '1';
						D11 <= '0';
						WRITEFLAG := '1';
					END IF;
				END IF;
			END IF;
		END IF;
		D13 <= WRITEFLAG;
	END PROCESS;

	O1 <= D7; --address mem
	O2 <= D8; --write data to mem
	O3 <= D9; --hit delayed (cache hit?)
	O4 <= D10; --mem write delayed (only under certain conditions, i dont think we nead to care about it?)
	O5 <= D11; --mem read delayed (probably the delayed, possibly the stalling)
	O6 <= D12; --mux ctrl
	O7 <= D13; --write ready

END CC1;