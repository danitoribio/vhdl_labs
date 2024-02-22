library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FILTER_TestBench is
end FILTER_TestBench;

architecture tb_arch of FILTER_TestBench is
    -- Component declaration
    component FILTER
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
        port (Clk     : in  STD_LOGIC;
              Reset   : in  STD_LOGIC;
              DataIn  : in  SIGNED (7 downto 0);
              Enable  : in  STD_LOGIC;
              DataOut : out SIGNED (7 downto 0));
    end component;

    -- Clock process
    signal Clk : STD_LOGIC := '0';
    constant Clk_period : time := 10 ns;

    -- Signals for the test bench
    signal Reset   : STD_LOGIC := '0';
    signal DataIn  : SIGNED (7 downto 0) := (others => '0');
    signal Enable  : STD_LOGIC := '0';
    signal DataOut : SIGNED (7 downto 0);

begin
    -- Instantiate the FILTER module
    UUT: FILTER
        generic map (
            -- Provide the same coefficients as in the DUT
            a0  => 0,
            a1  => 2,
            a2  => 0,
            a3  => -15,
            a4  => 0,
            a5  => 76,
            a6  => 128,
            a7  => 76,
            a8  => 0,
            a9  => -15,
            a10 => 0,
            a11 => 2,
            a12 => 0
        )
        port map (
            Clk     => Clk,
            Reset   => Reset,
            DataIn  => DataIn,
            Enable  => Enable,
            DataOut => DataOut
        );

    -- Clock process definition
    Clk_Process: process
    begin
        while now < 5000 ns loop  -- Simulate for 5000 ns
            Clk <= '0';
            wait for Clk_period / 2;
            Clk <= '1';
            wait for Clk_period / 2;
        end loop;
        wait;
    end process Clk_Process;

    -- Stimulus process
    Stimulus_Process: process
    begin
        Reset <= '1';  -- Reset initially
        wait for 10 ns;
        Reset <= '0';  -- Deassert reset

        -- Add your test cases here
        -- Example:
        -- Enable <= '1';
        -- DataIn <= to_signed(10, DataIn'length); -- Sample input
        -- wait for 10 ns;
        -- assert DataOut = expected_output_variable report "Test failed!" severity error;

        wait;
    end process Stimulus_Process;

end tb_arch;
