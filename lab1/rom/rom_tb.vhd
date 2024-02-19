library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity rom_tb is
end entity rom_tb;

architecture sim of rom_tb is
  constant PERIOD         : time                 := 10 ns;  -- Simulation period
  signal time_instance_tb : unsigned(3 downto 0) := (others => '0');  -- Testbench stimulus
  signal sin_value_tb     : signed(7 downto 0);  -- Testbench monitored signal

  -- Instantiate the DUT (Device Under Test)
  component rom
    port (
      time_instance : in  unsigned(3 downto 0);
      sin_value     : out signed(7 downto 0)
      );
  end component;

begin
  -- Instantiate the DUT
  dut : rom
    port map (
      time_instance => time_instance_tb,
      sin_value     => sin_value_tb
      );

  -- Stimulus process
  stimulus_process : process
  begin
    for i in 0 to 15 loop
      time_instance_tb <= to_unsigned(i, 4);
      wait for PERIOD;
      report "sin_value = " & integer'image(to_integer(sin_value_tb));
    end loop;
    wait;
  end process;

end architecture sim;
