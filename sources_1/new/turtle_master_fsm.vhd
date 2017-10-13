library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity turtle_master_fsm is
    Generic (
        RESET_VAL       : natural := 50_000;
        DELAY_VAL       : natural := 0
    );
    Port ( 
        clk             : in  STD_LOGIC;
        ext_reset       : in  STD_LOGIC;
        bscan_reset     : in  STD_LOGIC;
        reset_out       : out STD_LOGIC;
        cmp_en          : out STD_LOGIC
    );
end turtle_master_fsm;

architecture Behavioral of turtle_master_fsm is
    constant COUNTER_WIDTH      : natural := 16;
    signal counter              : unsigned (COUNTER_WIDTH-1 downto 0);
    
    constant NUM_STATES         : natural := 4;
    constant INIT_ST            : std_logic_vector (NUM_STATES-1 downto 0) := (0=>'1', others=>'0');
    constant RESET_ST           : std_logic_vector (NUM_STATES-1 downto 0) := (1=>'1', others=>'0');
    constant DELAY_ST           : std_logic_vector (NUM_STATES-1 downto 0) := (2=>'1', others=>'0');
    constant CMP_ST             : std_logic_vector (NUM_STATES-1 downto 0) := (3=>'1', others=>'0');
    signal state_reg            : std_logic_vector (NUM_STATES-1 downto 0) := INIT_ST;
    
begin

    -- Reset Logic
    process (clk) is
    begin
        if rising_edge(clk) then
            reset_out <= '0';
            cmp_en <= '0';

            -- External reset jumps to reset state
            if ext_reset = '1' or bscan_reset = '1'  then
                counter <= to_unsigned(RESET_VAL-1, COUNTER_WIDTH);
                state_reg <= RESET_ST;
            end if;
        
            -- State machine
            case state_reg is   
                when INIT_ST =>
                    -- Next State
                    counter <= to_unsigned(RESET_VAL-1, COUNTER_WIDTH);
                    state_reg <= RESET_ST;
                    
                when RESET_ST =>
                    -- Output
                    reset_out <= '1';
                    -- Next State
                    if counter > 0 then
                        counter <= counter - 1;
                    elsif DELAY_VAL > 0 then
                        counter <= to_unsigned(DELAY_VAL-1, COUNTER_WIDTH);
                        state_reg <= DELAY_ST;
                    else
                        state_reg <= CMP_ST;
                    end if;
                    
                when DELAY_ST =>
                    -- Next State
                    if counter > 0 then
                        counter <= counter - 1;
                    else
                        state_reg <= CMP_ST;
                    end if;
                
                when CMP_ST =>
                    -- Output
                    cmp_en <= '1';
                
                when others =>
                    -- Should never arrive here!
                
            end case;
            
        end if;
    end process;

end Behavioral;
