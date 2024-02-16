library ieee;
-- library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use work.rom_package.all;

entity GenSen is
    port (Clk : in  std_logic;          --100MHz so we can count in 10ns
    Reset     : in  std_logic;
    per       : in  std_logic_vector(1 downto 0);
    led       : out signed(7 downto 0);
    dac       : out unsigned(7 downto 0)
    );
end GenSen;

architecture lab1 of GenSen is
    signal f           : integer range 600 to 3900 := 600;  --Frequency of the signal
    signal MaxCount    : integer range 0 to 10417  := 0;  --Max count for the counter
    signal counter     : integer range 0 to 10417  := 0;  -- Biggest case when f = 600 so 10417 cycles 
    signal rom_address : unsigned(3 downto 0);
    signal rom_data    : signed(7 downto 0);

    signal EoC : std_logic;             --End of Counter  

    component rom is
     port (
       time_instance : in  unsigned(3 downto 0) := (others => '0');  -- time instant to select the sine (16 different times)
       sin_value     : out signed(7 downto 0)   := (others => '0')  -- value of the sine wave at each time instant
     );
    end component;


begin
    --ROM
    ROM_inst : rom
        port map(
            time_instance => rom_address,
            sin_value     => rom_data
        );

    PROCESS(per)                        --Multiplexer for the frequency
        BEGIN
            CASE per IS
            WHEN "00"   => f <= 600;
            WHEN "01"   => f <= 1000;
            WHEN "10"   => f <= 2200;
            WHEN OTHERS => f <= 3900;
            END CASE;
    END PROCESS;

    --Calculation of the MaxCount
    process(f)
        begin
            MaxCount <= 100000000/(16*f);  -- We compute the period of the signal and 
                                  -- divide it by 16 to get the time of each sample
                                  -- and multiply it by the clk frequency to get the number of
                                  -- cycles necessary to get 1/16 of the period of the signal 
    end process;

    process(clk, reset)  --Timer to count the time needed for a sample
        begin
        if reset = '1' then
            counter <= 0;
        elsif clk'event and clk = '1' then
                if counter >= MaxCount then  --Used to count 1/16 of the period of the signal
                counter <= 0;

                else
                counter <= counter + 1;
                end if;


        end if;
    end process;

    EoC <= '1' when counter >= MaxCount else '0';  --End of Counter


    process(clk, reset)                 --Counter for the address of the ROM
        begin
        if reset = '1' then
            rom_address <= (others => '0');
        elsif clk'event and clk = '1' then
            if EoC = '1' then
                    rom_address <= rom_address + 1;  -- automatic to 0 due to overflow
            end if;

        end if;
    end process;

    -- process(rom_address)
    -- begin
    --   rom_data <= rom_data(to_integer(rom_address)); --We get the data from the ROM
    -- end process;

    led <= rom_data;
    dac <= to_unsigned(128, 8) + unsigned(rom_data);  --We add 128 to the led value to get the dac value


end lab1;

