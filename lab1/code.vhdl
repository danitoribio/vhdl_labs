library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity GenSen is
    port (Clk : in std_logic; --100MHz so we can count in 10ns
    Reset : in std_logic;
    per : in std_logic_vector(1 downto 0);
    led : out signed(7 downto 0);
    dac : out unsigned(7 downto 0)
    );
end GenSen;

architecture lab1 of GenSen is
    signal f: integer;
    signal MaxCount: integer;    
    signal counter:unsigned(13 downto 0);-- Biggest case when f = 600 so 10417 cycles to count
                                        -- which are 14 bits
        
begin

    PROCESS(per) --Multiplexer for the frequency
        BEGIN
            CASE per IS
            WHEN "00" => f <= 600;
            WHEN "01" => f <= 1000;
            WHEN "10" => f <= 2200;
            WHEN OTHERS => f <= 3900;
            END CASE;
    END PROCESS;

    --Calculation of the MaxCount
    process(f)
        begin
            MaxCount <= 100000000/(16*f); -- We compute the period of the signal and 
                                  -- divide it by 16 to get the time of each sample
                                  -- and multiply it by the clk frequency to get the number of
                                  -- cycles necessary to get 1/16 of the period of the signal 
    end process;
        
    process(clk, reset)
        begin
        if reset = '1' then
            counter<=(others => '0');
        elsif clk'event and clk = '1' then
                if counter = MaxCount then --Used to count 1/16 of the period of the signal
                counter<=(others => '0');
                else
                counter <= counter + 1;
                end if;    
        end if;
    end process;
            
    EoC <='1' when counter = MaxCount else '0'; --End of Counter

end lab1;

