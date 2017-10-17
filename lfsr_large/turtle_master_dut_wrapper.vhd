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
-- +----------+         +----------+
-- |       ---|---rst---|-->       |
-- |          |         |          |
-- |       <==|===dout==|===       |
-- +----------+         +----------+
--    Master      FMC      Slave

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity turtle_master_dut_wrapper is
    Generic (
        DOUT_WIDTH      : natural := 64;
        STAGES          : natural;
        TMR_MODE        : natural
    );
    Port ( 
        clk_a           : in  std_logic;
        clk_b           : in  std_logic;
        clk_c           : in  std_logic;
        reset           : in  std_logic;
        dout            : out std_logic_vector (DOUT_WIDTH-1 downto 0)
    );
end turtle_master_dut_wrapper;

architecture Behavioral of turtle_master_dut_wrapper is

    signal fmc_reset_a          : std_logic;
    signal fmc_reset_b          : std_logic;
    signal fmc_reset_c          : std_logic;
    signal fmc_dout             : std_logic_vector (DOUT_WIDTH-1 downto 0);
    
    signal slave_reset_a        : std_logic;
    signal slave_reset_b        : std_logic;
    signal slave_reset_c        : std_logic;
    signal slave_dout_a         : std_logic_vector (DOUT_WIDTH-1 downto 0);
    signal slave_dout_b         : std_logic_vector (DOUT_WIDTH-1 downto 0);
    signal slave_dout_c         : std_logic_vector (DOUT_WIDTH-1 downto 0);

begin

    -- Master/FMC Boundary I/O Module
    master_dut_io: entity work.turtle_dut_io
        generic map (
            RESET_OUT_TMR   => FALSE
        )
        port map (
            clk_a           => clk_a,
            clk_b           => clk_b,
            clk_c           => clk_c,
            reset_in        => reset,
            reset_out_a     => fmc_reset_a,
            reset_out_b     => fmc_reset_b,
            reset_out_c     => fmc_reset_c,
            dout_in         => fmc_dout,
            dout_out        => dout
        );
        
    -- Slave/FMC Boundary I/O Module
    slave_dut_io: entity work.turtle_dut_io
        generic map (
            RESET_IN_TMR    => FALSE,
            RESET_OUT_TMR   => FALSE,
            DOUT_IN_TMR     => FALSE
        )
        port map (
            clk_a           => clk_a,
            clk_b           => clk_b,
            clk_c           => clk_c,
            reset_in_a      => fmc_reset_a,
            reset_in_b      => fmc_reset_b,
            reset_in_c      => fmc_reset_c,
            reset_out_a     => slave_reset_a,
            reset_out_b     => slave_reset_b,
            reset_out_c     => slave_reset_c,
            dout_in_a       => slave_dout_a,
            dout_in_b       => slave_dout_b,
            dout_in_c       => slave_dout_c,
            dout_out        => fmc_dout
        );

    -- Slave DUT Instance
    dut_inst: entity work.turtle_dut
        generic map (
            STAGES      => STAGES,
            TMR_MODE    => TMR_MODE
        )
        port map (
            clk_a       => clk_a,
            clk_b       => clk_b,
            clk_c       => clk_c,
            reset_a     => slave_reset_a,
            reset_b     => slave_reset_b,
            reset_c     => slave_reset_c,
            dout_a      => slave_dout_a,
            dout_b      => slave_dout_b,
            dout_c      => slave_dout_c
        );

end Behavioral;
