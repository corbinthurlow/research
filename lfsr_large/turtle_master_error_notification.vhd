library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity turtle_master_error_notification is
    Port ( 
        clk         : in  std_logic;
        error       : in  std_logic;
        led         : out std_logic_vector (7 downto 0)
    );
end turtle_master_error_notification;

architecture Behavioral of turtle_master_error_notification is
    signal error_led_cnt        : unsigned (23 downto 0);
begin

    -- Error Notification
    process (clk) is
    begin
        if rising_edge(clk) then
            if error = '0' then
                error_led_cnt <= (others=>'0');
            elsif error='1' then
                error_led_cnt <= error_led_cnt + 1;
            end if;
        end if;
    end process;
    led <= (others=>error_led_cnt(23));


end Behavioral;
