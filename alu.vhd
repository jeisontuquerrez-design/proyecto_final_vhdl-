library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port (
        A       : in  std_logic_vector(7 downto 0);
        B       : in  std_logic_vector(7 downto 0);
        ALU_Sel : in  std_logic;  -- 0: suma, 1: resta
        Result  : out std_logic_vector(7 downto 0);
        NZVC    : out std_logic_vector(3 downto 0)  -- N, Z, V, C
    );
end entity;

architecture behavioral of alu is
    signal result_int : std_logic_vector(7 downto 0);
begin
    ALU_PROCESS : process (A, B, ALU_Sel)
        variable Sum_uns  : unsigned(8 downto 0);
        variable Diff_uns : unsigned(8 downto 0);
    begin
        if ALU_Sel = '0' then
            -- SUMA (A + B)
            Sum_uns := unsigned('0' & A) + unsigned('0' & B);
            result_int <= std_logic_vector(Sum_uns(7 downto 0));
            
            -- Banderas para SUMA
            NZVC(3) <= Sum_uns(7);  -- N flag
            if (Sum_uns(7 downto 0) = x"00") then
                NZVC(2) <= '1';     -- Z flag
            else
                NZVC(2) <= '0';
            end if;
            -- V flag para suma
            if ((A(7)='0' and B(7)='0' and Sum_uns(7)='1') or
                (A(7)='1' and B(7)='1' and Sum_uns(7)='0')) then
                NZVC(1) <= '1';
            else
                NZVC(1) <= '0';
            end if;
            NZVC(0) <= Sum_uns(8);  -- C flag
            
        else
            -- RESTA (A - B)
            Diff_uns := unsigned('0' & A) - unsigned('0' & B);
            result_int <= std_logic_vector(Diff_uns(7 downto 0));
            
            -- Banderas para RESTA
            NZVC(3) <= Diff_uns(7);  -- N flag
            if (Diff_uns(7 downto 0) = x"00") then
                NZVC(2) <= '1';      -- Z flag
            else
                NZVC(2) <= '0';
            end if;
            -- V flag para resta
            if ((A(7)='0' and B(7)='1' and Diff_uns(7)='1') or
                (A(7)='1' and B(7)='0' and Diff_uns(7)='0')) then
                NZVC(1) <= '1';
            else
                NZVC(1) <= '0';
            end if;
            NZVC(0) <= not Diff_uns(8);  -- C flag (borrow)
        end if;
    end process;
    
    Result <= result_int;
end architecture;