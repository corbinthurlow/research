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
-- CLOCK_MODE:
--   - COMMON
--   - SPLIT
--   - TRIPLICATED
--

--
-- IO_MODE:
--   - 1PORT
--   - 1PORT_TMR
--   - 3PORT
--

entity turtle_slave_top is
    Generic (
        TMR_MODE                : string := "SIMULATION";
        CLOCK_MODE              : string := "TRIPLICATED";
        IO_MODE                 : string := "1PORT";
        FMC_DATA_WIDTH          : natural := 20;
        CHALLENGE_WIDTH         : natural := 64;
        RESPONSE_WIDTH          : natural := 64
    );
    Port ( 
        fmc_clk_a               : in    std_logic;
        fmc_clk_b               : in    std_logic;
        fmc_clk_c               : in    std_logic;
        fmc_rst_a               : in    std_logic;
        fmc_rst_b               : in    std_logic;
        fmc_rst_c               : in    std_logic;
        fmc_data_a              : inout std_logic_vector (FMC_DATA_WIDTH-1 downto 0);
        fmc_data_b              : inout std_logic_vector (FMC_DATA_WIDTH-1 downto 0);
        fmc_data_c              : inout std_logic_vector (FMC_DATA_WIDTH-1 downto 0);
        fmc_buf_ab              : out   std_logic_vector (1 downto 0);
        fmc_buf_bc              : out   std_logic_vector (1 downto 0);
        nexys_vadj              : out   std_logic_vector (1 downto 0);
        nexys_vadj_en           : out   std_logic;
        nexys_led               : out   std_logic_vector (7 downto 0)
    );
end turtle_slave_top;

architecture Behavioral of turtle_slave_top is

    signal io_rst_a             : std_logic;
    signal io_rst_b             : std_logic;
    signal io_rst_c             : std_logic;
    signal io_challenge_a       : std_logic_vector (CHALLENGE_WIDTH-1 downto 0);
    signal io_challenge_b       : std_logic_vector (CHALLENGE_WIDTH-1 downto 0);
    signal io_challenge_c       : std_logic_vector (CHALLENGE_WIDTH-1 downto 0);
    signal dut_response_a       : std_logic_vector (RESPONSE_WIDTH-1 downto 0);
    signal dut_response_b       : std_logic_vector (RESPONSE_WIDTH-1 downto 0);
    signal dut_response_c       : std_logic_vector (RESPONSE_WIDTH-1 downto 0);
    
    signal clk_a                : std_logic;
    signal clk_b                : std_logic;
    signal clk_c                : std_logic;
begin

    clocking: entity work.turtle_clocking
        generic map (
            MODE                => CLOCK_MODE
        )
        port map (
            clk_in_a            => fmc_clk_a,
            clk_in_b            => fmc_clk_b,
            clk_in_c            => fmc_clk_c,
            clk_out_a           => clk_a,
            clk_out_b           => clk_b,
            clk_out_c           => clk_c
        );

    slave_io: entity work.turtle_slave_io
        generic map (
            MODE                => IO_MODE,
            FMC_DATA_WIDTH      => FMC_DATA_WIDTH,
            CHALLENGE_WIDTH     => CHALLENGE_WIDTH,
            RESPONSE_WIDTH      => RESPONSE_WIDTH
        )
        port map (
            clk_a               => clk_a,
            clk_b               => clk_b,
            clk_c               => clk_c,
            challenge_a         => io_challenge_a,
            challenge_b         => io_challenge_b,
            challenge_c         => io_challenge_c,
            response_a          => dut_response_a,
            response_b          => dut_response_b,
            response_c          => dut_response_c,
            rst_a               => io_rst_a,
            rst_b               => io_rst_b,
            rst_c               => io_rst_c,
            fmc_data_a          => fmc_data_a,
            fmc_data_b          => fmc_data_b,
            fmc_data_c          => fmc_data_c,
            fmc_rst_a           => fmc_rst_a,
            fmc_rst_b           => fmc_rst_b,
            fmc_rst_c           => fmc_rst_c
        );

        

    dut_inst: entity work.turtle_dut_wrapper
        generic map (
            TMR_MODE            => TMR_MODE,
            CHALLENGE_WIDTH     => CHALLENGE_WIDTH,
            RESPONSE_WIDTH      => RESPONSE_WIDTH
        )
        port map (
            clk_a               => clk_a,
            clk_b               => clk_b,
            clk_c               => clk_c,
            reset_a             => io_rst_a,
            reset_b             => io_rst_b,
            reset_c             => io_rst_c,
            challenge_a         => io_challenge_a,
            challenge_b         => io_challenge_b,
            challenge_c         => io_challenge_c,
            response_a          => dut_response_a,
            response_b          => dut_response_b,
            response_c          => dut_response_c
        );

    -- Misc I/O
    nexys_led <= dut_response_a(7 downto 0);
    nexys_vadj_en <= '1';
    nexys_vadj <= "11";
    fmc_buf_ab <= "00";
    fmc_buf_bc <= "00";

end Behavioral;
