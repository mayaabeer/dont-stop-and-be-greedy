library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MSHR is
    port (
        clk, reset, miss: in std_logic;
        Address, Data   : in std_ulogic_vector(31 downto 0);
        O1: out std_ulogic_vector(31 downto 0));
end MSHR;

architecture MSHR1 of MSHR is
    signal RT, RS: std_ulogic_vector(4 downto 0) := (others => '0');
begin
    process(clk, reset)
    begin
    if reset = '1' then 
    O1 <= (others => '0');
    elsif rising_edge(clk) then
        if miss = '1' then
            O1 <= Address;
            end if;
            end if;
            end process;
end MSHR1;
