library IEEE;
use IEEE.std_logic_1164.ALL;

use work.voter_pkg.all;

entity turtle_dut_io is
    Generic (
        DOUT_WIDTH          : natural := 64;
        RESET_IN_TMR        : boolean := false;
        RESET_OUT_TMR       : boolean := false;
        DOUT_IN_TMR         : boolean := false;
        DOUT_OUT_TMR        : boolean := false
    );
    Port ( 
        clk_a               : in  std_logic;
        clk_b               : in  std_logic;
        clk_c               : in  std_logic;
        reset_in            : in  std_logic := '0';
        reset_in_a          : in  std_logic := '0';
        reset_in_b          : in  std_logic := '0';
        reset_in_c          : in  std_logic := '0';
        reset_out           : out std_logic := '0';
        reset_out_a         : out std_logic := '0';
        reset_out_b         : out std_logic := '0';
        reset_out_c         : out std_logic := '0';
        dout_in             : in  std_logic_vector (DOUT_WIDTH-1 downto 0) := (others=>'0');
        dout_in_a           : in  std_logic_vector (DOUT_WIDTH-1 downto 0) := (others=>'0');
        dout_in_b           : in  std_logic_vector (DOUT_WIDTH-1 downto 0) := (others=>'0');
        dout_in_c           : in  std_logic_vector (DOUT_WIDTH-1 downto 0) := (others=>'0');
        dout_out            : out std_logic_vector (DOUT_WIDTH-1 downto 0) := (others=>'0');
        dout_out_a          : out std_logic_vector (DOUT_WIDTH-1 downto 0) := (others=>'0');
        dout_out_b          : out std_logic_vector (DOUT_WIDTH-1 downto 0) := (others=>'0');
        dout_out_c          : out std_logic_vector (DOUT_WIDTH-1 downto 0) := (others=>'0')
    );
end turtle_dut_io;

architecture Behavioral of turtle_dut_io is
    signal reset_next_a     : std_logic;
    signal reset_next_b     : std_logic;
    signal reset_next_c     : std_logic;
    signal reset_reg_a      : std_logic;
    signal reset_reg_b      : std_logic;
    signal reset_reg_c      : std_logic;
    
    signal dout_next_a      : std_logic_vector (DOUT_WIDTH-1 downto 0);
    signal dout_next_b      : std_logic_vector (DOUT_WIDTH-1 downto 0);
    signal dout_next_c      : std_logic_vector (DOUT_WIDTH-1 downto 0);
    signal dout_reg_a       : std_logic_vector (DOUT_WIDTH-1 downto 0);
    signal dout_reg_b       : std_logic_vector (DOUT_WIDTH-1 downto 0);
    signal dout_reg_c       : std_logic_vector (DOUT_WIDTH-1 downto 0);
begin
    -- reset_in
    reset_in_tmr_gen: if RESET_IN_TMR = TRUE generate
    begin
        reset_next_a <= reset_in_a;
        reset_next_b <= reset_in_b;
        reset_next_c <= reset_in_c;
    end generate;
    
    reset_in_gen: if RESET_IN_TMR = FALSE generate
    begin
        reset_next_a <= reset_in;
        reset_next_b <= reset_in;
        reset_next_c <= reset_in;
    end generate;

    -- reset_out
    reset_out_tmr_gen: if RESET_OUT_TMR = TRUE generate
    begin
        process (clk_a) is
        begin
            if rising_edge(clk_a) then
                reset_reg_a <= reset_next_a;
            end if;
        end process;
        reset_out_a <= reset_reg_a;
    
        process (clk_b) is
        begin
            if rising_edge(clk_b) then
                reset_reg_b <= reset_next_b;
            end if;
        end process;
        reset_out_b <= reset_reg_b;
        
        process (clk_c) is
        begin
            if rising_edge(clk_c) then
                reset_reg_c <= reset_next_c;
            end if;
        end process;
        reset_out_c <= reset_reg_c;
    end generate;
    
    reset_out_gen: if RESET_OUT_TMR = FALSE generate
    begin
        process (clk_a) is
        begin
            if rising_edge(clk_a) then
                reset_reg_a <= vote(reset_next_a, reset_next_b, reset_next_c);
            end if;
        end process;
        reset_out <= reset_reg_a;
    end generate;
    
    
    -- dout_in
    dout_in_tmr_gen: if DOUT_IN_TMR = TRUE generate
    begin
        dout_next_a <= dout_in_a;
        dout_next_b <= dout_in_b;
        dout_next_c <= dout_in_c;
    end generate;
    
    dout_in_gen: if DOUT_IN_TMR = FALSE generate
    begin
        dout_next_a <= dout_in; --previously dout_in
        dout_next_b <= dout_in; --previously dout_in
        dout_next_c <= dout_in; --previously dout_in
    end generate;
    
    -- dout_out
    dout_out_tmr_gen: if DOUT_OUT_TMR = TRUE generate
    begin
        process (clk_a) is
        begin
            if rising_edge(clk_a) then
                dout_reg_a <= dout_next_a;
            end if;
        end process;
        dout_out_a <= dout_reg_a;
    
        process (clk_b) is
        begin
            if rising_edge(clk_b) then
                dout_reg_b <= dout_next_b;
            end if;
        end process;
        dout_out_b <= dout_reg_b;
        
        process (clk_c) is
        begin
            if rising_edge(clk_c) then
                dout_reg_c <= dout_next_c;
            end if;
        end process;
        dout_out_c <= dout_reg_c;
    end generate;
    
    dout_out_gen: if DOUT_OUT_TMR = FALSE generate
    begin
        process (clk_a) is
        begin
            if rising_edge(clk_a) then
                dout_reg_a <= vote(dout_next_a, dout_next_b, dout_next_c);
            end if;
        end process;
        dout_out <= dout_reg_a;
    end generate;
    
    


end Behavioral;
