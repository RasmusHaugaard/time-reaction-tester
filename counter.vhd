library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity counter is
	Generic (
		size : integer
	);
	Port (
		clk : in STD_LOGIC;
		reset : in STD_LOGIC := '0';
		reset_val : in integer range 0 to size-1 := 0;
		enable : in STD_LOGIC := '1';
		value : inout integer range 0 to size-1 := 0;
		overflow : out std_LOGIC := '0'
	);
end counter;

architecture Behavioral of counter is
begin
	process (clk, reset, reset_val)
	begin
		if reset='1' then
			value <= reset_val;
			overflow <= '0';
		elsif rising_edge(clk) then
			overflow <= '0';
			if enable = '1' then
				if value = size - 1 then
					value <= 0;
					overflow <= '1';
				else
					value <= value + 1;
				end if;
			end if;
		end if;
	end process;
end Behavioral;

