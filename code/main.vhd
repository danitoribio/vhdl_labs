library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    per   : in  std_logic_vector(1 downto 0);
    led   : out signed(7 downto 0);
    dac   : out unsigned(7 downto 0)
    );
end main;

architecture behavioural of main is
  signal sine   : signed (7 downto 0);
  signal sine_filtered : signed (7 downto 0);

  constant MAX_COUNT : integer := 9999; -- f = 10kHz for the sampling.
  signal counter : integer range 0 to MAX_COUNT := 0;

  signal EoC_sampling : std_logic;

  component sine_generator is
    port (Clk   : in  std_logic;        --100MHz so we can count in 10ns
          Reset : in  std_logic;
          per   : in  std_logic_vector(1 downto 0);
          led   : out signed(7 downto 0);
          dac   : out unsigned(7 downto 0)
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
  sine_generator_inst : sine_generator
    port map(
      Clk   => clk,
      Reset => reset,
      per   => per,
      led   => sine,
      dac   => open
      );

  filter_parallel_inst : filter_parallel  -- Aqui hay que hacer generic map y quitar los valores default porque en el statement del lab nos lo dan sin valores default
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
      DataIn  => sine,
      Enable  => EoC_sampling,
      DataOut => sine_filtered
      );

  --Timer to count the time needed for sampling the sine before the filter
  process(clk, reset)
  begin
    if reset = '1' then
      counter <= 0;
    elsif clk'event and clk = '1' then
      if counter = MAX_COUNT then
        counter <= 0;
      else
        counter <= counter + 1;
      end if;
    end if;
  end process;

  --End of Counter to sample the sine for the filter
  EoC_sampling <= '1' when counter = MAX_COUNT else '0';

  led <= sine_filtered;
  dac <= to_unsigned(128, 8) + unsigned(sine_filtered);  --We add 128 to the led value to get the dac value

end behavioural;
