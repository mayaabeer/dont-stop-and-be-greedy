LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY NonBlockingTb IS
END NonBlockingTb;

ARCHITECTURE TBMIPS OF NonBlockingTb IS

    COMPONENT MSHR IS
        PORT (
            clk, reset, miss : IN STD_LOGIC;
            addressIn, dataIn : IN STD_ULOGIC_VECTOR(31 DOWNTO 0);
            dataOut, addressOut : OUT STD_ULOGIC_VECTOR(31 DOWNTO 0);
            rt_in : IN STD_ULOGIC_VECTOR(4 DOWNTO 0);
            rt_out : OUT STD_ULOGIC_VECTOR(4 DOWNTO 0);
            dataReady : IN STD_LOGIC;
            addressReady : IN STD_LOGIC;
            dataReadyOut : OUT STD_LOGIC;
            mshr_ready : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT CACHEL1 IS
        PORT (
            I1, I2 : IN STD_ULOGIC_VECTOR(31 DOWNTO 0);
            O1, O2 : OUT STD_ULOGIC_VECTOR(31 DOWNTO 0);
            O3, O4 : OUT STD_ULOGIC;
            C1, C2 : IN STD_ULOGIC
        );
    END COMPONENT;

    COMPONENT CACHEL2 IS
        GENERIC (N : INTEGER);
        PORT (
            I1, I2 : IN STD_ULOGIC_VECTOR(31 DOWNTO 0);
            O1 : OUT STD_ULOGIC_VECTOR(31 DOWNTO 0);
            O2 : OUT STD_ULOGIC;
            C1, C2 : IN STD_ULOGIC
        );
    END COMPONENT;

    SIGNAL mshr_addressIn, mshr_dataOut, mshr_addressOut, l1_writeData, l1_readData, l1_writebackData : STD_ULOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mshr_miss, mshr_reset, mshr_clk, l1_hit, l1_ready, l1_write, l1_read, mshr_ready : STD_LOGIC;
    SIGNAL l1_address, l2_address, l2_dataOut, mshr_dataIn, l2_dataIn : STD_ULOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mshr_dataReady, mshr_addressReady, mshr_dataReadyOut, l2_ready, l2_write, l2_read : STD_LOGIC;
    SIGNAL sig_rt, mshr_rt_in, mshr_rt_out : STD_ULOGIC_VECTOR(4 DOWNTO 0);

BEGIN

    MSHR1 : MSHR PORT MAP(
        mshr_clk, mshr_reset, mshr_miss, mshr_addressIn, mshr_dataIn,
        mshr_dataOut, mshr_addressOut, mshr_rt_in, mshr_rt_out,
        mshr_dataReady, mshr_addressReady, mshr_dataReadyOut, mshr_ready
    );

    CACHEL11 : CACHEL1 PORT MAP(
        l1_address, l1_writeData, l1_readData, l1_writebackData,
        l1_hit, l1_ready, l1_write, l1_read
    );

    CACHEL21 : CacheL2 GENERIC MAP(N => 32)
    PORT MAP(
        l2_address, l2_dataIn, l2_dataOut, l2_ready, l2_write, l2_read
    );

    clkGEN : PROCESS
    BEGIN
        mshr_clk <= '0';
        WAIT FOR 50 ns;
        mshr_clk <= '1';
        WAIT FOR 50 ns;
    END PROCESS;

    setReg : PROCESS
    BEGIN
        WAIT FOR 20 ns;
        sig_rt <= "00010";
        l1_address <= "00000000000000000000000000000001";
    END PROCESS;

    PROCESS (mshr_clk)
    BEGIN
        mshr_rt_in <= sig_rt;
        IF rising_edge(mshr_clk) THEN
            mshr_miss <= NOT l1_hit;

            IF mshr_miss = '1' THEN
                mshr_addressIn <= l1_address;
                mshr_addressReady <= '1';
                l2_read <= '1';
                l2_write <= '0';
            END IF;

            IF mshr_addressReady = '1' THEN
                l2_address <= mshr_addressOut;
                mshr_dataIn <= l2_dataOut;
                mshr_dataReady <= '1';
            END IF;
        END IF;
    END PROCESS;

    --connect data to be fetched from memory to mshr
END TBMIPS;