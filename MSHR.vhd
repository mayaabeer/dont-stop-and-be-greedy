LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MSHR IS
    PORT (
        clk, reset, miss : IN STD_LOGIC;
        addressIn, dataIn : IN STD_ULOGIC_VECTOR(31 DOWNTO 0);
        dataOut, addressOut : OUT STD_ULOGIC_VECTOR(31 DOWNTO 0);
        rt : IN STD_ULOGIC_VECTOR(4 DOWNTO 0);
        dataReady, addressReady: IN STD_LOGIC;
    );
END MSHR;

ARCHITECTURE MSHR1 OF MSHR IS
    --TYPE MEMORY IS ARRAY (0 TO 31) OF STD_ULOGIC_VECTOR(59 DOWNTO 0);
    --SIGNAL M1 : MEMORY := (OTHERS => (OTHERS => '0'));
    SIGNAL missedAddress, missedData : STD_ULOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL addressReady, dataReady : STD_LOGIC := '0';
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF (miss = '1') THEN
            missedAddress <= addressIn;
        END IF;
        IF (addressReady = '1') THEN
            missedData <= dataIn;
            dataReady <= '1';
        END IF;
        IF(dataReady = '1') THEN
            --put into register
        END IF;
    END PROCESS;
    addressOut <= missedAddress;
    dataOut <= missedData;
END MSHR1;
