library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Coefficients of the FIR filter, in our case of order 12 so 13 coefficients
entity filter_parallel is
  generic (a0  : integer := 0;
           a1  : integer := 2;
           a2  : integer := 0;
           a3  : integer := -15;
           a4  : integer := 0;
           a5  : integer := 76;
           a6  : integer := 128;
           a7  : integer := 76;
           a8  : integer := 0;
           a9  : integer := -15;
           a10 : integer := 0;
           a11 : integer := 2;
           a12 : integer := 0
           );

  port (Clk     : in  std_logic;        --100MHz so we can count in 10ns
        Reset   : in  std_logic;
        DataIn  : in  signed (7 downto 0);
        Enable  : in  std_logic;
        DataOut : out signed (7 downto 0));

end filter_parallel;

architecture behavioural of filter_parallel is
  constant N_COEFFICIENTS : integer := 12;
  type shift_register_type is array (0 to N_COEFFICIENTS) of integer range -127 to 128;

  signal shift_registers : shift_register_type;

  constant COEFFICIENTS : shift_register_type := (
    a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12
    );

  signal output : signed (15 downto 0);

begin
  process(Clk, Reset)
  begin
    if Reset = '1' then
      -- temp(3) <= (others => '0');       -- Pipeline, see diagram
      for i in 0 to N_COEFFICIENTS loop
        shift_registers(i) <= 0;
      end loop;
      output <= (others => '0');

    elsif rising_edge(clk) then
      if enable = '1' then
        -- shift data in registers
        -- for i in N_COEFFICIENTS downto 1 loop
        --   shift_registers(i) <= shift_registers(i - 1);
        -- end loop;
        --
        shift_registers(0) <= to_integer(DataIn);
        shift_registers(1) <= shift_registers(0);
        shift_registers(2) <= shift_registers(1);

        -- calculate outpu
        -- output <= (others => '0');
        -- for i in 0 to N_COEFFICIENTS loop
        --   output <= output + COEFFICIENTS(i) * shift_registers(i);
        -- end loop;
      end if;
    end if;
  end process;

  DataOut <= output(15 downto 8);

end behavioural;

-- The computed coefficients with matlab are the followings:
-- -0.000000000000001485990817575209568847452
--  0.009713826664505794197812527102087187814
--  0.00000000000000143474975490020232873442
-- -0.058124387344871880634045169244927819818
-- -0.000000000000001076062316175151647943202
--  0.298594742640497901042806461191503331065
--  0.500000000000000999200722162640886381269
--  0.298594742640497901042806461191503331065
-- -0.000000000000001076062316175151647943202
-- -0.058124387344871880634045169244927819818
--  0.00000000000000143474975490020232873442
--  0.009713826664505794197812527102087187814
-- -0.000000000000001485990817575209568847452
-- Our input and output are 8 bits signed numbers so the biggest absolute value is 2^7 = 128,
-- our biggest coefficient is 0.5, so 0.5*2^k < 128; k<log2(128/0.5); k = 8 bits.
-- After multiplying by 2^8 we get the following coefficients (we will divide by 2^8 in the end by taking the 8 MSB of the result):
-- 0, 2, 0, -15, 0, 76, 128, 76, 0, -15, 0, 2, 0
