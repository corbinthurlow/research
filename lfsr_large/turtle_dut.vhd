library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity turtle_dut is
    Generic (
        STAGES      : natural;
        TMR_MODE    : natural
    );
    Port (
        clk_a       : in  std_logic;
        clk_b       : in  std_logic;
        clk_c       : in  std_logic;
        reset_a     : in  std_logic;
        reset_b     : in  std_logic;
        reset_c     : in  std_logic;
        dout_a      : out std_logic_vector (63 downto 0);
        dout_b      : out std_logic_vector (63 downto 0);
        dout_c      : out std_logic_vector (63 downto 0)
    );
end turtle_dut;

architecture Behavioral of turtle_dut is
begin

lfsr_large1: entity work.lfsr_large
    generic map(
        DATA_WIDTH => 64
        )
      port map(
        clk_a => clk_a,
        rst_a => reset_a,
        data_out_a => dout_a
      );
      


end Behavioral;
