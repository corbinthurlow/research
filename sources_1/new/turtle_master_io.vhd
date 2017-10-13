library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--library UNISIM;
--use UNISIM.VComponents.all;

entity turtle_master_io is
    Generic (
        FMC_DATA_WIDTH      : integer := 20;
        CHALLENGE_WIDTH     : integer := 64;
        RESPONSE_WIDTH      : integer := 64;
        MODE                : string := "1PORT";
        IOB_EN              : boolean := TRUE
    );
    Port ( 
        clk_a               : in    STD_LOGIC;
        clk_b               : in    STD_LOGIC;
        clk_c               : in    STD_LOGIC;
        fmc_rst_a           : out   STD_LOGIC;
        fmc_rst_b           : out   STD_LOGIC;
        fmc_rst_c           : out   STD_LOGIC;
        fmc_data_a          : inout STD_LOGIC_VECTOR (FMC_DATA_WIDTH-1 downto 0);
        fmc_data_b          : inout STD_LOGIC_VECTOR (FMC_DATA_WIDTH-1 downto 0);
        fmc_data_c          : inout STD_LOGIC_VECTOR (FMC_DATA_WIDTH-1 downto 0);
        challenge           : in    STD_LOGIC_VECTOR (CHALLENGE_WIDTH-1 downto 0);
        response_a          : out   STD_LOGIC_VECTOR (RESPONSE_WIDTH-1 downto 0);
        response_b          : out   STD_LOGIC_VECTOR (RESPONSE_WIDTH-1 downto 0);
        response_c          : out   STD_LOGIC_VECTOR (RESPONSE_WIDTH-1 downto 0);
        rst                 : in    STD_LOGIC
    );
end turtle_master_io;

architecture Behavioral of turtle_master_io is

    function first_port_mode(str_mode: string)
    return integer is
    begin
        if str_mode = "1PORT" then
            return 1;
        elsif str_mode = "3PORT" then
            return 1;
        else
            return 0;
        end if;
    end first_port_mode;
    
    function other_port_mode(str_mode: string)
    return integer is
    begin
        if str_mode = "1PORT" then
            return 0;
        elsif str_mode = "3PORT" then
            return 1;
        else
            return 0;
        end if;
    end other_port_mode;
    
    signal fmc_din_a        : STD_LOGIC_VECTOR (CHALLENGE_WIDTH-1 downto 0);
    signal fmc_din_b        : STD_LOGIC_VECTOR (CHALLENGE_WIDTH-1 downto 0);
    signal fmc_din_c        : STD_LOGIC_VECTOR (CHALLENGE_WIDTH-1 downto 0);

begin

    -- Signal Routing
    connection_1port: if MODE = "1PORT" generate
    begin
        response_a <= fmc_din_a;
        response_b <= fmc_din_a;
        response_c <= fmc_din_a;
    end generate connection_1port;
    
    connection_3port: if MODE = "3PORT" generate
    begin
        response_a <= fmc_din_a;
        response_b <= fmc_din_b;
        response_c <= fmc_din_c;
    end generate connection_3port;

    -- FMC Data A
    fmc_data_buf_a: if MODE = "1PORT" or MODE = "1PORT_TMR" or MODE = "3PORT" generate
        constant FMC_DIN_PORT_MODE      : integer := 1;
        constant FMC_DOUT_PORT_MODE     : integer := 1;
    begin
        io_buf: for I in 0 to FMC_DATA_WIDTH-1 generate
        begin
        
            output_buf: if I < CHALLENGE_WIDTH generate
            begin
                output_buf_inst: entity work.output_buffer
                    generic map (
                        BUFFER_MODE => FMC_DOUT_PORT_MODE,
                        IOB_EN  => IOB_EN
                    )
                    port map (
                        clk     => clk_a,
                        I0      => challenge(I),
                        O       => fmc_data_a(I)
                    );
            end generate output_buf;
            
            input_buf: if CHALLENGE_WIDTH <= I and I < CHALLENGE_WIDTH + RESPONSE_WIDTH generate
            begin
                input_buf_inst: entity work.input_buffer
                    generic map (
                        BUFFER_MODE => FMC_DIN_PORT_MODE,
                        IOB_EN  => IOB_EN
                    )
                    port map (
                        clk     => clk_a,
                        I       => fmc_data_a(I),
                        O0      => fmc_din_a(I-CHALLENGE_WIDTH)
                    );
                fmc_data_a(I) <= 'Z';
            end generate input_buf;
            
        end generate io_buf;
    end generate fmc_data_buf_a;

    -- FMC Data B
    fmc_data_buf_b: if  MODE = "3PORT" generate
        constant FMC_DIN_PORT_MODE      : integer := 1;
        constant FMC_DOUT_PORT_MODE     : integer := 1;
    begin
        io_buf: for I in 0 to FMC_DATA_WIDTH-1 generate
        begin

            output_buf: if I < CHALLENGE_WIDTH generate
            begin
                output_buf_inst: entity work.output_buffer
                    generic map (
                        BUFFER_MODE => FMC_DOUT_PORT_MODE,
                        IOB_EN  => IOB_EN
                    )
                    port map (
                        clk     => clk_b,
                        I0      => challenge(I),
                        O       => fmc_data_b(I)
                    );
            end generate output_buf;
            
            input_buf: if CHALLENGE_WIDTH <= I and I < CHALLENGE_WIDTH + RESPONSE_WIDTH generate
            begin
                input_buf_inst: entity work.input_buffer
                    generic map (
                        BUFFER_MODE => FMC_DIN_PORT_MODE,
                        IOB_EN  => IOB_EN
                    )
                    port map (
                        clk     => clk_b,
                        I       => fmc_data_b(I),
                        O0      => fmc_din_b(I-CHALLENGE_WIDTH)
                    );
                fmc_data_b(I) <= 'Z';
            end generate input_buf;
            
        end generate io_buf;
    end generate fmc_data_buf_b;

    -- FMC Data C
    fmc_data_buf_c: if  MODE = "3PORT" generate
        constant FMC_DIN_PORT_MODE      : integer := 1;
        constant FMC_DOUT_PORT_MODE     : integer := 1;
    begin
        io_buf: for I in 0 to FMC_DATA_WIDTH-1 generate
        begin
        
            output_buf: if I < CHALLENGE_WIDTH generate
            begin
                output_buf_inst: entity work.output_buffer
                    generic map (
                        BUFFER_MODE => FMC_DOUT_PORT_MODE,
                        IOB_EN  => IOB_EN
                    )
                    port map (
                        clk     => clk_c,
                        I0      => challenge(I),
                        O       => fmc_data_c(I)
                    );
            end generate output_buf;
            
            input_buf: if CHALLENGE_WIDTH <= I and I < CHALLENGE_WIDTH + RESPONSE_WIDTH generate
            begin
                input_buf_inst: entity work.input_buffer
                    generic map (
                        BUFFER_MODE => FMC_DIN_PORT_MODE,
                        IOB_EN  => IOB_EN
                    )
                    port map (
                        clk     => clk_c,
                        I       => fmc_data_c(I),
                        O0      => fmc_din_c(I-CHALLENGE_WIDTH)
                    );
                fmc_data_c(I) <= 'Z';
            end generate input_buf;
            
        end generate io_buf;
    end generate fmc_data_buf_c;

    
    -- FMC Reset
    reset_buf_a: if MODE = "1PORT" or MODE = "3PORT" generate
        constant RST_PORT_MODE      : integer := 1;
    begin
        io_buf: entity work.output_buffer
            generic map (
                BUFFER_MODE => RST_PORT_MODE,
                IOB_EN  => IOB_EN
            )
            port map (
                clk     => clk_a,
                I0      => rst,
                O       => fmc_rst_a
            );
    end generate reset_buf_a;
    
    reset_buf_b: if MODE = "3PORT" generate
        constant RST_PORT_MODE      : integer := 1;
    begin
        io_buf: entity work.output_buffer
            generic map (
                BUFFER_MODE => RST_PORT_MODE,
                IOB_EN  => IOB_EN
            )
            port map (
                clk     => clk_b,
                I0      => rst,
                O       => fmc_rst_b
            );
    end generate reset_buf_b;
    
    reset_buf_c: if MODE = "3PORT" generate
        constant RST_PORT_MODE      : integer := 1;
    begin
        io_buf: entity work.output_buffer
            generic map (
                BUFFER_MODE => RST_PORT_MODE,
                IOB_EN  => IOB_EN
            )
            port map (
                clk     => clk_c,
                I0      => rst,
                O       => fmc_rst_c
            );
    end generate reset_buf_c;

end Behavioral;
