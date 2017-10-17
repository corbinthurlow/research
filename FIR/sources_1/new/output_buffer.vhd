library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity output_buffer is
    Generic (
        IOB_EN      : boolean := TRUE;
        BUFFER_MODE : integer := 3
    );
    Port ( 
        I0          : in STD_LOGIC;
        I1          : in STD_LOGIC := '0';
        I2          : in STD_LOGIC := '0';
        clk         : in STD_LOGIC;
        O           : out STD_LOGIC
    );
end output_buffer;

architecture Behavioral of output_buffer is

    signal I_buf        : std_logic;
    signal I_buf_reg    : std_logic;
    
    attribute IOB : boolean;
    attribute IOB of I_buf_reg : signal is IOB_EN;
    
    attribute DONT_TOUCH : string;

begin

    -- Zero Buffer Mode
    gen_0_buf: if BUFFER_MODE = 0 generate
    begin
        I_buf <= I0;
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
                I0  => I0,
                O   => I_buf
            );
    end generate gen_1_buf;
    
    
    -- Triple Buffer Mode
    gen_3_buf: if BUFFER_MODE = 3 generate
        attribute DONT_TOUCH of buf_inst_0 : label is "TRUE";
    begin
        buf_inst_0: LUT3
            generic map (
                INIT    => x"E8" 
            )
            port map (
                I0  => I0,
                I1  => I1,
                I2  => I2,
                O   => I_buf
            );
    end generate gen_3_buf;

    -- Input Register
    process (clk) is
    begin
        if rising_edge(clk) then
            I_buf_reg <= I_buf;
        end if;
    end process;
    
    O <= I_buf_reg;

end Behavioral;
