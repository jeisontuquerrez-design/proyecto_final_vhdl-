library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rom_128x8_sync is
    port (
        clock   : in  std_logic;
        address : in  integer range 0 to 255;
        dataout : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of rom_128x8_sync is
    type rom_type is array (0 to 127) of std_logic_vector(7 downto 0);
    constant ROM : rom_type := (
        0  => x"86",  -- LDA_IMM
        1  => x"AA",
        2  => x"96",  -- STA_DIR
        3  => x"E0",
        4  => x"20",  -- BRA
        5  => x"00",
        others => x"00"
    );
    signal rom_dataout_int : std_logic_vector(7 downto 0);
begin
    process(clock)
    begin
        if rising_edge(clock) then
            if address <= 127 then
                rom_dataout_int <= ROM(address);
            else
                rom_dataout_int <= (others => '0');
            end if;
        end if;
    end process;

    dataout <= rom_dataout_int;
end architecture;
