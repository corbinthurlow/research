-----------------
--lfsr_large.vhd
-----------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;


--entity large_lsfr
entity lfsr_large is
    generic(
	DATA_WIDTH	: natural := 64;
	RST_VALUE   : std_logic_vector(128 - 1 downto 0) := (others=>'1')
	);
    port(
	clk_a		 : in std_logic;
	rst_a        : in std_logic;
	data_out_a   : out std_logic_vector(DATA_WIDTH - 1 downto 0)
);
end lfsr_large;

--architecture
architecture Behavioral of lfsr_large is
    constant LENGTH            : natural := 128;
    constant MAX               : natural := 5000000;
	signal data_next, data_reg     : std_logic_vector(LENGTH - 1 downto 0) := (others=>'1');
	constant Q1                : natural := 29;
	constant Q2                : natural := 17;
	constant Q3                : natural := 2;
	constant Q4                : natural := 0;
	signal tmp                 : std_logic;
	signal en                  : std_logic;
	signal counter             : unsigned(31 downto 0) := (others=>'0');
begin

    process (clk_a) is
    begin
        if clk_a'event and clk_a = '1' then
            if rst_a = '1' then
                data_reg <= RST_VALUE;
            else
                 counter <= counter + 1;
                    if(counter >= MAX) then
                        counter <= (others=>'0');
                        data_reg <= data_next;
                    end if;                
            end if;
         end if;
    end process;
    tmp <= data_reg(Q1) xor data_reg(Q2) xor data_reg(Q3) xor data_reg(Q4);
    data_next <= tmp & data_reg(LENGTH - 1 downto 1);
    --output logic  
    data_out_a <= (data_reg(LENGTH - 1 downto 64) xor data_reg(63 downto 0));
    
    
   
end Behavioral;
