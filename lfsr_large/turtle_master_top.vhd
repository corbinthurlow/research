library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity turtle_master_top is
    generic (
        STAGES          : natural := 2;
        TMR_MODE        : natural := 2;
        
        DATA_WIDTH      : natural := 64;
        LOG_LENGTH      : natural := 8;
        RESET_VAL       : natural := 50_000;
        DELAY_VAL       : natural := 0
    );
    port ( 
        fmc_clk_a       : in  std_logic;
        fmc_clk_b       : in  std_logic;
        fmc_clk_c       : in  std_logic;
        reset_btn       : in  std_logic;
        fmc_reset_a     : out std_logic;
        fmc_reset_b     : out std_logic;
        fmc_reset_c     : out std_logic;
        fmc_din         : in  std_logic_vector (DATA_WIDTH-1 downto 0);
        led             : out std_logic_vector (7 downto 0);
        set_vadj        : out std_logic_vector (1 downto 0);
        vadj_en         : out std_logic
    );
end turtle_master_top;

architecture Behavioral of turtle_master_top is

    signal reset_btn_d          : std_logic;
    signal reset_btn_dd         : std_logic;
    signal ext_reset            : std_logic;
    
    signal fsm_reset_out        : std_logic;
    
    signal master_dout          : std_logic_vector (DATA_WIDTH-1 downto 0);
    signal slave_dout           : std_logic_vector (DATA_WIDTH-1 downto 0);
    
    signal bscan_reset          : std_logic;
    signal bscan_error_clear    : std_logic;
    
    signal error                : std_logic;
    signal error_master_log     : std_logic_vector (LOG_LENGTH*DATA_WIDTH-1 downto 0);
    signal error_slave_log      : std_logic_vector (LOG_LENGTH*DATA_WIDTH-1 downto 0);
begin

    -- Misc I/O
    vadj_en <= '1';
    set_vadj <= "11";

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
            LOG_LENGTH      => LOG_LENGTH
        )
        port map (
            clk             => fmc_clk_a,
            system_reset    => bscan_reset,
            error_clear     => bscan_error_clear,
            master_log      => error_master_log,
            slave_log       => error_slave_log,
            error           => error
        );

    -- Control Logic
    fsm: entity work.turtle_master_fsm
        generic map (
            RESET_VAL       => RESET_VAL,
            DELAY_VAL       => DELAY_VAL
        )
        port map (
            clk             => fmc_clk_a,
            ext_reset       => ext_reset,
            bscan_reset     => bscan_reset,
            reset_out       => fsm_reset_out
        );
    
    
    -- Master DUT Instance
    dut_wrapper: entity work.turtle_master_dut_wrapper
        generic map (
            STAGES      => STAGES,
            TMR_MODE    => TMR_MODE
        )
        port map (
            clk_a           => fmc_clk_a,
            clk_b           => fmc_clk_b,
            clk_c           => fmc_clk_c,
            reset           => fsm_reset_out,
            dout            => master_dout
        );
        
    -- I/O Registers
    io: entity work.turtle_dut_io
        generic map (
            RESET_OUT_TMR   => FALSE
        )
        port map (
            clk_a           => fmc_clk_a,
            clk_b           => fmc_clk_b,
            clk_c           => fmc_clk_c,
            reset_in        => fsm_reset_out,
            reset_out_a     => fmc_reset_a,
            reset_out_b     => fmc_reset_b,
            reset_out_c     => fmc_reset_c,
            dout_in         => fmc_din,
            dout_out        => slave_dout
        );
    
    -- Error Detection
    error_detection: entity work.turtle_master_error_detection
        generic map (
            LOG_LENGTH      => LOG_LENGTH
        )
        port map (
            clk             => fmc_clk_a,
            error_clear     => fsm_reset_out,
            slave_dout      => slave_dout,
            master_dout     => master_dout,
            error           => error,
            master_log      => error_master_log,
            slave_log       => error_slave_log
        );

    -- Error Notification
    error_notification: entity work.turtle_master_error_notification
        port map (
            clk             => fmc_clk_a,
            error           => error,
            led             => led
        );
    

end Behavioral;
