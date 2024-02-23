library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Coefficients of the FIR filter, in our case of order 12 so 13 coefficients
entity filter_parallel is
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

  port (Clk     : in  std_logic;        --100MHz so we can count in 10ns
        Reset   : in  std_logic;
        DataIn  : in  signed (7 downto 0);
        Enable  : in  std_logic;
        DataOut : out signed (7 downto 0));

end filter_parallel;

architecture behavioural of filter_parallel is
  constant N_COEFFICIENTS : integer := 12;

  type shift_register_type is array (0 to N_COEFFICIENTS) of signed (7 downto 0);
  signal shift_registers : shift_register_type := (others => (others => '0'));

  type temp_type is array (0 to N_COEFFICIENTS) of signed (15 downto 0);
  signal temp_registers : temp_type := (others => (others => '0'));

  constant COEFFICIENTS : temp_type := (
    to_signed(a0, 16),
    to_signed(a1, 16),
    to_signed(a2, 16),
    to_signed(a3, 16),
    to_signed(a4, 16),
    to_signed(a5, 16),
    to_signed(a6, 16),
    to_signed(a7, 16),
    to_signed(a8, 16),
    to_signed(a9, 16),
    to_signed(a10, 16),
    to_signed(a11, 16),
    to_signed(a12, 16)
    );

  signal output : signed (15 downto 0);

begin
  process(Clk, Reset)
  begin
    if Reset = '1' then
      -- temp(3) <= (others => '0');       -- Pipeline, see diagram
      shift_registers <= (others => (others => '0'));
      temp_registers <= (others => (others => '0'));
      output <= (others => '0');
    elsif rising_edge(clk) then
      if enable = '1' then
        shift_registers(0) <= DataIn;
        shift_registers(1) <= shift_registers(0);
        shift_registers(2) <= shift_registers(1);
        shift_registers(3) <= shift_registers(2);
        shift_registers(4) <= shift_registers(3);
        shift_registers(5) <= shift_registers(4);
        shift_registers(6) <= shift_registers(5);
        shift_registers(7) <= shift_registers(6);
        shift_registers(8) <= shift_registers(7);
        shift_registers(9) <= shift_registers(8);
        shift_registers(10) <= shift_registers(9);
        shift_registers(11) <= shift_registers(10);
        shift_registers(12) <= shift_registers(11);

        -- can I use for loops better?
        -- for i in 1 to N_COEFFICIENTS loop
        --   shift_registers(i) <= shift_registers(i-1);
        -- end loop;

        -- calculate output
        -- FIXME
        -- output <= (others => '0');
        -- for i in 0 to N_COEFFICIENTS loop -- Esto se puede cambiar para no usar un for loop (mirar el archivo del filtro de clase)
        --   output <= output + COEFFICIENTS(i) * shift_registers(i);
        -- end loop;
      end if;
    end if;
  end process;

  temp_registers(0) <= shift_registers(0) * COEFFICIENTS(0);
  temp_registers(1) <= shift_registers(1) * COEFFICIENTS(1);
  temp_registers(2) <= shift_registers(2) * COEFFICIENTS(2);
  temp_registers(3) <= shift_registers(3) * COEFFICIENTS(3);
  temp_registers(4) <= shift_registers(4) * COEFFICIENTS(4);
  temp_registers(5) <= shift_registers(5) * COEFFICIENTS(5);
  temp_registers(6) <= shift_registers(6) * COEFFICIENTS(6);
  temp_registers(7) <= shift_registers(7) * COEFFICIENTS(7);
  temp_registers(8) <= shift_registers(8) * COEFFICIENTS(8);
  temp_registers(9) <= shift_registers(9) * COEFFICIENTS(9);
  temp_registers(10) <= shift_registers(10) * COEFFICIENTS(10);
  temp_registers(11) <= shift_registers(11) * COEFFICIENTS(11);
  temp_registers(12) <= shift_registers(12) * COEFFICIENTS(12);
  DataOut <= temp_registers(12)(15 downto 8);

  -- DataOut <= output(15 downto 8);

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
