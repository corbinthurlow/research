library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity turtle_master_error_detection is
    generic (
        DATA_WIDTH      : integer := 64;
        LOG_LENGTH      : integer := 8
    );
    Port ( 
        clk             : in  STD_LOGIC;
        error_clear     : in  STD_LOGIC;
        slave_dout      : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        master_dout     : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        master_log      : out std_logic_vector (LOG_LENGTH*DATA_WIDTH-1 downto 0);
        slave_log       : out std_logic_vector (LOG_LENGTH*DATA_WIDTH-1 downto 0);
        error           : out STD_LOGIC
    );
end turtle_master_error_detection;

architecture Behavioral of turtle_master_error_detection is

    signal error_reg            : std_logic;
    
    signal master_log_reg       : std_logic_vector (LOG_LENGTH*DATA_WIDTH-1 downto 0);
    signal slave_log_reg        : std_logic_vector (LOG_LENGTH*DATA_WIDTH-1 downto 0);
    signal log_counter          : unsigned (7 downto 0);

begin
    -- Output
    error <= error_reg;
    master_log <= master_log_reg;
    slave_log <= slave_log_reg;

    -- Error Detection
    process (clk) is
    begin
        if rising_edge(clk) then
            if error_clear = '1' then
                error_reg <= '0';
            elsif slave_dout /= master_dout then
                error_reg <= '1';
            end if;
        end if;
    end process;
    
    -- Logging
    process (clk) is
    begin
        if rising_edge(clk) then
            if error_clear='1' then
                log_counter <= to_unsigned(LOG_LENGTH/2, 8);
            else
                if log_counter > 0 then
                    master_log_reg <= master_log_reg((LOG_LENGTH-1)*DATA_WIDTH-1 downto 0) & master_dout;
                    slave_log_reg <= slave_log_reg((LOG_LENGTH-1)*DATA_WIDTH-1 downto 0) & slave_dout;
                    if error_reg = '1' then
                        log_counter <= log_counter -1;
                    end if;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
