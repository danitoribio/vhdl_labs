library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main_tb is
end entity main_tb;

architecture sim of main_tb is
  constant CLOCK_PERIOD      : time := 10 ns;    -- Clock period (100MHz)
  constant CLOCK_SEMIPERIOD  : time := CLOCK_PERIOD / 2;  -- Clock period (100MHz)
  constant SIMULATION_PERIOD : time := 6754 us;  -- Simulation period (67.54ms) 8 periods of the given frequencies

  constant N_FREQUENCIES : integer         := 4;
  type wait_array_type is array (0 to (N_FREQUENCIES - 1)) of time;
  constant WAIT_ARRAY    : wait_array_type := (3333 us, 2 ms, 909 us, 512 ms);  -- Wait times for each frequency to simulate 2 periods

  signal Clk_tb   : std_logic                    := '0';  -- Test bench clock signal
  signal Reset_tb : std_logic                    := '0';  -- Test bench reset signal
  signal per_tb   : std_logic_vector(1 downto 0) := "00";  -- Test bench input per signal
  signal led_tb   : signed(7 downto 0);    -- Test bench output led signal
  signal dac_tb   : unsigned(7 downto 0);  -- Test bench output dac signal

  component main is
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      per   : in  std_logic_vector(1 downto 0);
      led   : out signed(7 downto 0);
      dac   : out unsigned(7 downto 0)
      );
  end component;

begin

  -- Instantiate the unit under test
  UUT : main
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
    while now < SIMULATION_PERIOD loop
      Clk_tb <= '0';
      wait for CLOCK_SEMIPERIOD;
      Clk_tb <= '1';
      wait for CLOCK_SEMIPERIOD;
    end loop;
    wait;
  end process;

  -- Stimulus process
  stimulus_process : process
  begin
    -- Reset the unit under test
    Reset_tb <= '1';
    wait for CLOCK_PERIOD;
    Reset_tb <= '0';
    wait for CLOCK_PERIOD;

    -- Test cases with different values for per
    for i in 0 to (N_FREQUENCIES - 1) loop
      per_tb <= std_logic_vector(to_unsigned(i, per_tb'length));  -- Increase per by 1
      wait for WAIT_ARRAY(i);  -- Wait for the given period for the specific frequency

    end loop;
    assert false report "End of simulation. Not an error" severity failure;
    wait;
  end process;

end sim;
