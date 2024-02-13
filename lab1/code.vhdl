library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity GenSen is
    port (Clk : in std_logic;
    Reset : in std_logic;
    per : in std_logic_vector(1 downto 0);
    led : out signed(7 downto 0);
    dac : out unsigned(7 downto 0)
    );
end GenSen;

architecture lab1 of GenSen is
    signal f: integer;


    PROCESS(per) --Multiplexer for the frequency
    BEGIN
        CASE per IS
        WHEN "00" => f <= 600;
        WHEN "01" => f <= 1000;
        WHEN "10" => f <= 2200;
        WHEN OTHERS => f <= 3900;
        END CASE;
    END PROCESS;

end lab1;

