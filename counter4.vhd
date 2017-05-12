library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity counter4 is port(
	clk : in std_logic;
	enable : in std_logic := '1';
	reset : in std_logic := '0';
	v0 : out std_logic_vector(3 downto 0);
	v1 : out std_logic_vector(3 downto 0);
	v2 : out std_logic_vector(3 downto 0);
	v3 : out std_logic_vector(3 downto 0);
	overflow : out std_logic
);
end counter4;

architecture Behavioral of counter4 is

signal i0 : integer range 0 to 9;
signal i1 : integer range 0 to 9;
signal i2 : integer range 0 to 9;
signal i3 : integer range 0 to 9;

signal o0 : std_logic;
signal o1 : std_logic;
signal o2 : std_logic;

begin

v0 <= std_logic_vector(to_unsigned(i0, 4));
v1 <= std_logic_vector(to_unsigned(i1, 4));
v2 <= std_logic_vector(to_unsigned(i2, 4));
v3 <= std_logic_vector(to_unsigned(i3, 4));

val_cnt0 : entity work.counter generic map(size => 10) Port map(
	clk => clk,
	enable => enable,
	reset => reset,
	value => i0,
	overflow => o0
);

val_cnt1 : entity work.counter generic map(size => 10) Port map(
	clk => clk,
	enable => o0,
	reset => reset,
	value => i1,
	overflow => o1
);

val_cnt2 : entity work.counter generic map(size => 10) Port map(
	clk => clk,
	enable => o1,
	reset => reset,
	value => i2,
	overflow => o2
);

val_cnt3 : entity work.counter generic map(size => 10) Port map(
	clk => clk,
	enable => o2,
	reset => reset,
	value => i3,
	overflow => overflow
);

end Behavioral;

