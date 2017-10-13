library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--
-- TMR_MODE:
--   - SIMULATION
--   - SIMULATION_COARSE_TMR
--   - EDIF
--   - EDIF_COARSE_TMR
--   - EDIF_FINE_TMR
--

--
-- IO_MODE:
--   - 1PORT
--   - 3PORT
--


entity turtle_master_top is
    generic (
        TMR_MODE            : string := "SIMULATION";
        IO_MODE             : string := "1PORT";
        FMC_DATA_WIDTH      : natural := 20;
        CHALLENGE_WIDTH     : natural := 64;
        RESPONSE_WIDTH      : natural := 64;
        
        DATA_WIDTH          : natural := 64;
        LOG_LENGTH          : natural := 8;
        RESET_VAL           : natural := 50_000;
        DELAY_VAL           : natural := 0
    );
    port ( 
        fmc_clk_a           : in    std_logic;
        fmc_clk_b           : in    std_logic;
        fmc_clk_c           : in    std_logic;
        reset_btn           : in    std_logic;
        fmc_rst_a           : out   std_logic;
        fmc_rst_b           : out   std_logic;
        fmc_rst_c           : out   std_logic;
        fmc_data_a          : inout std_logic_vector (FMC_DATA_WIDTH-1 downto 0);
        fmc_data_b          : inout std_logic_vector (FMC_DATA_WIDTH-1 downto 0);
        fmc_data_c          : inout std_logic_vector (FMC_DATA_WIDTH-1 downto 0);
        fmc_buf_ab          : out   std_logic_vector (1 downto 0);
        fmc_buf_bc          : out   std_logic_vector (1 downto 0);
        fmc_led             : out   std_logic_vector (1 downto 0);
        nexys_led           : out   std_logic_vector (7 downto 0);
        nexys_vadj          : out   std_logic_vector (1 downto 0);
        nexys_vadj_en       : out   std_logic
    );
end turtle_master_top;

architecture Behavioral of turtle_master_top is

    signal reset_btn_d          : std_logic;
    signal reset_btn_dd         : std_logic;
    signal ext_reset            : std_logic;
    
    signal fsm_reset_out        : std_logic;
    
    signal master_response      : std_logic_vector (RESPONSE_WIDTH-1 downto 0);
    signal slave_response_a     : std_logic_vector (RESPONSE_WIDTH-1 downto 0);
    signal slave_response_b     : std_logic_vector (RESPONSE_WIDTH-1 downto 0);
    signal slave_response_c     : std_logic_vector (RESPONSE_WIDTH-1 downto 0);
    signal challenge            : std_logic_vector (CHALLENGE_WIDTH-1 downto 0);
    
    signal bscan_reset          : std_logic;
    signal bscan_error_clear    : std_logic;
    
    constant LOG_VALUE_WIDTH    : integer := 32;
    constant LOG_ENTRY_VALUES   : integer := 4;
    signal sync_error           : std_logic_vector (2 downto 0);
    signal cmp_error            : std_logic_vector (2 downto 0);
    signal system_failure       : std_logic;
    signal comparison_log       : std_logic_vector (LOG_LENGTH*LOG_ENTRY_VALUES*LOG_VALUE_WIDTH-1 downto 0);
begin

    -- Misc I/O
    nexys_vadj_en <= '1';
    nexys_vadj <= "11";
    fmc_buf_ab <= "00";
    fmc_buf_bc <= "00";

    process (fmc_clk_a) is
    begin
        if rising_edge(fmc_clk_a) then
            reset_btn_d <= reset_btn;
            reset_btn_dd <= reset_btn_d;
        end if;
    end process;
    ext_reset <= not(reset_btn_dd);
    
    -- BSCAN Instances
    bscan: entity work.turtle_master_bscan
        generic map (
            LOG_LENGTH          => LOG_LENGTH
        )
        port map (
            clk                 => fmc_clk_a,
            system_reset        => bscan_reset,
            error_clear         => bscan_error_clear,
            comparison_log      => comparison_log,
            cmp_error           => cmp_error,
            sync_error          => sync_error,
            system_failure      => system_failure
        );

    -- Control Logic
    fsm: entity work.turtle_master_fsm
        generic map (
            RESET_VAL           => RESET_VAL,
            DELAY_VAL           => DELAY_VAL
        )
        port map (
            clk                 => fmc_clk_a,
            ext_reset           => ext_reset,
            bscan_reset         => bscan_reset,
            reset_out           => fsm_reset_out
        );
    
    -- Challenge Generator
    challenge_gen: entity work.turtle_challenge_gen
        generic map (
            CHALLENGE_WIDTH     => CHALLENGE_WIDTH
        )
        port map (
            clk                 => fmc_clk_a,
            rst                 => fsm_reset_out,
            challenge_out       => challenge
        );
    
    -- Master DUT Instance
    dut_wrapper: entity work.turtle_master_dut_wrapper
        generic map (
            FMC_DATA_WIDTH      => FMC_DATA_WIDTH,
            CHALLENGE_WIDTH     => CHALLENGE_WIDTH,
            RESPONSE_WIDTH      => RESPONSE_WIDTH,
            TMR_MODE            => TMR_MODE
        )
        port map (
            clk_a               => fmc_clk_a,
            clk_b               => fmc_clk_b,
            clk_c               => fmc_clk_c,
            reset               => fsm_reset_out,
            challenge           => challenge,
            response            => master_response
        );
        
    -- I/O Registers
    master_io: entity work.turtle_master_io
        generic map (
            FMC_DATA_WIDTH      => FMC_DATA_WIDTH,
            CHALLENGE_WIDTH     => CHALLENGE_WIDTH,
            RESPONSE_WIDTH      => RESPONSE_WIDTH,
            MODE                => IO_MODE
        )
        port map (
            clk_a               => fmc_clk_a,
            clk_b               => fmc_clk_b,
            clk_c               => fmc_clk_c,
            rst                 => fsm_reset_out,
            challenge           => challenge,
            response_a          => slave_response_a,
            response_b          => slave_response_b,
            response_c          => slave_response_c,
            fmc_data_a          => fmc_data_a,
            fmc_data_b          => fmc_data_b,
            fmc_data_c          => fmc_data_c,
            fmc_rst_a           => fmc_rst_a,
            fmc_rst_b           => fmc_rst_b,
            fmc_rst_c           => fmc_rst_c
        );
    
    -- Error Detection
    error_detection: entity work.turtle_master_error_detection
        generic map (
            RESPONSE_WIDTH      => RESPONSE_WIDTH,
            LOG_LENGTH          => LOG_LENGTH
        )
        port map (
            clk                 => fmc_clk_a,
            reset               => fsm_reset_out,
            error_clear         => bscan_error_clear,
            master_response     => master_response,
            slave_response_a    => slave_response_a,
            slave_response_b    => slave_response_b,
            slave_response_c    => slave_response_c,
            comparison_log      => comparison_log,
            cmp_error           => cmp_error,
            sync_error          => sync_error,
            system_failure      => system_failure
        );

    -- Error Notification
    error_notification: entity work.turtle_master_error_notification
        port map (
            clk                 => fmc_clk_a,
            cmp_error           => cmp_error,
            sync_error          => sync_error,
            system_failure      => system_failure,
            nexys_led           => nexys_led,
            fmc_led             => fmc_led
        );
    

end Behavioral;
