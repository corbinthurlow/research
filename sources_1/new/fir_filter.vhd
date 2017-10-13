----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/03/2017 04:20:37 PM
-- Design Name: 
-- Module Name: fir_filter - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fir_filter_8 is
    generic(
        DATA_WIDTH  : natural;
        FOURTH_DATA_SIZE   : natural := 4;
        HALF_DATA_SIZE     : natural := 2
    
    );
    Port ( 
           data_in          : in std_logic_vector((DATA_WIDTH) - 1 downto 0);
           data_out         : out std_logic_vector(DATA_WIDTH - 1 downto 0);
           clk              : in std_logic;
           rst              : in std_logic
           );
end fir_filter_8;

architecture Behavioral of fir_filter_8 is
type fir_data is array
    (7 downto 0) of signed((DATA_WIDTH/FOURTH_DATA_SIZE) - 1 downto 0);
type fir_coeff is array 
    (7 downto 0) of signed((DATA_WIDTH/FOURTH_DATA_SIZE) - 1 downto 0);
type fir_mult is array
    (7 downto 0) of signed ((DATA_WIDTH/HALF_DATA_SIZE) - 1 downto 0);
type fir_add0 is array
    (3 downto 0) of signed((DATA_WIDTH/HALF_DATA_SIZE) downto 0);
type fir_add1 is array
    (1 downto 0) of signed((DATA_WIDTH/HALF_DATA_SIZE) + 1 downto 0);

signal coeff_0          : std_logic_vector((DATA_WIDTH/FOURTH_DATA_SIZE) - 1 downto 0);
signal coeff_1          : std_logic_vector((DATA_WIDTH/FOURTH_DATA_SIZE) - 1 downto 0);
signal coeff_2          : std_logic_vector((DATA_WIDTH/FOURTH_DATA_SIZE) - 1 downto 0);
signal coeff_3          : std_logic_vector((DATA_WIDTH/FOURTH_DATA_SIZE) - 1 downto 0);
signal coeff_4          : std_logic_vector((DATA_WIDTH/FOURTH_DATA_SIZE) - 1 downto 0);
signal coeff_5          : std_logic_vector((DATA_WIDTH/FOURTH_DATA_SIZE) - 1 downto 0);
signal coeff_6          : std_logic_vector((DATA_WIDTH/FOURTH_DATA_SIZE) - 1 downto 0);
signal coeff_7          : std_logic_vector((DATA_WIDTH/FOURTH_DATA_SIZE) - 1 downto 0);
signal data_out_next, data_out_reg  : std_logic_vector(DATA_WIDTH - 1 downto 0); 
signal r_data          : fir_data;
signal r_coeff         : fir_coeff;
signal r_mult          : fir_mult;
signal r_add0          : fir_add0;
signal r_add1          : fir_add1;
signal r_add2          : signed((DATA_WIDTH/HALF_DATA_SIZE)+2 downto 0);
signal r_add2_final    : signed((DATA_WIDTH/HALF_DATA_SIZE) - 1 downto 0);

begin

    --put input into each co_eff
    coeff_0 <= data_in(DATA_WIDTH - 1 downto 48);
    coeff_1 <= data_in(DATA_WIDTH - 17 downto 32);
    coeff_2 <= data_in(DATA_WIDTH - 33 downto 16);
    coeff_3 <= data_in(DATA_WIDTH - 49 downto 0);
    coeff_4 <= data_in(DATA_WIDTH - 1 downto 48);
    coeff_5 <= data_in(DATA_WIDTH - 17 downto 32);
    coeff_6 <= data_in(DATA_WIDTH - 33 downto 16);
    coeff_7 <= data_in(DATA_WIDTH - 49 downto 0);
    
    process(clk,rst)
    begin 
        if rst = '1' then
            r_data <= (others=>(others=>'0'));
            r_coeff <= (others=>(others=>'0'));
        elsif clk'event and clk = '1' then
            r_data <= signed(data_in(DATA_WIDTH - 1 downto 48)) & r_data(r_data'length - 2 downto 0);
            r_coeff(0) <= signed(coeff_0);
            r_coeff(1) <= signed(coeff_1);
            r_coeff(2) <= signed(coeff_2);
            r_coeff(3) <= signed(coeff_3);
            r_coeff(4) <= signed(coeff_4);
            r_coeff(5) <= signed(coeff_5);
            r_coeff(6) <= signed(coeff_6);
            r_coeff(7) <= signed(coeff_7);
		end if;
	end process;
	
	
	--process for first multiple stage
	mult0: process(clk,rst)
	begin
		if rst = '1' then
			r_mult <= (others=>(others=>'0'));
		elsif clk'event and clk ='1' then
			for k in 0 to 7 loop
				r_mult(k) <= r_data(k) * r_coeff(k);
			end loop;
		end if;
	end process mult0;
	
	--process for first add stage
	add0: process(clk,rst)
	begin
		if rst = '1' then
			r_add0 <= (others=>(others=>'0'));
		elsif clk'event and clk = '1' then
			for k in 0 to 3 loop
				r_add0(k) <= resize(r_mult(2*k),33) + resize(r_mult(2*k+1),33);
			end loop;
		end if;
	end process add0;
	
	--process for second add stage
	add1: process(clk,rst)
	begin
		if rst = '1' then 
			r_add1 <= (others=>(others=>'0'));
		elsif clk'event and clk = '1' then
			for k in 0 to 1 loop
				r_add1(k) <= resize(r_add0(2*k),34)+ resize(r_add0(2*k+1),34);
			end loop;
		end if;
	end process add1;
	
	--process for third add stage
	add2: process(clk,rst)
	begin
		if rst = '1' then
			r_add2 <= (others=>'0');
		elsif clk'event and clk = '1' then
			r_add2 <= resize(r_add1(0),35) + resize(r_add1(1),35);
		end if;
	end process add2;
	
	--make r_add2 a 32 bit number
	r_add2_final <= r_add2(r_add2'length - 4 downto 0);
	
	--process for outputting 
	output: process(clk,rst)
	begin
		if rst = '1' then
			data_out_reg <= (others=>'0');
		elsif clk'event and clk = '1' then
			data_out_reg <= data_out_next; 
		end if;
	end process output;
	
	--final output
	data_out_next <= std_logic_vector(r_add2_final*r_add2_final);
	data_out <= data_out_reg;

end Behavioral;
