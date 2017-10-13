library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity input_buffer is
    Generic (
        IOB_EN      : boolean := TRUE;
        BUFFER_MODE : integer := 3
    );
    Port ( 
        I           : in STD_LOGIC;
        clk         : in STD_LOGIC;
        O0          : out STD_LOGIC;
        O1          : out STD_LOGIC;
        O2          : out STD_LOGIC
    );
end input_buffer;

architecture Behavioral of input_buffer is

    signal I_reg        : std_logic;
    signal I_reg_buf0   : std_logic;
    signal I_reg_buf1   : std_logic;
    signal I_reg_buf2   : std_logic;

    attribute IOB : boolean;
    attribute IOB of I_reg : signal is IOB_EN;
    
    attribute DONT_TOUCH : string;
    
begin

    -- Input Register
    process (clk) is
    begin
        if rising_edge(clk) then
            I_reg <= I;
        end if;
    end process;
    
    -- Zero Buffer Mode
    gen_0_buf: if BUFFER_MODE = 0 generate
    begin
        I_reg_buf0 <= I_reg;
        I_reg_buf1 <= I_reg;
        I_reg_buf2 <= I_reg;
    end generate gen_0_buf;    
    
    -- Single Buffer Mode
    gen_1_buf: if BUFFER_MODE = 1 generate
        attribute DONT_TOUCH of buf_inst_0 : label is "TRUE";
    begin
        buf_inst_0: LUT1
            generic map (
                INIT    => "10"
            )
            port map (
                I0  => I_reg,
                O   => I_reg_buf0
            );
            I_reg_buf1 <= I_reg_buf0;
            I_reg_buf2 <= I_reg_buf0;
    end generate gen_1_buf;
    
    -- Triple Buffer Mode
    gen_3_buf: if BUFFER_MODE = 3 generate
        attribute DONT_TOUCH of buf_inst_0 : label is "TRUE";
        attribute DONT_TOUCH of buf_inst_1 : label is "TRUE";
        attribute DONT_TOUCH of buf_inst_2 : label is "TRUE";
    begin
    
        buf_inst_0: LUT1
            generic map (
                INIT    => "10"
            )
            port map (
                I0  => I_reg,
                O   => I_reg_buf0
            );
        buf_inst_1: LUT1
            generic map (
                INIT    => "10"
            )
            port map (
                I0  => I_reg,
                O   => I_reg_buf1
            );
        buf_inst_2: LUT1
            generic map (
                INIT    => "10"
            )
            port map (
                I0  => I_reg,
                O   => I_reg_buf2
            );
            
    end generate gen_3_buf;

    O0 <= I_reg_buf0;
    O1 <= I_reg_buf1;
    O2 <= I_reg_buf2;

end Behavioral;
