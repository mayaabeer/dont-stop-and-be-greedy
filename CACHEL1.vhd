LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY CACHEL1 IS
	PORT (
		I1, I2 : IN STD_ULOGIC_VECTOR(31 DOWNTO 0); --I1: Address, I2: Data to be written
		O1, O2 : OUT STD_ULOGIC_VECTOR(31 DOWNTO 0); --O1: Data read from cache, O2: Writeback Data
		O3, O4 : OUT STD_ULOGIC; -- O3: Hit Status , O4: Ready Status
		C1, C2 : IN STD_ULOGIC); -- C1: Write control, C2: Read control
END CACHEL1;

ARCHITECTURE CACHEL11 OF CACHEL1 IS
	TYPE MEMORY IS ARRAY (0 TO 31) OF STD_ULOGIC_VECTOR(59 DOWNTO 0); --This is an array that initalizes 32 blocks of 60 bits memory structure
	SIGNAL M1 : MEMORY := (OTHERS => (OTHERS => '0')); --Initialize everything to 0
	SIGNAL D1, D2, R2, R3 : STD_ULOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); --R2: Signal storing the data that is read from the cache. R3: Stores the data needed to writeback to memory
	SIGNAL D3, D4, HIT, READY : STD_ULOGIC := '0';
BEGIN
	D1 <= TRANSPORT I1 AFTER 13 ns; --address (TAG&POINTER) derived from I1
	D2 <= TRANSPORT I2 AFTER 13 ns; --Write Data Derived from I2
	D3 <= TRANSPORT C1 AFTER 13 ns; --MemWrite Determines whether its a write op or not derived from C1
	D4 <= TRANSPORT C2 AFTER 13 ns; --MemRead Determines whether its a read op or not derived from C2

	-- D1(4 downto 0) 5 bit di pointer (32 indirizzi possibili nella cache) !! offset non presente
	-- D1(31 downto 5) 27 bit di tag (istruzione)
	-- R1(58 downto 32) 27 bit di tag
	-- R1(59) valid

	--Translation
	--D1(4 downto 0): 5-bit pointer basically represents the index (32 possible blocks in the cache) !! no offset present
	--D1(31 downto 5): 27-bit tag (instruction)
	--R1(58 downto 32): 27-bit tag
	--R1(59): valid

	Control : PROCESS (D1, D2, D3, D4)
		VARIABLE MEMDATA : STD_ULOGIC_VECTOR(59 DOWNTO 0) := (OTHERS => '0');
		VARIABLE VALIDFLAG, TAGFLAG, HITFLAG, READYFLAG : STD_ULOGIC := '0';
	BEGIN
		IF (to_integer(unsigned(D1(4 DOWNTO 0))) < 32) THEN --checks if the index is in one of the 32 blocks
			MEMDATA := M1(to_integer(unsigned(D1(4 DOWNTO 0))));
			VALIDFLAG := MEMDATA(59);
		END IF;

		IF (D1(31 DOWNTO 5) = MEMDATA(58 DOWNTO 32)) THEN
			TAGFLAG := '1';
		ELSE
			TAGFLAG := '0';
		END IF;

		IF (D3 = '0' AND D4 = '0' AND MEMDATA = "000000000000000000000000000000000000000000000000000000000000") THEN
			HITFLAG := '1';
		ELSE
			HITFLAG := VALIDFLAG AND TAGFLAG;
		END IF;

		READYFLAG := '0';

		IF (D3 = '0' AND D4 = '1') THEN --Read
			IF (HITFLAG = '1') THEN --cache retrieve the data from the cache
				R2 <= MEMDATA(31 DOWNTO 0);
				READYFLAG := '1';
			ELSE --output the address of the data to be fetched from memory
				R2 <= D1;
				READYFLAG := '1';
			END IF;
		ELSE
			IF (D3 = '1' AND D4 = '0') THEN --write
				IF (VALIDFLAG = '0') THEN --write the data into the cache (no hit = '0' because the previous data is invalid)
					M1(to_integer(unsigned(D1(4 DOWNTO 0)))) <= '1' & D1(31 DOWNTO 5) & D2;
					HITFLAG := '1';
					READYFLAG := '1';
				ELSE
					IF (VALIDFLAG = '1') THEN
						IF (HITFLAG = '1') THEN  --update the data
							M1(to_integer(unsigned(D1(4 DOWNTO 0)))) <= '1' & D1(31 DOWNTO 5) & D2; --valid data, same tag, new data
							READYFLAG := '1';
						ELSE -- tags don't match -> perform write back
							R3 <= MEMDATA(31 DOWNTO 0);  --data to be written back to memory (write-back data)
							R2 <= MEMDATA(58 DOWNTO 32) & D1(4 DOWNTO 0);
							M1(to_integer(unsigned(D1(4 DOWNTO 0)))) <= '1' & D1(31 DOWNTO 5) & D2;  --valid data, different tag, new data
							READYFLAG := '1';
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
		HIT <= HITFLAG;
		READY <= READYFLAG;
	END PROCESS;

	O1 <= R2; --data read or address to be read from memory or address to write the write-back data
	O2 <= R3; --data to be written into memory (write-back data)
	O3 <= HIT; --hit
	O4 <= READY; --ready

END CACHEL11;