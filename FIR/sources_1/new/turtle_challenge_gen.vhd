library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity turtle_challenge_gen is
    Generic (
        CHALLENGE_WIDTH     : natural
    );
    Port (
        clk                 : in STD_LOGIC;
        rst                 : in STD_LOGIC;
        challenge_out       : out STD_LOGIC_VECTOR (CHALLENGE_WIDTH-1 downto 0)
    );
end turtle_challenge_gen;


architecture Behavioral of turtle_challenge_gen is
begin

    fir: entity work.fir_filter_8
        generic map(
            DATA_WIDTH => CHALLENGE_WIDTH
        )
        port map(
            data_in =>  (others=>'0'),
            clk         => clk,
            rst         => rst,
            data_out    => challenge_out
        );

end Behavioral;
