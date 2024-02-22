library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FILTER is
--Coefficients of the FIR filter, in our case of order 12 so 13 coefficients
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
             a12 : integer := 0);
    port (Clk     : in  STD_LOGIC;      --100MHz so we can count in 10ns
          Reset   : in  STD_LOGIC;
          DataIn  : in  SIGNED (7 downto 0);
          Enable  : in  STD_LOGIC;
          DataOut : out SIGNED (7 downto 0));

end FILTER;


architecture lab2 of FILTER is
type data1 is array (0 to 12) of signed (7 downto 0); 
signal aX : data1; -- The flip flops that store the input data, x(n), x(n-1)...
type data2 is array (0 to 4) of signed (15 downto 0); 
signal temp : data2; -- The values between each multiplication and addition, where temp(3) is stored in the pipeline
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

process(Clk,Reset)
  begin
    if Reset='1' then 
      aX <= (others=> (others=>'0'));
      temp(3) <= (others=> '0');   -- Pipeline, see diagram
    elsif rising_edge(Clk) then 
      if enable='1' then 
        aX(0) <= DataIn; -- The values in the registers are updated at the rising edge of the clock
        aX(1) <= aX(0);         
        aX(2) <= aX(1); 
        aX(3) <= aX(2);         
        aX(4) <= aX(3);
        aX(5) <= aX(4);         
        aX(6) <= aX(5);
        aX(7) <= aX(6);         
        aX(8) <= aX(7);
        aX(9) <= aX(8);         
        aX(10) <= aX(9);
        aX(11) <= aX(10);         
        aX(12) <= aX(11);                             
        temp(3) <= temp(2) + a6*aX(6);   -- Pipeline
      end if; 
    end if; 
  end process; 
  
  temp(0) <=           A(0)*aX(0); 
  temp(1) <= temp(0) + A(1)*aX(1);     
  --temp(2) <= temp(1) + A(2)*aX(2);     
  
  temp(3) <= temp(2) + B(1)*aY(1);         
  temp(4) <= temp(3) + B(2)*aY(2);  
  combY   <= temp(4)(17 downto 8); 

end lab2;
