library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity edice is 
    Port ( run: in std_logic;
           clr: in std_logic;
           rst: in std_logic;
           clk: in std_logic;
           cheat: in std_logic;
           display_7seg: out std_logic_vector(6 downto 0);
           cheat_in:in std_logic_vector(2 downto 0);
           Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0)-- 4 Anode signals
    ); 
end edice;

architecture arch of edice is
 -- uncomment below line to write to fpga
--constant PRESCALER_constant: unsigned(25 downto 0) := "00000101110111110000100010";

 -- comment below line to write to fpga
constant PRESCALER_constant: unsigned(25 downto 0) :=   "00000000000000000000000100";
signal fin,fout,fcheat_in,fcheat_out : unsigned (2 downto 0);
signal buff_display_7seg, buff_dice_7seg: unsigned (6 downto 0);
signal buff_cheat: std_logic;
signal PRESCALER: unsigned(25 downto 0) := (others => '0') ;
signal refresh_counter: unsigned (19 downto 0):= (others => '0');
signal refresh_counter_vector: std_logic_vector (19 downto 0) :=(others => '0')  ;
signal LED_activating_counter: std_logic_vector(1 downto 0);
begin


-------------------------------------------- Modified 3 bit Counter Start --------------------------------------------------------
-- state register section
process (rst,clk)
begin
    if(rst = '1') then
        fout <= (others=> '0');
        fcheat_out <= (others => '0');  
    elsif(rising_edge(clk)) then
    
    				if PRESCALER < PRESCALER_CONSTANT then
					PRESCALER <= PRESCALER + 1;
				else
					PRESCALER <= (others => '0');
					 fout <= fin;
					 fcheat_out <= fcheat_in;
				end if;
       
    end if;
end process;

buff_cheat <= '0' when ( cheat ='1' and cheat_in = "111") else
              '0' when ( cheat ='1' and cheat_in = "000") else
              '0' when ( cheat ='0' ) else
              '1'; 

--when run = 1, throw the dice
fin <=  "000" when ( clr = '1'  ) else
          fout when (run = '0' ) else 
         "000" when ( buff_cheat = '0' and fout >= "101" ) else
         fout + 1;


fcheat_in <=    "000" when ( clr = '1' ) else
                fcheat_out when ( run = '0') else
                unsigned (cheat_in)-1 when (fout ="111" or fout ="110") else
                fout;
                     
-------------------------------------------- Modified 3 bit Counter End --------------------------------------------------------


-------------------------------------------- 3 bit Decoder Start --------------------------------------------------------

with fcheat_out select
        buff_display_7seg <= "1001111" when "000" ,
                     "0010010" when "001" ,
                     "0000110" when "010" ,
                     "1001100" when "011" ,
                     "0100100" when "100" ,
                     "0100000" when "101" ,
                     "1111110" when others;

with fcheat_out select
        buff_dice_7seg <= "1111110" when "000" ,
                     "1101101" when "001" ,
                     "0110110" when "010" ,
                     "1001001" when "011" ,
                     "1001000" when "100" ,
                     "1000000" when "101" ,
                     "0110000" when others;
                     
                     

process(clk,rst)
begin 
    if(rst='1') then
        refresh_counter <= (others => '0');
    elsif(rising_edge(clk)) then
        refresh_counter <= refresh_counter + 1;
    end if;
end process;
 refresh_counter_vector <= std_logic_vector(refresh_counter);
 -- uncomment below line for writing to fpga
  --LED_activating_counter <= refresh_counter_vector(19 downto 18);
  -- comment below line when writing to fpga
  LED_activating_counter <= refresh_counter_vector(1 downto 0);
-- 4-to-1 MUX to generate anode activating signals for 4 LEDs 

process(LED_activating_counter)
begin
    case LED_activating_counter is
    when "00" =>
        Anode_Activate <= "0111"; 
        -- activate LED1 and Deactivate LED2, LED3, LED4
       display_7seg <= std_logic_vector(buff_display_7seg);

      
    when "01" =>
        Anode_Activate <= "1011"; 
        -- activate LED2 and Deactivate LED1, LED3, LED4
        display_7seg <= std_logic_vector(buff_dice_7seg);
      
    when "10" =>
        Anode_Activate <= "1101"; 
        -- activate LED3 and Deactivate LED2, LED1, LED4
        display_7seg <= "1111111";
      
    when others=>
        Anode_Activate <= "1110"; 
        -- activate LED4 and Deactivate LED2, LED3, LED1
         display_7seg <= "1111111";
         
    end case;
end process;

-------------------------------------------- 3 bit Decoder End --------------------------------------------------------

end arch; 
