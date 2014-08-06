library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;


entity gray_encoder is
   generic(
      g_length :  integer := 8
      );

   port(
      clk_i    :  in std_logic;
      reset_i  :  in std_logic;
      data_in  :  in std_logic_vector(g_length-1 downto 0);
      data_out :  out std_logic_vector(g_length-1 downto 0));
end gray_encoder;

architecture rtl of gray_encoder is

begin
   clk : process(clk_i)
		variable data_srl : unsigned(g_length-1 downto 0);
   begin
      if rising_edge(clk_i) then
         if reset_i  = '0' then
            data_out <= (others => '0');
         else
				data_srl := (unsigned(data_in) srl 1);
            data_out <= ( std_logic_vector(data_srl) xor data_in);
         end if;
      end if;
   end process;
end rtl;






