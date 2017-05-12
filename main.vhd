library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main is Port ( 
	clk : in  STD_LOGIC;
   An : out  STD_LOGIC_VECTOR (3 downto 0);
   Ca : out  STD_LOGIC_VECTOR (7 downto 0);
   LD0 : out std_logic;
   BTN0 : in std_logic
);
end main;

architecture Behavioral of main is

subtype S is integer range 0 to 3;
constant state_idle : S := 0;
constant state_delay : S := 1;
constant state_counting : S := 2;
constant state_score : S := 3;

signal state : S := state_idle;

signal highscore : std_logic_vector(15 downto 0) := "1001100110011001"; --9999
constant zeros : std_logic_vector(15 downto 0) := "0000000000000000";
signal cnt, seg : std_logic_vector(15 downto 0);

signal p10KHz, p1KHz : std_logic := '0';
signal btn_press, btn_release : std_logic;

constant delay_max : integer := 4000; --ms
constant delay_min : integer := 1000; --ms
signal delay_o, delay_r, delay_en, delay_en0 : std_logic;
constant delay_rand_size : integer := delay_max - delay_min;
signal delay_rand : integer range 0 to delay_rand_size - 1;

constant scoretime : integer := 3000; --ms
signal scoretime_o, scoretime_r : std_logic;

signal cnt_r, cnt_en, cnt_en0, cnt_o : std_logic;

begin

LD0 <= '1' when state = state_delay or state = state_score else '0';

delay_r <= '0' when state = state_delay else '1';
delay_en <= '1' when state = state_delay else '0';

scoretime_r <= '0' when state = state_score else '1';

cnt_r <= '1' when state = state_idle else '0';
cnt_en <= '1' when state = state_counting else '0';

seg <= highscore when state = state_idle else
		 zeros when state = state_delay else
		 cnt;

process (clk)
begin
	if rising_edge(clk) then
		case state is
			when state_idle => 
				if btn_release = '1' then
					state <= state_delay;
				end if;
			when state_delay =>
				if btn_press = '1' then
					state <= state_idle;
				elsif delay_o = '1' then
					state <= state_counting;
				end if;
			when state_counting => 
				if btn_press = '1' then
					state <= state_score;
				elsif cnt_o = '1' then
					state <= state_idle;
				end if;
			when state_score =>
				if scoretime_o = '1' then
					state <= state_idle;
					if cnt < highscore then
						highscore <= cnt;
					end if;
				end if;
			when others => null;
		end case;
	end if;
end process;

prescaler_10Khz: entity work.counter Generic map(size => 5000) Port map(
	clk => Clk,
	overflow => p10KHz
);

BUTTON0 : entity work.button Port map(
	clk => p10KHz,
	raw_input => BTN0,
	press => btn_press,
	release => btn_release
);

prescaler_1Khz: entity work.counter Generic map(size => 50000) Port map(
	clk => clk,
	overflow => p1KHz
);

delay_en0 <= '1' when p1KHz = '1' and delay_en = '1' else '0';
cnt_delay : entity work.counter generic map(size => delay_max) port map(
	clk => clk,
	enable => delay_en0,
	overflow => delay_o,
	reset => delay_r,
	reset_val => delay_rand
);

cnt_delay_rand : entity work.counter generic map(size => delay_rand_size) port map(
	clk => clk,
	value => delay_rand
);

cnt_scoretimer : entity work.counter generic map(size => scoretime) port map(
	clk => clk,
	enable => p1KHz,
	reset => scoretime_r,
	overflow => scoretime_o
);

cnt_en0 <= '1' when p1KHz = '1' and cnt_en = '1' else '0';
cnt4 : entity work.counter4 port map(
	clk => clk,
	enable => cnt_en0,
	reset => cnt_r,
	v0 => cnt(3 downto 0), 
	v1 => cnt(7 downto 4), 
	v2 => cnt(11 downto 8),
	v3 => cnt(15 downto 12),
	overflow => cnt_o
);

mux : entity work.seg7_mux4 port map(
	clk_50MHz => clk,
	An => An,
	Ca => Ca,
	Dp => "1111",
	Hex0 => seg(3 downto 0),
	Hex1 => seg(7 downto 4),
	Hex2 => seg(11 downto 8),
	Hex3 => seg(15 downto 12)
);

end Behavioral;