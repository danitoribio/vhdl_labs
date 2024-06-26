library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
    port (
        time_instance : in  unsigned(3 downto 0) := (others => '0');  -- time instant to select the sine (16 different times)
        sin_value     : out signed(7 downto 0)   := (others => '0')  -- value of the sine wave at each time instant
        );
end rom;

architecture behavioural of rom is
    type rom_type is array (0 to 15) of signed (7 downto 0);  -- type array of 16 signed 8-bit values

    signal rom_values : rom_type := (  -- values of the sine wave at each time instant (16 different times)
        to_signed(0, 8),
        to_signed(48, 8),
        to_signed(89, 8),
        to_signed(117, 8),
        to_signed(127, 8),
        to_signed(117, 8),
        to_signed(89, 8),
        to_signed(48, 8),
        to_signed(0, 8),
        to_signed(-48, 8),
        to_signed(-89, 8),
        to_signed(-117, 8),
        to_signed(-127, 8),
        to_signed(-117, 8),
        to_signed(-89, 8),
        to_signed(-48, 8)
        );
begin
    sin_value <= rom_values(to_integer(time_instance));  -- assign the value of the sine wave for the selected time instant

end behavioural;

-- Code to get the values for the sign in Python
-- import math
--
-- # Define parameters
-- amplitude = 127
-- frequency = 1  # Adjust frequency as needed
-- num_points = 16
--
-- # Generate values
-- values = []
-- for t in range(num_points):
--     values.append((int) (amplitude * math.sin((2 * math.pi * t) / num_points)))
--
-- # Print the values
-- for i, val in enumerate(values):
--     print(f"f(t_{i}) =", val)
