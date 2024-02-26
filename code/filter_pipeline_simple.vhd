library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Coefficients of the FIR filter, in our case of order 12 so 13 coefficients
entity filter_pipeline_simple is
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

end filter_pipeline_simple;

architecture behavioural of filter_pipeline_simple is
  constant N_COEFFICIENTS : integer := 12;
  constant N_REG_PIPELINE : integer := 1;

  constant N_BITS_DATA : integer := 8;
  constant N_DIVISION  : integer := 9;  -- 2**N_DIVISION to divide the filter
  constant N_BITS_TEMP : integer := N_BITS_DATA + N_DIVISION;

  type shift_register_type is array (0 to N_COEFFICIENTS) of signed ((N_BITS_DATA - 1) downto 0);
  signal shift_registers : shift_register_type := (others => (others => '0'));

  type temp_type is array (0 to N_COEFFICIENTS) of signed ((N_BITS_TEMP - 1) downto 0);
  signal temp_registers : temp_type := (others => (others => '0'));

  type shift_pipeline_register_type is array (0 to N_REG_PIPELINE - 1) of signed ((N_BITS_DATA - 1) downto 0);
  signal shift_pipeline_registers : shift_pipeline_register_type := (others => (others => '0'));

  type temp_pipline_type is array (0 to N_REG_PIPELINE - 1) of signed ((N_BITS_TEMP - 1) downto 0);
  signal temp_pipeline_register : temp_type := (others => (others => '0'));

  constant COEFFICIENTS : shift_register_type := (
    to_signed(a0, N_BITS_DATA),
    to_signed(a1, N_BITS_DATA),
    to_signed(a2, N_BITS_DATA),
    to_signed(a3, N_BITS_DATA),
    to_signed(a4, N_BITS_DATA),
    to_signed(a5, N_BITS_DATA),
    to_signed(a6, N_BITS_DATA),
    to_signed(a7, N_BITS_DATA),
    to_signed(a8, N_BITS_DATA),
    to_signed(a9, N_BITS_DATA),
    to_signed(a10, N_BITS_DATA),
    to_signed(a11, N_BITS_DATA),
    to_signed(a12, N_BITS_DATA)
    );
begin
  process(Clk, Reset)
  begin
    if Reset = '1' then
      shift_registers <= (others => (others => '0'));
    elsif rising_edge(clk) then
      if enable = '1' then
        shift_registers(0) <= DataIn;
        shift_registers(1) <= shift_registers(0);
        shift_registers(2) <= shift_registers(1);
        shift_registers(3) <= shift_registers(2);
        shift_registers(4) <= shift_registers(3);
        shift_registers(5) <= shift_registers(4);
        shift_registers(6) <= shift_registers(5);

        -- pipeline critical zone split. We add a temp_pipeline_register from 6 to 7
        temp_registers(6)           <= temp_registers(5) + shift_registers(6) * COEFFICIENTS(6);
        shift_pipeline_registers(0) <= shift_registers(6);

        shift_registers(7)  <= shift_pipeline_registers(0);
        shift_registers(8)  <= shift_registers(7);
        shift_registers(9)  <= shift_registers(8);
        shift_registers(10) <= shift_registers(9);
        shift_registers(11) <= shift_registers(10);
        shift_registers(12) <= shift_registers(11);
      end if;
    end if;
  end process;

  temp_registers(0) <= resize(shift_registers(0) * COEFFICIENTS(0), N_BITS_TEMP);
  temp_registers(1) <= temp_registers(0) + shift_registers(1) * COEFFICIENTS(1);
  temp_registers(2) <= temp_registers(1) + shift_registers(2) * COEFFICIENTS(2);
  temp_registers(3) <= temp_registers(2) + shift_registers(3) * COEFFICIENTS(3);
  temp_registers(4) <= temp_registers(3) + shift_registers(4) * COEFFICIENTS(4);
  temp_registers(5) <= temp_registers(4) + shift_registers(5) * COEFFICIENTS(5);

  temp_registers(7)  <= temp_registers(6) + shift_registers(7) * COEFFICIENTS(7);
  temp_registers(8)  <= temp_registers(7) + shift_registers(8) * COEFFICIENTS(8);
  temp_registers(9)  <= temp_registers(8) + shift_registers(9) * COEFFICIENTS(9);
  temp_registers(10) <= temp_registers(9) + shift_registers(10) * COEFFICIENTS(10);
  temp_registers(11) <= temp_registers(10) + shift_registers(11) * COEFFICIENTS(11);
  temp_registers(12) <= temp_registers(11) + shift_registers(12) * COEFFICIENTS(12);

  DataOut <= temp_registers(12)((N_BITS_TEMP - 1) downto (N_DIVISION));

end behavioural;

-- The computed coefficients with matlab are the followings:
-- -0.02809454701043502533597262527109705843
--  0.000000000000000007024176997085506021788
-- 0.042141820515652538003958937906645587645
-- 0.090915863922831199883667352423799457029
-- 0.136373795884246834519970548171841073781
-- 0.168567282062610124260260135997668839991
-- 0.180191569250188837747472803130222018808
-- 0.168567282062610124260260135997668839991
-- 0.136373795884246834519970548171841073781
-- 0.090915863922831199883667352423799457029
-- 0.042141820515652538003958937906645587645
-- 0.000000000000000007024176997085506021788
-- -0.02809454701043502533597262527109705843
-- Our input and output are 8 bits signed numbers so the biggest absolute value is 2^7 = 128,
-- our biggest coefficient is 0.180191569250188837747472803130222018808,
-- so 0.180191569250188837747472803130222018808*2^k < 128; k<log2(128/0.180191569250188837747472803130222018808);
-- k = 9 bits.
-- After multiplying by 2^9 we get the following coefficients (we will divide by 2^9 in the end by taking the 9 MSB of the result):
-- -14, 0, 22, 47, 70, 86, 92, 86, 70, 47, 22, 0, -14
