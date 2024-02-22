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

begin
end behavioural;
