library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity memory is
    port (
        clock       : in  std_logic;
        reset       : in  std_logic;
        address     : in  std_logic_vector(7 downto 0);
        datain      : in  std_logic_vector(7 downto 0);
        write       : in  std_logic;
        port_in_00  : in std_logic_vector(7 downto 0);  -- Un solo puerto de entrada
        port_out_00 : out std_logic_vector(7 downto 0); -- Un solo puerto de salida (conecta a LEDs)
        dataout     : out std_logic_vector(7 downto 0);

        hex0        : out std_logic_vector(6 downto 0);
        hex1        : out std_logic_vector(6 downto 0);
        hex2        : out std_logic_vector(6 downto 0);
        hex3        : out std_logic_vector(6 downto 0)
    );
end entity;

architecture memory_arch of memory is

    -- Declaración de componentes
    component rom_128x8_sync is
        port (
            clock   : in  std_logic;
            address : in  integer range 0 to 255;
            dataout : out std_logic_vector(7 downto 0)
        );
    end component;

    component rw_96x8_sync is
        port (
            clock       : in  std_logic;
            reset       : in  std_logic;
            address_int : in  integer range 0 to 255;
            datain      : in  std_logic_vector(7 downto 0);
            write       : in  std_logic;
            dataout     : out std_logic_vector(7 downto 0)
        );
    end component;

    -- HEX decodificador de 4 bits, activo bajo
    function hex_to_7seg(hex: std_logic_vector(3 downto 0)) return std_logic_vector is
        variable segs : std_logic_vector(6 downto 0);
    begin
        case hex is
            when "0000" => segs := "1000000"; -- 0
            when "0001" => segs := "1111001"; -- 1
            when "0010" => segs := "0100100"; -- 2
            when "0011" => segs := "0110000"; -- 3
            when "0100" => segs := "0011001"; -- 4
            when "0101" => segs := "0010010"; -- 5
            when "0110" => segs := "0000010"; -- 6
            when "0111" => segs := "1111000"; -- 7
            when "1000" => segs := "0000000"; -- 8
            when "1001" => segs := "0010000"; -- 9
            when "1010" => segs := "0001000"; -- A
            when "1011" => segs := "0000011"; -- b
            when "1100" => segs := "1000110"; -- C
            when "1101" => segs := "0100001"; -- d
            when "1110" => segs := "0000110"; -- E
            when "1111" => segs := "0001110"; -- F
            when others => segs := "1111111"; -- blank
        end case;
        return segs;
    end function;

    signal rom_dataout      : std_logic_vector(7 downto 0);
    signal rw_dataout       : std_logic_vector(7 downto 0);
    signal dataout_internal : std_logic_vector(7 downto 0);
    signal address_int      : integer range 0 to 255;

    -- Registro para puerto de salida (conectado a LEDs)
    signal reg_port_out_00  : std_logic_vector(7 downto 0);

begin

    address_int <= to_integer(unsigned(address));

    -- Instancia de ROM 
    u_rom : rom_128x8_sync
        port map (
            clock   => clock,
            address => address_int,
            dataout => rom_dataout
        );

    -- Instancia de RAM 
    u_ram : rw_96x8_sync
        port map (
            clock       => clock,
            reset       => reset,
            address_int => address_int,
            datain      => datain,
            write       => write,
            dataout     => rw_dataout
        );

    -- Proceso para puerto de salida (LEDs) en dirección 0xE0
    process(clock, reset)
    begin
        if reset = '1' then
            reg_port_out_00 <= (others => '0');
        elsif rising_edge(clock) then
            if address = x"E0" and write = '1' then
                reg_port_out_00 <= datain;
            end if;
        end if;
    end process;

    port_out_00 <= reg_port_out_00;

    -- Multiplexor principal para data_out 
    process(address_int, rom_dataout, rw_dataout, reg_port_out_00, address)
    begin
        if address = x"F0" then
            dataout_internal <= x"E0"; -- Puerto de entrada fijo 
        elsif address_int <= 127 then
            dataout_internal <= rom_dataout;            -- ROM
        elsif address_int >= 128 and address_int <= 255 then
            dataout_internal <= rw_dataout;             -- RAM
        elsif address = x"E0" then
            dataout_internal <= reg_port_out_00;        -- Puerto de salida (LEDs)
        else
            dataout_internal <= (others => '0');
        end if;
    end process;

    dataout <= dataout_internal;

    -- 7-segment HEX displays
    hex3 <= hex_to_7seg(address(7 downto 4));
    hex2 <= hex_to_7seg(address(3 downto 0));
    hex1 <= hex_to_7seg(dataout_internal(7 downto 4));
    hex0 <= hex_to_7seg(dataout_internal(3 downto 0));

end architecture;
