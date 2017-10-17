library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

-- Modes:
--  -COMMON
--  -SPLIT
--  -TRIPLICATED

entity turtle_clocking is
    Generic (
        MODE        : string := "TRIPLICATED"
    );
    Port ( 
        clk_in_a    : in    STD_LOGIC;
        clk_in_b    : in    STD_LOGIC;
        clk_in_c    : in    STD_LOGIC;
        clk_out_a   : out   STD_LOGIC;
        clk_out_b   : out   STD_LOGIC;
        clk_out_c   : out   STD_LOGIC
    );
end turtle_clocking;

architecture Behavioral of turtle_clocking is

begin
    common_mode: if MODE = "COMMON" generate
        clk_out_a <= clk_in_a;
        clk_out_b <= clk_in_a;
        clk_out_c <= clk_in_a;
    end generate;
    
    split_mode: if MODE = "SPLIT" generate
        attribute DONT_TOUCH : string;
        attribute DONT_TOUCH of buff_a : label is "TRUE";
        attribute DONT_TOUCH of buff_b : label is "TRUE";
        attribute DONT_TOUCH of buff_c : label is "TRUE";
    begin
        buff_a: BUFG 
            port map (
                I => clk_in_a,
                O => clk_out_a
            );

        buff_b: BUFG 
            port map (
                I => clk_in_a,
                O => clk_out_b
            );
            
        buff_c: BUFG 
            port map (
                I => clk_in_a,
                O => clk_out_c
            );
    end generate;
    
    triplicated_mode: if MODE = "TRIPLICATED" generate
        clk_out_a <= clk_in_a;
        clk_out_b <= clk_in_b;
        clk_out_c <= clk_in_c;
    end generate;

end Behavioral;
