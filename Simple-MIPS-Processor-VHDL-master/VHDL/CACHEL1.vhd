library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CACHEL1 is
port(I1,I2: in std_ulogic_vector(31 downto 0); --I1: Address, I2: Data to be written
     O1,O2: out std_ulogic_vector(31 downto 0); --O1: Data read from cache, O2: Writeback Data
     O3, O4: out std_ulogic; -- O3: Hit Status , O4: Ready Status
     C1, C2: in std_ulogic); -- C1: Write control, C2: Read control
end CACHEL1;

architecture CACHEL11 of CACHEL1 is
type MEMORY is array (0 to 31) of std_ulogic_vector(59 downto 0); --This is an array that initalizes 32 blocks of 60 bits memory structure
signal M1: MEMORY := (others => (others => '0')); --Initialize everything to 0
signal D1, D2, R2, R3: std_ulogic_vector(31 downto 0) := (others => '0'); --R2: Signal storing the data that is read from the cache. R3: Stores the data needed to writeback to memory
signal D3, D4, HIT, READY: std_ulogic := '0';
begin
	D1 <= transport I1 after 13 ns; --address (TAG&POINTER) derived from I1
	D2 <= transport I2 after 13 ns; --Write Data Derived from I2
	D3 <= transport C1 after 13 ns; --MemWrite Determines whether its a write op or not derived from C1
	D4 <= transport C2 after 13 ns; --MemRead Determines whether its a read op or not derived from C2

	-- D1(4 downto 0) 5 bit di pointer (32 indirizzi possibili nella cache) !! offset non presente
	-- D1(31 downto 5) 27 bit di tag (istruzione)
	-- R1(58 downto 32) 27 bit di tag
	-- R1(59) valid

	--Translation
	--D1(4 downto 0): 5-bit pointer basically represents the index (32 possible blocks in the cache) !! no offset present
	--D1(31 downto 5): 27-bit tag (instruction)
	--R1(58 downto 32): 27-bit tag
	--R1(59): valid

	Control:process(D1, D2, D3, D4)
	variable MEMDATA: std_ulogic_vector(59 downto 0) := (others => '0');
	variable VALIDFLAG, TAGFLAG, HITFLAG, READYFLAG: std_ulogic := '0';
	begin
		if(to_integer(unsigned(D1(4 downto 0))) < 32) then --checks if the index is in one of the 32 blocks
			MEMDATA := M1(to_integer(unsigned(D1(4 downto 0))));
			VALIDFLAG := MEMDATA(59);
		end if;

		if(D1(31 downto 5) = MEMDATA(58 downto 32)) then
			TAGFLAG := '1';
		else
			TAGFLAG := '0';
		end if;

		if(D3 = '0' and D4 = '0' and MEMDATA = "000000000000000000000000000000000000000000000000000000000000") then
			HITFLAG := '1';
		else
			HITFLAG := VALIDFLAG and TAGFLAG;
		end if;

		READYFLAG := '0';

		if(D3 = '0' and D4 = '1') then --Read
			if(HITFLAG = '1') then --cache retrieve the data from the cache
				R2 <= MEMDATA(31 downto 0);
				READYFLAG := '1';
			else --output the address of the data to be fetched from memory
				R2 <= D1;
				READYFLAG := '1';
			end if;
		else if(D3 = '1' and D4 = '0') then --write
			if(VALIDFLAG = '0') then --write the data into the cache (no hit = '0' because the previous data is invalid)
				M1(to_integer(unsigned(D1(4 downto 0)))) <= '1'&D1(31 downto 5)&D2;
				HITFLAG := '1';
				READYFLAG := '1';
			else if(VALIDFLAG = '1') then
				if(HITFLAG = '1') then --update the data
					M1(to_integer(unsigned(D1(4 downto 0)))) <= '1'&D1(31 downto 5)&D2; --valid data, same tag, new data
					READYFLAG := '1';
				else -- tags don't match -> perform write back
					R3 <= MEMDATA(31 downto 0); --data to be written back to memory (write-back data)
					R2 <= MEMDATA(58 downto 32)&D1(4 downto 0);
					M1(to_integer(unsigned(D1(4 downto 0)))) <= '1'&D1(31 downto 5)&D2; --valid data, different tag, new data
					READYFLAG := '1';
				end if;
			end if;
			end if;			
		end if;
		end if;
		HIT <= HITFLAG;
		READY <= READYFLAG;
	end process;

	O1 <= R2; --data read or address to be read from memory or address to write the write-back data
	O2 <= R3; --data to be written into memory (write-back data)
	O3 <= HIT; --hit
	O4 <= READY; --ready

end CACHEL11;
