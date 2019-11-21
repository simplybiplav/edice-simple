library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity edice_test is
end edice_test;


architecture behaviour of edice_test is
constant CLK_PERIOD: time :=10*4 ns;
constant STATE_WAIT_TIME: time :=10*4 ns;
constant RUN_WAIT_TIME: time := 20*4 ns;

component edice
    Port ( run: in std_logic;
           clr: in std_logic;
           rst: in std_logic;
           clk: in std_logic;
           cheat: in std_logic;
           display_7seg: out std_logic_vector(6 downto 0);
           cheat_in:in std_logic_vector(2 downto 0);
           Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0)-- 4 Anode signals
    ); 
end component;

signal en:  std_logic;
signal clr:  std_logic;
signal rst:  std_logic;
signal clk:  std_logic;
signal cheat:  std_logic;
signal display_7seg: std_logic_vector(6 downto 0);
signal cheat_in: std_logic_vector(2 downto 0);
signal Anode_Activate : STD_LOGIC_VECTOR (3 downto 0);-- 4 Anode signals




begin

utt: edice port map(
run => en,
clr => clr,
rst => rst,
clk => clk,
cheat => cheat,
display_7seg => display_7seg,
cheat_in => cheat_in,
Anode_Activate => Anode_Activate 
);


clk_process: process
begin
    clk <= '0' ;
    wait for CLK_PERIOD/2;
    clk <= '1' ;
    wait for CLK_PERIOD/2;
end process;

io_process: process
begin
        en <= '0';
        clr <= '0';
        rst <= '0';
        cheat <= '0';
        --display_7seg <= "0000000";
        --dice_7seg <= "0000000";
        cheat_in <= "011";

        rst <= '1';
        clr <= '1';
        wait for STATE_WAIT_TIME;
        rst <= '0';
        clr <= '0';

        en <= '1';
        wait for STATE_WAIT_TIME * 10;

        en <= '0';
        wait for STATE_WAIT_TIME * 5;

        cheat <= '1';
        en <= '1';
        wait for STATE_WAIT_TIME * 10;

        en <= '0';
        wait for STATE_WAIT_TIME * 5;

        cheat_in <= "111";
        en <= '1';
        wait for STATE_WAIT_TIME * 10;

        en <= '0';
        wait for STATE_WAIT_TIME * 5;

        cheat <= '0';
end process;







end;
