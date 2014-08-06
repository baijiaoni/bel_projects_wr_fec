library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.gray_pack.all;

entity top_gray is
end top_gray;


architecture behavior of top_gray is

   signal clk     : std_logic := '0';
   signal reset   : std_logic := '0'; 
   signal count   : integer := 0;
   signal data_enc: std_logic_vector(7 downto 0);
   signal data    : std_logic_vector(7 downto 0);
   constant clk_p : time := 8 ns;
begin

   encoder : gray_encoder
      port map(
         clk_i    => clk,
         reset_i  => reset,
         data_in  => std_logic_vector(to_unsigned(count,8)),
         data_out => data_enc);

   decoder : gray_decoder
      port map(
         clk_i    => clk,
         reset_i  => reset,
         data_in  => data_enc,
         data_out => data);

   clk_proc : process
   begin
      clk   <= '0';
      wait for clk_p/2;
      clk   <= '1';
      wait for clk_p/2;
      count <= count+1;
   end process;
end;



