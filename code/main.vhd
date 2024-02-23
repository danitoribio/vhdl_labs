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
  signal output : signed (7 downto 0);

  component sine_generator is
    port (Clk   : in  std_logic;        --100MHz so we can count in 10ns
          Reset : in  std_logic;
          per   : in  std_logic_vector(1 downto 0);
          led   : out signed(7 downto 0);
          dac   : out unsigned(7 downto 0)
          );
  end component;

  component filter_parallel is
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

  filter_parallel_inst : filter_parallel -- Aqui hay que hacer generic map y quitar los valores default porque en el statement del lab nos lo dan sin valores default
    port map(
      Clk     => clk,
      Reset   => reset,
      DataIn  => sine,
      Enable  => '1',
      DataOut => output
      );

  led <= output; -- El led creo q sigue teniendo el valor del lab1
  dac <= to_unsigned(128, 8) + unsigned(output);  --We add 128 to the led value to get the dac value

end behavioural;
