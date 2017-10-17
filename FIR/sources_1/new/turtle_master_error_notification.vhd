library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity turtle_master_error_notification is
    Port ( 
        clk                 : in  std_logic;
        sync_error          : in  std_logic_vector (2 downto 0);
        cmp_error           : in  std_logic_vector (2 downto 0);
        system_failure      : in  std_logic;
        nexys_led           : out std_logic_vector (7 downto 0);
        fmc_led             : out std_logic_vector (1 downto 0)
    );
end turtle_master_error_notification;

architecture Behavioral of turtle_master_error_notification is
    signal error_led_cnt        : unsigned (23 downto 0) := (others => '0');
begin

    -- Blinking light generator
    process (clk) is
    begin
        if rising_edge(clk) then
            error_led_cnt <= error_led_cnt + 1;
        end if;
    end process;
    
    -- Output signals
    fmc_led <= error_led_cnt(23) & not(error_led_cnt(23)) when system_failure = '1' else "00";
    nexys_led <= system_failure & '0' & cmp_error & sync_error;

end Behavioral;
