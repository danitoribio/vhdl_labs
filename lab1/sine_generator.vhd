library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity GenSen is
  port (Clk   : in  std_logic;          --100MHz so we can count in 10ns
        Reset : in  std_logic;
        per   : in  std_logic_vector(1 downto 0);
        led   : out signed(7 downto 0);
        dac   : out unsigned(7 downto 0)
        );
end GenSen;

architecture lab1 of GenSen is
  signal MaxCount    : integer range 0 to 10417  := 0;  -- max count for the counter to count the frequency
  signal counter     : integer range 0 to 10417  := 0;  -- biggest case when f = 600 so 10417 cycles 
  signal rom_address : unsigned(3 downto 0);            -- address of the ROM
  signal rom_data    : signed(7 downto 0);              -- data of the ROM
  signal filtered_signal : signed(7 downto 0);          -- filtered signal
  signal enable: std_logic := '1';                      -- enable signal for the filter

  signal EoC : std_logic;  --End of Counter to change to the next address of the ROM

  component rom is
    port (
      time_instance : in  unsigned(3 downto 0) := (others => '0');
      sin_value     : out signed(7 downto 0)   := (others => '0')
      );
  end component;

  component FILTER is
    generic (
      a0 : integer := 0;
      a1 : integer := 0;
      a2 : integer := 0;
      a3 : integer := 0;
      a4 : integer := 0;
      a5 : integer := 0;
      a6 : integer := 0;
      a7 : integer := 0;
      a8 : integer := 0;
      a9 : integer := 0;
      a10 : integer := 0;
      a11 : integer := 0;
      a12 : integer := 0
      );
      port (
        Clk     : in  STD_LOGIC;      --100MHz so we can count in 10ns
        Reset   : in  STD_LOGIC;
        DataIn  : in  SIGNED (7 downto 0);
        Enable  : in  STD_LOGIC;
        DataOut : out SIGNED (7 downto 0)
        );
  end component;

begin
  --ROM instance
  ROM_inst : rom
    port map(
      time_instance => rom_address,
      sin_value     => rom_data
      );
  FIR_inst : FILTER
    generic map(
      a0=>0, 
      a1=>2, 
      a2=>0, 
      a3=>-15, 
      a4=>0, 
      a5=>76, 
      a6=>128, 
      a7=>76, 
      a8=>0, 
      a9=>-15, 
      a10=>0, 
      a11=>2, 
      a12=>0
      );
    port map(
      Clk     => Clk,
      Reset   => Reset,
      DataIn  => rom_data,
      Enable  => enable, -- This signal will be 1 when a new sine value has to be filtered
      DataOut => filtered_signal
    );

  -- Multiplexer to select the MaxCount
  -- We compute the period of the signal and 
  -- divide it by 16 to get the time of each sample
  -- and multiply it by the clk frequency to get the number of
  -- cycles necessary to get 1/16 of the period of the signal 
  PROCESS(per)
  BEGIN
    CASE per is  -- select the frequency of the signal based on the input per
      WHEN "00"   => MaxCount <= 10416;
      WHEN "01"   => MaxCount <= 6250;
      WHEN "10"   => MaxCount <= 2840;
      WHEN OTHERS => MaxCount <= 1602;
    END CASE;
  END PROCESS;

  --Timer to count the time needed for a sample
  process(clk, reset)
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

  --End of Counter to change to the next address of the ROM 
  EoC <= '1' when counter >= MaxCount else '0';

  process(clk, reset)                    --Counter for the address of the ROM
  begin
    if reset = '1' then
      rom_address <= (others => '0');
    elsif clk'event and clk = '1' then
      --We change the address of the ROM when the counter is at the end
      if EoC = '1' then
        rom_address <= rom_address + 1;  -- automatic to 0 due to overflow
      end if;

    end if;
  end process;

  led <= rom_data;                      --copy the data of the ROM to the led

  -- He comentado estos dos outputs porque hay que verlo en la simulacion, creo q la solucion final es el d dac2
  -- pero asi podemos hacer un plot con la senal original y la senal filtrada
  -- dac1 <= to_unsigned(128, 8) + unsigned(rom_data);  --We add 128 to the led value to get the dac value
  -- dac2 <= to_unsigned(128, 8) + unsigned(filtered_signal);  --We add 128 to the led value to get the dac value
end lab1;

