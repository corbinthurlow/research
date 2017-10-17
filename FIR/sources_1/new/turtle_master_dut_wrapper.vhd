--
-- This module is designed to create a copy of
-- dut as it is instanced on the slave as seen
-- by the master. This creates a copy of the dut
-- on the master with the same delay that would 
-- be experienced by the dut on the slave device.
--
-- Signals are registered on the boundaries of 
-- each device. Signals in this module are named
-- to reflect where they would fall within the following
-- schematic.
--
-- +----------+             +----------+
-- |       ---|-----rst-----|-->       |
-- |          |             |          |
-- |       ===|==challenge==|==>       |
-- |       <==|===response==|===       |
-- +----------+             +----------+
--    Master      FMC          Slave

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
 
entity turtle_master_dut_wrapper is
    Generic (
        FMC_DATA_WIDTH          : natural;
        CHALLENGE_WIDTH         : natural;
        RESPONSE_WIDTH          : natural;
        TMR_MODE                : string
    );
    Port ( 
        clk_a                   : in  std_logic;
        clk_b                   : in  std_logic;
        clk_c                   : in  std_logic;
        reset                   : in  std_logic;
        challenge               : in  std_logic_vector (CHALLENGE_WIDTH-1 downto 0);
        response                : out std_logic_vector (RESPONSE_WIDTH-1 downto 0)
    );
end turtle_master_dut_wrapper;

architecture Behavioral of turtle_master_dut_wrapper is
    
    signal slave_reset_a        : std_logic;
    signal slave_reset_b        : std_logic;
    signal slave_reset_c        : std_logic;
    signal slave_challenge_a    : std_logic_vector (CHALLENGE_WIDTH-1 downto 0);
    signal slave_challenge_b    : std_logic_vector (CHALLENGE_WIDTH-1 downto 0);
    signal slave_challenge_c    : std_logic_vector (CHALLENGE_WIDTH-1 downto 0);
    signal slave_response_a     : std_logic_vector (RESPONSE_WIDTH-1 downto 0);
    signal slave_response_b     : std_logic_vector (RESPONSE_WIDTH-1 downto 0);
    signal slave_response_c     : std_logic_vector (RESPONSE_WIDTH-1 downto 0);

    signal fmc_rst_a            : std_logic;
    signal fmc_rst_b            : std_logic;
    signal fmc_rst_c            : std_logic;
    signal fmc_data_a           : std_logic_vector (FMC_DATA_WIDTH-1 downto 0);
    signal fmc_data_b           : std_logic_vector (FMC_DATA_WIDTH-1 downto 0);
    signal fmc_data_c           : std_logic_vector (FMC_DATA_WIDTH-1 downto 0);
    

begin

    -- Master/FMC Boundary I/O Module
    master_io: entity work.turtle_master_io
        generic map (
            FMC_DATA_WIDTH      => FMC_DATA_WIDTH,
            CHALLENGE_WIDTH     => CHALLENGE_WIDTH,
            RESPONSE_WIDTH      => RESPONSE_WIDTH,
            MODE                => "1PORT",
            IOB_EN              => FALSE
        )
        port map (
            clk_a               => clk_a,
            clk_b               => clk_b,
            clk_c               => clk_c,
            rst                 => reset,
            challenge           => challenge,
            response_a          => response,
            response_b          => open,
            response_c          => open,
            fmc_data_a          => fmc_data_a,
            fmc_data_b          => fmc_data_b,
            fmc_data_c          => fmc_data_c,
            fmc_rst_a           => fmc_rst_a,
            fmc_rst_b           => fmc_rst_b,
            fmc_rst_c           => fmc_rst_c
        );


        
    -- Slave/FMC Boundary I/O Module
    slave_io: entity work.turtle_slave_io
        generic map (
            MODE                => "1PORT",
            FMC_DATA_WIDTH      => FMC_DATA_WIDTH,
            CHALLENGE_WIDTH     => CHALLENGE_WIDTH,
            RESPONSE_WIDTH      => RESPONSE_WIDTH,
            IOB_EN              => FALSE
        )
        port map (
            clk_a               => clk_a,
            clk_b               => clk_b,
            clk_c               => clk_c,
            challenge_a         => slave_challenge_a,
            challenge_b         => slave_challenge_b,
            challenge_c         => slave_challenge_c,
            response_a          => slave_response_a,
            response_b          => slave_response_b,
            response_c          => slave_response_c,
            rst_a               => slave_reset_a,
            rst_b               => slave_reset_b,
            rst_c               => slave_reset_c,
            fmc_data_a          => fmc_data_a,
            fmc_data_b          => fmc_data_b,
            fmc_data_c          => fmc_data_c,
            fmc_rst_a           => fmc_rst_a,
            fmc_rst_b           => fmc_rst_b,
            fmc_rst_c           => fmc_rst_c
        );

    -- Slave DUT Instance
    dut_inst: entity work.turtle_dut_wrapper
        generic map (
            CHALLENGE_WIDTH     => CHALLENGE_WIDTH,
            RESPONSE_WIDTH      => RESPONSE_WIDTH,
            TMR_MODE            => TMR_MODE
        )
        port map (
            clk_a               => clk_a,
            clk_b               => clk_b,
            clk_c               => clk_c,
            reset_a             => slave_reset_a,
            reset_b             => slave_reset_b,
            reset_c             => slave_reset_c,
            challenge_a         => slave_challenge_a,
            challenge_b         => slave_challenge_b,
            challenge_c         => slave_challenge_c,
            response_a          => slave_response_a,
            response_b          => slave_response_b,
            response_c          => slave_response_c
        );

end Behavioral;
