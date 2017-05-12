library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity button is
Port (
	clk : in std_logic;
	raw_input : in std_logic;
	debounced : out std_logic;
	press : out std_logic;
	release : out std_logic;
	toggle : out std_logic
);
end button;

architecture Behavioral of button is
	signal inp_arr : std_logic_vector(7 downto 0);
	signal low, high : std_logic;
	
	subtype S is std_logic_vector(3 downto 0);
	signal state : S := "0000";
	
	constant s0 : S := "0000";
	constant s1 : S := "1110";
	constant s2 : S := "1100";
	constant s3 : S := "1001";
	constant s4 : S := "1000";
	constant s5 : S := "0110";
	constant s6 : S := "0100";
	constant s7 : S := "0001";
begin

	high <= '1' when inp_arr = "11111111" else '0';
	low <= '1' when inp_arr = "00000000" else '0';
		
	process (clk)
	begin
		if rising_edge(clk) then
			inp_arr <= inp_arr(6 downto 0) & raw_input;
		
			case state is
				when s0 => if high = '1' then state <= s1; end if;
				when s1 => state <= s2;
				when s2 => if low = '1' then state <= s3; end if;
				when s3 => state <= s4;
				when s4 => if high = '1' then state <= s5; end if;
				when s5 => state <= s6;
				when s6 => if low = '1' then state <= s7; end if;
				when s7 => state <= s0;
				when others => null;
			end case;
		end if;
	end process;
	
	release <= state(0);
	press <= state(1);
	debounced <= state(2);
	toggle <= state(3);

end Behavioral;

