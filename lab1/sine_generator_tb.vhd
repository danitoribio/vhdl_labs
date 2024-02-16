library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sine_generator_tb is
end entity sine_generator_tb;

architecture sim of sine_generator_tb is
  constant CLOCK_PERIOD      : time := 10 ns;  -- Clock period (100MHz)
  constant SIMULATION_PERIOD : time := 10 ms;

  signal Clk_tb   : std_logic                    := '0';  -- Test bench clock signal
  signal Reset_tb : std_logic                    := '0';  -- Test bench reset signal
  signal per_tb   : std_logic_vector(1 downto 0) := "00";  -- Test bench input per signal
  signal led_tb   : signed(7 downto 0);    -- Test bench output led signal
  signal dac_tb   : unsigned(7 downto 0);  -- Test bench output dac signal

  component GenSen
    port (
      Clk   : in  std_logic;
      Reset : in  std_logic;
      per   : in  std_logic_vector(1 downto 0);
      led   : out signed(7 downto 0);
      dac   : out unsigned(7 downto 0)
      );
  end component;

begin

  -- Instantiate the unit under test
  UUT : GenSen
    port map (
      Clk   => Clk_tb,
      Reset => Reset_tb,
      per   => per_tb,
      led   => led_tb,
      dac   => dac_tb
      );

  -- Clock generation process
  clk_process : process
  begin
    while now < SIMULATION_PERIOD loop  -- Simulate for 10 us
      Clk_tb <= '0';
      wait for CLOCK_PERIOD / 2;
      Clk_tb <= '1';

      wait for CLOCK_PERIOD / 2;
    end loop;
    wait;
  end process;

  -- Stimulus process
  stimulus_process : process
  begin
    -- Reset
    Reset_tb <= '1';
    wait for 10 ns;
    Reset_tb <= '0';
    wait for 10 ns;

    -- Test cases with different values for per
    for i in 0 to 3 loop
      wait for CLOCK_PERIOD;
      per_tb <= std_logic_vector(to_unsigned(i, per_tb'length));  -- Increase per by 1
      wait for SIMULATION_PERIOD / 4;
      report "per_tb = " & integer'image(to_integer(unsigned(per_tb)));

    end loop;
    wait for 100 ns;                -- Wait some time
    wait;
  end process;

end sim;
