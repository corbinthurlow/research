----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 09/20/2017 03:17:35 PM
-- Design Name:
-- Module Name: lfsr_large_tb - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lfsr_large_tb is
end lfsr_large_tb;

architecture Behavioral of lfsr_large_tb is
    signal clk_tb          : std_logic;
    signal reset_tb     : std_logic;
    constant DATA_WIDTH : natural := 64;
    signal data_out_tb,data_out_tb_prev  : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others =>'0');

begin
    clk50mhz_process: process
    begin
        clk_tb <= '0';
        wait for 10ns;
        clk_tb <= '1';
        wait for 10ns;
    end process;
    
    
    lfsr_large_lower : entity work.lfsr_large
            generic map(
                DATA_WIDTH => DATA_WIDTH
    
            )
            port map(
                clk_a => clk_tb,
                rst_a => reset_tb,
                data_out_a => data_out_tb    
            );
    
    

    simulation: process
    begin
        wait for 1000ns;
        reset_tb <= '1';
        wait for 20ns;
        assert data_out_tb = (data_out_tb'range=>'0')  report "Value did not reset";
        wait for 30ns;
        
        
        reset_tb <= '0';
        wait for 2000ns;
        
        assert data_out_tb /= (data_out_tb'range=>'0') report "Value should not be all 0's" severity ERROR;        
        data_out_tb_prev <= data_out_tb;
        reset_tb <= '0';
        wait for 100ns;
        
        assert data_out_tb /= data_out_tb_prev report "Error value should have changed" severity ERROR;
        reset_tb <= '0';
        wait for 2000ns;
        reset_tb <= '0';

        wait for 200ns;
        reset_tb <= '0';

        wait for 1000ns;
        reset_tb <= '0';

     end process;

     




end Behavioral;
