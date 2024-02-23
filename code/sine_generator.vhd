library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sine_generator is
  port (Clk   : in  std_logic;          --100MHz so we can count in 10ns
        Reset : in  std_logic;
        per   : in  std_logic_vector(1 downto 0);
        led   : out signed(7 downto 0);
        dac   : out unsigned(7 downto 0)
        );
end sine_generator;

architecture behavioural of sine_generator is
  signal MaxCount    : integer range 0 to 10417 := 0;  -- max count for the counter to count the frequency
  signal counter     : integer range 0 to 10417 := 0;  -- biggest case when f = 600 so 10417 cycles
  signal rom_address : unsigned(3 downto 0);           -- address of the ROM
  signal rom_data    : signed(7 downto 0);             -- data of the ROM

  signal EoC : std_logic;  --End of Counter to change to the next address of the ROM

  signal output : signed(7 downto 0);   --output of the filter

  component rom is
    port (
      time_instance : in  unsigned(3 downto 0) := (others => '0');
      sin_value     : out signed(7 downto 0)   := (others => '0')
      );
  end component;

  component filter_parallel is
    generic (a0  : integer;
             a1  : integer;
             a2  : integer;
             a3  : integer;
             a4  : integer;
             a5  : integer;
             a6  : integer;
             a7  : integer;
             a8  : integer;
             a9  : integer;
             a10 : integer;
             a11 : integer;
             a12 : integer
             );

    port (Clk     : in  std_logic;      --100MHz so we can count in 10ns
          Reset   : in  std_logic;
          DataIn  : in  signed (7 downto 0);
          Enable  : in  std_logic;
          DataOut : out signed (7 downto 0));
  end component;

begin
  --ROM instance
  rom_inst : rom
    port map(
      time_instance => rom_address,
      sin_value     => rom_data
      );

  --Filter instance
  filter_parallel_inst : filter_parallel
    generic map (
      a0  => -7,
      a1  => 0,
      a2  => 11,
      a3  => 23,
      a4  => 35,
      a5  => 43,
      a6  => 46,
      a7  => 43,
      a8  => 35,
      a9  => 23,
      a10 => 11,
      a11 => 0,
      a12 => -7
      )
    port map(
      Clk     => clk,
      Reset   => reset,
      DataIn  => rom_data,
      Enable  => EoC,
      DataOut => output
      );

  -- Multiplexer to select the MaxCount
  -- We compute the period of the signal and
  -- divide it by 16 to get the time of each sample
  -- and multiply it by the clk frequency to get the number of
  -- cycles necessary to get 1/16 of the period of the signal
  process(per)
  begin
    case per is  -- select the frequency of the signal based on the input per
      when "00"   => MaxCount <= 10416;
      when "01"   => MaxCount <= 6250;
      when "10"   => MaxCount <= 2840;
      when others => MaxCount <= 1602;
    end case;
  end process;

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

  led <= output;
  dac <= to_unsigned(128, 8) + unsigned(output);  --We add 128 to the led value to get the dac value
end behavioural;
