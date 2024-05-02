--declare MSHR, CacheL1, CacheL2, HDU,

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY NonBlockingTb IS
END NonBlockingTb;

ARCHITECTURE TBMIPS OF TB IS

    COMPONENT MSHR IS
        PORT (
            clk, reset, miss : IN STD_LOGIC;
            addressIn, dataIn : IN STD_ULOGIC_VECTOR(31 DOWNTO 0);
            dataOut, addressOut : OUT STD_ULOGIC_VECTOR(31 DOWNTO 0);
            rt : IN STD_ULOGIC_VECTOR(4 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT CACHEL1 IS
        PORT (
            I1, I2 : IN STD_ULOGIC_VECTOR(31 DOWNTO 0); --I1: Address, I2: Data to be written
            O1, O2 : OUT STD_ULOGIC_VECTOR(31 DOWNTO 0); --O1: Data read from cache, O2: Writeback Data
            O3, O4 : OUT STD_ULOGIC; -- O3: Hit Status , O4: Ready Status
            C1, C2 : IN STD_ULOGIC); -- C1: Write control, C2: Read control
    END COMPONENT;

    COMPONENT CACHEL2 IS
        GENERIC (N : INTEGER);
        PORT (
            I1, I2 : IN STD_ULOGIC_VECTOR(31 DOWNTO 0); --address and data
            O1 : OUT STD_ULOGIC_VECTOR(31 DOWNTO 0); --return data for read signal
            O2 : OUT STD_ULOGIC; --called L2Ready. Can cache serve the operation?
            C1, C2 : IN STD_ULOGIC); -- write OR read signal
    END COMPONENT;

    COMPONENT HDU IS
        PORT (
            I1 : IN STD_ULOGIC_VECTOR(31 DOWNTO 0);
            I2 : IN STD_ULOGIC_VECTOR(4 DOWNTO 0);
            I3 : IN STD_ULOGIC;
            O1, O2, O3 : OUT STD_ULOGIC);
    END COMPONENT;

    COMPONENT REG IS
        PORT (
            I1, I2, I3 : IN STD_ULOGIC_VECTOR(4 DOWNTO 0);
            I4 : IN STD_ULOGIC_VECTOR(31 DOWNTO 0);
            C1 : IN STD_ULOGIC;
            O1, O2 : OUT STD_ULOGIC_VECTOR(31 DOWNTO 0));
    END COMPONENT;

    SIGNAL mshr_addressOut : STD_ULOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mshr_miss : STD_LOGIC;
BEGIN

    MSHR1 : MSHR PORT MAP(mshr_clk, mshr_reset, mshr_miss, mshr_addressIn, mshr_dataIn, mshr_dataOut, mshr_addressOut, mshr_rt, mshr_dataReady, mshr_addressReady);
    CACHEL1 : CACHEL11 PORT MAP(l1_address, l1_writeData, l1_readData, l1_writebackData, l1_hit, l1_ready, l1_write, l1_read);
    CACHEL2 : CACHEL21 PORT MAP(l2_address, l2_dataIn, l2_dataOut, l2_ready, l2_write, l2_read);
    HDU : HDU1 PORT MAP(hdu_instruction, hdu_rt1, hdu_read, hdu_mux, hdu_pc, hud_IFID);
    --REG : REG1 PORT MAP(reg_readreg1, reg_redreg2, );
    mshr_miss <=  not l1_hit;
    if(mshr_miss = '1')
        mshr_addressIn <= l1_readData;
        mshr_addressReady <= '1';
    END IF;
    if(mshr_addressReady = '1')
        l2_address <= mshr_addressOut;
        mshr_dataIn <= l2_dataOut;
        mshr_dataReady <= '1';
    END IF;

    --connect data to be fetched from memory to mshr
END TBMIPS;