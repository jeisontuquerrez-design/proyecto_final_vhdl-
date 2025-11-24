library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_test_system is
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        op_sel      : in  std_logic;  -- 1 switch: 0=suma, 1=resta
        input_a     : in  std_logic_vector(7 downto 0);
        input_b     : in  std_logic_vector(7 downto 0);
        flags_led   : out std_logic_vector(3 downto 0);
        disp_a_hi   : out std_logic_vector(6 downto 0);
        disp_a_lo   : out std_logic_vector(6 downto 0);
        disp_b_hi   : out std_logic_vector(6 downto 0);
        disp_b_lo   : out std_logic_vector(6 downto 0);
        disp_res_hi : out std_logic_vector(6 downto 0);
        disp_res_lo : out std_logic_vector(6 downto 0)
    );
end entity;

architecture structural of alu_test_system is
    signal alu_result : std_logic_vector(7 downto 0);
    signal nzvc_flags : std_logic_vector(3 downto 0);
    signal reg_a      : std_logic_vector(7 downto 0);
    signal reg_b      : std_logic_vector(7 downto 0);
    
    component alu is
        port (
            A       : in  std_logic_vector(7 downto 0);
            B       : in  std_logic_vector(7 downto 0);
            ALU_Sel : in  std_logic;
            Result  : out std_logic_vector(7 downto 0);
            NZVC    : out std_logic_vector(3 downto 0)
        );
    end component;
    
    component hex_to_7seg is
        port (
            hex_value : in  std_logic_vector(3 downto 0);
            seg_out   : out std_logic_vector(6 downto 0)
        );
    end component;
    
begin
    -- Registros para A y B
    process(clk, reset)
    begin
        if reset = '0' then
            reg_a <= (others => '0');
            reg_b <= (others => '0');
        elsif rising_edge(clk) then
            reg_a <= input_a;
            reg_b <= input_b;
        end if;
    end process;
    
    -- Instancia de la ALU
    alu_inst: alu
        port map (
            A       => reg_a,
            B       => reg_b,
            ALU_Sel => op_sel,
            Result  => alu_result,
            NZVC    => nzvc_flags
        );
    
    -- Displays para A (2 dígitos hexadecimales)
    disp_a_high: hex_to_7seg port map (reg_a(7 downto 4), disp_a_hi);
    disp_a_low:  hex_to_7seg port map (reg_a(3 downto 0), disp_a_lo);
    
    -- Displays para B (2 dígitos hexadecimales)
    disp_b_high: hex_to_7seg port map (reg_b(7 downto 4), disp_b_hi);
    disp_b_low:  hex_to_7seg port map (reg_b(3 downto 0), disp_b_lo);
    
    -- Displays para Resultado (2 dígitos hexadecimales)
    disp_res_high: hex_to_7seg port map (alu_result(7 downto 4), disp_res_hi);
    disp_res_low:  hex_to_7seg port map (alu_result(3 downto 0), disp_res_lo);
    
    -- LEDs para banderas NZVC
    flags_led <= nzvc_flags;
    
end architecture;