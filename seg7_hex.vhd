library ieee;
use ieee.std_logic_1164.all;

entity seg7_hex is
    port (
        digit : in integer range 0 to 15;  -- Ahora cuenta hasta 15 (0-F)
        seg   : out std_logic_vector(6 downto 0) -- g,f,e,d,c,b,a
    );
end seg7_hex;

architecture arch of seg7_hex is
begin
    process(digit)
    begin
        case digit is
            when 0  => seg <= "1000000";  -- 0
            when 1  => seg <= "1111001";  -- 1
            when 2  => seg <= "0100100";  -- 2
            when 3  => seg <= "0110000";  -- 3
            when 4  => seg <= "0011001";  -- 4
            when 5  => seg <= "0010010";  -- 5
            when 6  => seg <= "0000010";  -- 6
            when 7  => seg <= "1111000";  -- 7
            when 8  => seg <= "0000000";  -- 8
            when 9  => seg <= "0010000";  -- 9
            when 10 => seg <= "0001000";  -- A
            when 11 => seg <= "0000011";  -- b
            when 12 => seg <= "1000110";  -- C
            when 13 => seg <= "0100001";  -- d
            when 14 => seg <= "0000110";  -- E
            when 15 => seg <= "0001110";  -- F
            when others => seg <= "1111111"; -- apagado
        end case;
    end process;
end arch;
