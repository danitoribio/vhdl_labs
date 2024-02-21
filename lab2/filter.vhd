library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FILTER is
    generic ( a0 : integer; --Coefficients of the FIR filter, in our case of order 12 so 13 coefficients
    a1 : integer;
    a2 : integer;
    a3 : integer;
    a4 : integer;
    a5 : integer;
    a6 : integer;
    a7 : integer;
    a8 : integer;
    a9 : integer;
    a10 : integer;
    a11 : integer;
    a12 : integer)
    port ( Clk : in STD_LOGIC; --100MHz so we can count in 10ns
    Reset : in STD_LOGIC;
    DataIn : in SIGNED (7 downto 0);
    Enable : in STD_LOGIC;
    DataOut: out SIGNED (7 downto 0));
   
   end FILTER;

architecture lab2 of FILTER is


begin
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

generic map(a0=>0, 
            a1=>2, 
            a2=>0, 
            a3=>-15, 
            a4=>0, 
            a5=>76, 
            a6=>128, 
            a7=>76, 
            a8=>0, 
            a9=>-15, 
            a10=>0, 
            a11=>2, 
            a12=>0);


end lab2;