library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity gray_decoder is
   generic(
      g_length :  integer := 8
      );

   port(
      clk_i    :  in std_logic;
      reset_i  :  in std_logic;
      data_in  :  in std_logic_vector(g_length-1 downto 0);
      data_out :  out std_logic_vector(g_length-1 downto 0));
end gray_decoder;

architecture rtl of gray_decoder is

begin
   process(clk_i) 
   begin
      if rising_edge(clk_i) then
         if reset_i  = '0' then
            data_out <= (others => '0');
         else
               data_out(7) <=  data_in(7);
               data_out(6) <=  data_in(7) xor data_in(6);
               data_out(5) <=  data_in(7) xor data_in(6) xor data_in(5);
               data_out(4) <=  data_in(7) xor data_in(6) xor data_in(5) xor data_in(4);               
               data_out(3) <=  data_in(7) xor data_in(6) xor data_in(5) xor data_in(4) xor 
                               data_in(3);
               data_out(2) <=  data_in(7) xor data_in(6) xor data_in(5) xor data_in(4) xor
                               data_in(3) xor data_in(2);
               data_out(1) <=  data_in(7) xor data_in(6) xor data_in(5) xor data_in(4) xor
                               data_in(3) xor data_in(2) xor data_in(1);
               data_out(0) <=  data_in(7) xor data_in(6) xor data_in(5) xor data_in(4) xor 
                               data_in(3) xor data_in(2) xor data_in(1) xor data_in(0);
        end if;
      end if;
   end process;
end rtl;