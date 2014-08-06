library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

package gray_pack is

   component xgray_encoder is
      generic(
         g_length :  integer := 16);
      port(
         clk_i    : in  std_logic;
         reset_i  : in  std_logic;
         start_i  : in  std_logic;
         stall_i  : in  std_logic;
         enc_o    : out std_logic_vector(g_length-1 downto 0));
   end component;


   component gray_encoder is
      generic(
         g_length :  integer := 8);

      port(
         clk_i    :  in std_logic;
         reset_i  :  in std_logic;
         data_in  :  in std_logic_vector(g_length-1 downto 0);
         data_out :  out std_logic_vector(g_length-1 downto 0));
   end component;

   component gray_decoder is
      generic(
         g_length :  integer := 8);

      port(
         clk_i    :  in std_logic;
         reset_i  :  in std_logic;
         data_in  :  in std_logic_vector(g_length-1 downto 0);
         data_out :  out std_logic_vector(g_length-1 downto 0));
   end component;

end gray_pack;


