library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity turtle_slave_top is
    Generic (
        STAGES          : natural := 2;
        TMR_MODE        : natural := 1
    );
    Port ( 
        fmc_clk_a       : in  std_logic;
        fmc_clk_b       : in  std_logic;
        fmc_clk_c       : in  std_logic;
        fmc_reset_a     : in  std_logic;
        fmc_reset_b     : in  std_logic;
        fmc_reset_c     : in  std_logic;
        fmc_dout        : out std_logic_vector (63 downto 0);
        set_vadj        : out std_logic_vector (1 downto 0);
        vadj_en         : out std_logic;
        led             : out std_logic_vector (7 downto 0)
    );
end turtle_slave_top;

architecture Behavioral of turtle_slave_top is

    signal dut_dout_a   : std_logic_vector (63 downto 0);
    signal dut_dout_b   : std_logic_vector (63 downto 0);
    signal dut_dout_c   : std_logic_vector (63 downto 0);
    signal dut_reset_a  : std_logic;
    signal dut_reset_b  : std_logic;
    signal dut_reset_c  : std_logic;

begin

    io_inst: entity work.turtle_dut_io
        generic map (
            RESET_IN_TMR    => TRUE,
            RESET_OUT_TMR   => TRUE,
            DOUT_OUT_TMR    => FALSE,
            DOUT_IN_TMR     => FALSE
        )
        port map (
            clk_a           => fmc_clk_a,
            clk_b           => fmc_clk_b,
            clk_c           => fmc_clk_c,
            reset_in_a      => fmc_reset_a,
            reset_in_b      => fmc_reset_b,
            reset_in_c      => fmc_reset_c,
            reset_out_a     => dut_reset_a,
            reset_out_b     => dut_reset_b,
            reset_out_c     => dut_reset_c,
            dout_in_a       => dut_dout_a,
            dout_in_b       => dut_dout_b,
            dout_in_c       => dut_dout_c,
            dout_out        => fmc_dout
        );

    dut_inst: entity work.turtle_dut
        generic map (
            STAGES      => STAGES,
            TMR_MODE    => TMR_MODE
        )
        port map (
            clk_a       => fmc_clk_a,
            clk_b       => fmc_clk_b,
            clk_c       => fmc_clk_c,
            reset_a     => dut_reset_a,
            reset_b     => dut_reset_b,
            reset_c     => dut_reset_c,
            dout_a      => dut_dout_a,
            dout_b      => dut_dout_b,
            dout_c      => dut_dout_c
        );

    -- Misc I/O
--    led <= dut_dout_a(7 downto 0);
    led <=  dut_dout_a(31 downto 24);
    vadj_en <= '1';
    set_vadj <= "11";
end Behavioral;
