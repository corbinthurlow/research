library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use WORK.VOTER_PKG.ALL;

entity turtle_master_error_detection is
    generic (
        RESPONSE_WIDTH      : integer;
        LOG_VALUE_WIDTH     : integer := 32;
        LOG_ENTRY_VALUES    : integer := 4;
        LOG_LENGTH          : integer := 8
    );
    Port ( 
        clk                 : in  std_logic;
        reset               : in  std_logic;
        error_clear         : in  std_logic;
        master_response     : in  std_logic_vector (RESPONSE_WIDTH-1 downto 0);
        slave_response_a    : in  std_logic_vector (RESPONSE_WIDTH-1 downto 0);
        slave_response_b    : in  std_logic_vector (RESPONSE_WIDTH-1 downto 0);
        slave_response_c    : in  std_logic_vector (RESPONSE_WIDTH-1 downto 0);
        comparison_log      : out std_logic_vector (LOG_LENGTH*(LOG_ENTRY_VALUES*LOG_VALUE_WIDTH)-1 downto 0);
        cmp_error           : out std_logic_vector (2 downto 0);
        sync_error          : out std_logic_vector (2 downto 0);
        system_failure      : out std_logic
    );
end turtle_master_error_detection;

architecture Behavioral of turtle_master_error_detection is

    signal cmp_error_reg        : std_logic_vector (2 downto 0);
    signal sync_error_reg       : std_logic_vector (2 downto 0);
    signal system_failure_reg   : std_logic;
    
    signal slave_response_vote  : std_logic_vector (RESPONSE_WIDTH-1 downto 0);
    
    constant LOG_VALUE_PADDING  : std_logic_vector (LOG_VALUE_WIDTH-RESPONSE_WIDTH-1 downto 0) := (others=>'0');
    signal comparison_log_reg   : std_logic_vector (LOG_LENGTH*(LOG_ENTRY_VALUES*LOG_VALUE_WIDTH)-1 downto 0);
    signal log_counter          : unsigned (7 downto 0);

begin
    -- Output
    cmp_error <= cmp_error_reg;
    sync_error <= sync_error_reg;
    system_failure <= system_failure_reg;
    comparison_log <= comparison_log_reg;

    -- Error Detection
    slave_response_vote <= vote(slave_response_a, slave_response_b, slave_response_c);
    process (clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' or error_clear = '1' then
                sync_error_reg <= (others=>'0');
                cmp_error_reg <= (others=>'0');
                system_failure_reg <= '0';
            else 
                -- Out-of-sync error detection
                if slave_response_a /= slave_response_vote then
                    sync_error_reg(0) <= '1';
                end if;
                
                if slave_response_b /= slave_response_vote then
                    sync_error_reg(1) <= '1';
                end if;
                
                if slave_response_c /= slave_response_vote then
                    sync_error_reg(2) <= '1';
                end if;
            
                -- Comparison error detection
                if slave_response_a /= master_response then
                    cmp_error_reg(0) <= '1';
                end if;
                
                if slave_response_b /= master_response then
                    cmp_error_reg(1) <= '1';
                end if;
                
                if slave_response_c /= master_response then
                    cmp_error_reg(2) <= '1';
                end if;
                
                -- Multiple domain comparison error detection
                if slave_response_vote /= master_response then
                    system_failure_reg <= '1';
                end if;
            end if;
        end if;
    end process;
    
    -- Logging
    process (clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' or error_clear='1' then
                log_counter <= to_unsigned(LOG_LENGTH/2, 8);
            else
                if log_counter > 0 then
                    comparison_log_reg <=
                            comparison_log_reg((LOG_LENGTH-1)*(LOG_ENTRY_VALUES*LOG_VALUE_WIDTH)-1 downto 0) &
                            LOG_VALUE_PADDING & master_response &
                            LOG_VALUE_PADDING & slave_response_a &
                            LOG_VALUE_PADDING & slave_response_b &
                            LOG_VALUE_PADDING & slave_response_c;
                    if system_failure_reg = '1' then
                        log_counter <= log_counter -1;
                    end if;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
