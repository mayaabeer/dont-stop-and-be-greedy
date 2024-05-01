library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DM is
	port(I1, I2: in std_ulogic_vector(31 downto 0);
		 O1: out std_ulogic_vector(31 downto 0);
		 O2: out std_ulogic;
		 C1, C2: in std_ulogic);
	end DM; 

architecture DM1 of DM is

component CACHEL1 is
port(I1: in std_ulogic_vector(31 downto 0); --I1: Address
I2: in std_ulogic_vector(63 downto 0); -- I2: Data to be written
O1,O2: out std_ulogic_vector(31 downto 0); --O1: Data read from cache, O2: Writeback Data
O3, O4: out std_ulogic; -- O3: Hit Status , O4: Ready Status
C1, C2: in std_ulogic);
end component;

component CACHEL2 is
generic(N: integer);
port(I1,I2: in std_ulogic_vector(31 downto 0);
O1: out std_ulogic_vector(63 downto 0);
O2: out std_ulogic;
C1, C2: in std_ulogic);
end component;

component CC is
port(I1, I2: in std_ulogic_vector(31 downto 0);
     O1, O2: out std_ulogic_vector(31 downto 0);
     O3, O4, O5, O6, O7: out std_ulogic;
     I3, I4, C1, C2: in std_ulogic);
end component;

component CFC is
port(I1, I2: in std_ulogic_vector(31 downto 0);
I3: in std_ulogic_vector(63 downto 0);
C1, C2, C3, C4: in std_ulogic;
O1: out std_ulogic_vector(31 downto 0);
O2: out std_ulogic_vector(63 downto 0);
O3, O4: out std_ulogic);
end component;

signal ADDRESS, ADDRESS1, D3, D4, D5, D6, WRITE_DATA: std_ulogic_vector(31 downto 0) := (others => '0');
signal WRITE_DATA1, D7, R1: std_ulogic_vector(63 downto 0) := (others => '0');
signal MEMWRITE, MEMREAD, MEMWRITE1, MEMREAD1, HIT, L1READY, HIT_D, MEMWRITE_D, MEMREAD_D, L2READY, MUXCTRL, READREADY, WRITEREADY: std_ulogic := '0';
begin
	ADDRESS <= I1; --Address
	WRITE_DATA <= I2; --Write Data
	MEMWRITE <= C1; --MemWrite
	MEMREAD <= C2; --MemRead

	--Delays introduced by memories.
	--CACHEL1 --> 25ns
	--CACHEL2 --> 250ns

	CFC1: CFC port map(ADDRESS, WRITE_DATA, D7, MEMWRITE, MEMREAD, L2READY, HIT, ADDRESS1, WRITE_DATA1, MEMWRITE1, MEMREAD1);
	CACHEL11: CACHEL1 port map(ADDRESS1, WRITE_DATA1, D3, D4, HIT, L1READY, MEMWRITE1, MEMREAD1);
	CC1: CC port map(D3, D4, D5, D6, HIT_D, MEMWRITE_D, MEMREAD_D, MUXCTRL, WRITEREADY, L1READY, HIT, MEMWRITE, MEMREAD);

	--D5 = D3 = data read or address to read from memory.
	--D6 = D4 = data to write back into memory.

	CACHEL21: CACHEL2 generic map(N => 128)
			  port map(D5, D6, D7, L2READY, MEMWRITE_D, MEMREAD_D);
	
	finalcontrol:process(L1READY, L2READY, D3, D7, MUXCTRL, MEMREAD, MEMREAD_D)
	begin
		if(MEMREAD = '1') then
			if(L1READY = '1' and MUXCTRL = '1') then
				R1(31 downto 0) <= D3;
				R1(63 downto 32) <= (others => '0');
				READREADY <= '1';
			else if(MEMREAD_D = '1' and L2READY = '1' and MUXCTRL = '0') then
				R1 <= D7;
				READREADY <= '1';
			else
				READREADY <= '0';
			end if;
			end if;
		end if;	
	end process;

	O1 <= R1(31 downto 0);
	O2 <= '1' when (MEMREAD = '0' and MEMWRITE = '0') else
	      READREADY or WRITEREADY; --PC&REGENABLE
end DM1;
