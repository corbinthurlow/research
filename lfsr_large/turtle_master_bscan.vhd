library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity turtle_master_bscan is
    Generic (
        MASTER_LOG_BSCAN        : natural := 1;
        SLAVE_LOG_BSCAN         : natural := 2;
        STATUS_BSCAN            : natural := 3;
        LOG_LENGTH              : natural := 8;
        DATA_WIDTH              : natural := 64
    );
    Port ( 
        clk                     : in  std_logic;
        system_reset            : out std_logic;
        error_clear             : out std_logic;
        master_log              : in  std_logic_vector (LOG_LENGTH*DATA_WIDTH-1 downto 0);
        slave_log               : in  std_logic_vector (LOG_LENGTH*DATA_WIDTH-1 downto 0);
        error                   : in  std_logic
    );
end turtle_master_bscan;

architecture Behavioral of turtle_master_bscan is
    
    constant STATUS_BSCAN_WIDTH     : natural := 32;
    signal status_bscan_out         : std_logic_vector(STATUS_BSCAN_WIDTH-1 downto 0);
    signal status_bscan_in          : std_logic_vector(STATUS_BSCAN_WIDTH-1 downto 0);
    signal status_bscan_valid       : std_logic;
    signal status_bscan_valid_d     : std_logic;
    signal status_bscan_valid_dd    : std_logic;
    signal status_bscan_valid_ddd   : std_logic;
    signal status_bscan_rising      : std_logic;
    
    constant SYSTEM_RESET_CODE      : natural := 1;
    constant ERROR_CLEAR_CODE       : natural := 2;    

begin
    -- Synchronizer and edge detector
    process (clk) is
    begin
        if (rising_edge(clk)) then
            status_bscan_valid_d <= status_bscan_valid;
            status_bscan_valid_dd <= status_bscan_valid_d;
            status_bscan_valid_ddd <= status_bscan_valid_dd;
        end if;
    end process;
    status_bscan_rising <= '1' when status_bscan_valid_ddd = '0' and status_bscan_valid_dd = '1' else '0'; 

    -- Input commands
    process (clk) is
    begin
        if (rising_edge(clk)) then
            system_reset <= '0';
            error_clear <= '0';
            
            if status_bscan_rising = '1' then
                case to_integer(unsigned(status_bscan_in)) is
                    when SYSTEM_RESET_CODE =>
                        system_reset <= '1';
                    when ERROR_CLEAR_CODE =>
                        error_clear <= '1';
                    when others =>
                        -- Do nothing
                end case;
            end if;
        end if;
    end process;
        

    -- Status BSCAN interface
    status_bscan_if: entity work.bscan_if
        generic map (
            DATA_WIDTH  => STATUS_BSCAN_WIDTH,
            USE_EXTERNAL_TCK => false,
            INSTANCE_TCK_BUFG => false,
            USE_INPUT_REGISTER => true,
            JTAG_CHAIN => STATUS_BSCAN
        )
        port map (
            tck_in => '0', -- this doesn't do anything - "USE_EXTERNAL_TCK = false"
            data_out => status_bscan_out,
            data_in => status_bscan_in,
            data_in_update => status_bscan_valid,
            tck_out => open,
            data_out_capture => open  
        );
    status_bscan_out <= x"43434C0" & "000" & error; 
    
    -- Master Log BSCAN interface
    master_log_bscan_if: entity work.bscan_if
        generic map (
            DATA_WIDTH  => LOG_LENGTH*DATA_WIDTH,
            USE_EXTERNAL_TCK => false,
            INSTANCE_TCK_BUFG => false,
            USE_INPUT_REGISTER => true,
            JTAG_CHAIN => MASTER_LOG_BSCAN
        )
        port map (
            tck_in => '0', -- this doesn't do anything - "USE_EXTERNAL_TCK = false"
            data_out => master_log,
            data_in => open,
            data_in_update => open,
            tck_out => open,
            data_out_capture => open  
        );
        
    -- Slave Log BSCAN interface
    slave_log_bscan_if: entity work.bscan_if
        generic map (
            DATA_WIDTH  => LOG_LENGTH*DATA_WIDTH,
            USE_EXTERNAL_TCK => false,
            INSTANCE_TCK_BUFG => false,
            USE_INPUT_REGISTER => true,
            JTAG_CHAIN => SLAVE_LOG_BSCAN
        )
        port map (
            tck_in => '0', -- this doesn't do anything - "USE_EXTERNAL_TCK = false"
            data_out => slave_log,
            data_in => open,
            data_in_update => open,
            tck_out => open,
            data_out_capture => open  
        );

end Behavioral;