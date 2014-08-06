library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;


library work;
use work.gray_pack.all;


entity xgray_encoder is
   generic(
      g_length :  integer := 16);
   port(
      clk_i    : in  std_logic;
      reset_i  : in  std_logic;
      start_i  : in  std_logic;
      stall_i  : in  std_logic;
      enc_o    : out std_logic_vector(g_length-1 downto 0)); 
end xgray_encoder;

architecture rtl of xgray_encoder is

   signal s_cntr_std : std_logic_vector(g_length-1 downto 0) := x"0000";
	signal s_cntr     : integer := 0;
   signal s_enc      : std_logic_vector(g_length-1 downto 0) := x"0000";
   signal s_temp     : std_logic_vector(g_length-1 downto 0) := x"0000";
   signal s_start    : std_logic;
   type   stalling   is (STOP,COUNTING,STALL);
   signal fsm        :   stalling := STOP;
begin   

   encoder  : gray_encoder
   generic map( 
      g_length => 16)
   port map(
      clk_i    => clk_i,
      reset_i  => reset_i,
      data_in  => s_cntr_std,
      data_out => s_enc);
	
	s_cntr_std <= std_logic_vector(to_unsigned(s_cntr,g_length));
   s_start  <= start_i;

   with fsm select
   enc_o    <= s_enc    when STOP,
               s_enc    when COUNTING,
               s_temp   when STALL;

   input2gray : process(clk_i)
   variable one_time : boolean := TRUE;
   begin
      if rising_edge(clk_i) then
         if reset_i = '0' then
            s_cntr   <= 0;
         else
             case fsm is
               when STOP      =>
                  if (s_start = '1' and stall_i = '0') then
                     fsm <= COUNTING;     
                     s_cntr      <= s_cntr + 1;
                  end if;
               when COUNTING  =>
                  if (s_start = '1' and stall_i = '0') then
                     s_cntr      <= s_cntr + 1;
                  elsif (s_start = '1' and stall_i = '1') then               
                     fsm <= STALL;
                     s_temp      <= s_enc;
                  end if;
               when STALL  =>
                  if (s_start = '1' and stall_i = '0') then
                     fsm         <= COUNTING;
                     s_cntr      <= s_cntr + 1;
                  elsif (s_start = '0' and stall_i = '0') then
                     fsm         <= STOP;
                  end if;
               end case;
          end if;
      end if;
  end process;
end rtl;
