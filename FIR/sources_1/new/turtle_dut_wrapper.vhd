library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity turtle_dut_wrapper is
    Generic (
        CHALLENGE_WIDTH     : natural;
        RESPONSE_WIDTH      : natural;
        TMR_MODE            : string
    );
    Port ( 
        clk_a               : in  std_logic;
        clk_b               : in  std_logic;
        clk_c               : in  std_logic;
        reset_a             : in  std_logic;
        reset_b             : in  std_logic;
        reset_c             : in  std_logic;
        challenge_a         : in  std_logic_vector (CHALLENGE_WIDTH-1 downto 0);
        challenge_b         : in  std_logic_vector (CHALLENGE_WIDTH-1 downto 0);
        challenge_c         : in  std_logic_vector (CHALLENGE_WIDTH-1 downto 0);
        response_a          : out std_logic_vector (RESPONSE_WIDTH-1 downto 0);
        response_b          : out std_logic_vector (RESPONSE_WIDTH-1 downto 0);
        response_c          : out std_logic_vector (RESPONSE_WIDTH-1 downto 0)
    );
end turtle_dut_wrapper;

architecture Behavioral of turtle_dut_wrapper is

begin

    SIMULATION_MODE: if TMR_MODE = "SIMULATION" generate
		fir_filter : entity work.fir_filter_8
			generic map(
			DATA_WIDTH => 64		
			)
			port map(
			data_out => response_a,
			data_in => challenge_a,
			rst => reset_a,
			clk => clk_a			
			);
    end generate; 
    
    SIMULATION_COARSE_TMR_MODE: if TMR_MODE = "SIMULATION_COARSE_TMR" generate
    -- Instance 3 copies of the HDL module here
    end generate;
    
    EDIF_MODE: if TMR_MODE = "EDIF" generate
    -- Instance the synthesized module here
    end generate;
    
    EDIF_COARSE_TMR_MODE: if TMR_MODE = "EDIF_COARSE_TMR" generate
    -- Instance 3 copies of the synthesized module here
    end generate;
    
    EDIF_FINE_TMR_MODE: if TMR_MODE = "EDIF_FINE_TMR" generate
    -- Instance the triplicated synthesized module here
    end generate;

end Behavioral;
