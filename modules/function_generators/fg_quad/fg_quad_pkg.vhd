library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;

package fg_quad_pkg is

component fg_quad_datapath is
  generic (
    CLK_in_Hz:  integer := 125000000
    );
  port (
  data_a:             in  std_logic_vector(15 downto 0);
  data_b:             in  std_logic_vector(15 downto 0);
  clk:                in  std_logic;
  nrst:               in  std_logic;
  a_en, b_en:         in  std_logic;                      -- data register enable
  load_start, s_en:   in  std_logic;
  status_reg_changed: in  std_logic;   
  step_sel:           in  std_logic_vector(2 downto 0);
  shift_b:            in  integer range 0 to 48;          -- shiftvalue coeff b
  shift_a:            in  integer range 0 to 48;          -- shiftvalue coeff a
  freq_sel:           in  std_logic_vector(2 downto 0);
  dreq:               out std_logic;
  sw_out:             out std_logic_vector(23 downto 0);
  sw_strobe:          out std_logic;
  set_out:            out std_logic                       -- debug out
  );
end component fg_quad_datapath;

component fg_quad_scu_bus is
  generic (
    Base_addr:          unsigned(15 downto 0) := X"0300";
    CLK_in_Hz:          integer := 100_000_000;
    diag_on_is_1:       integer range 0 to 1 := 0         -- if 1 then diagnosic information is generated during compilation
    );
  port
    (
    Adr_from_SCUB_LA:   in      std_logic_vector(15 downto 0);  -- latched address from SCU_Bus
    Data_from_SCUB_LA:  in      std_logic_vector(15 downto 0);  -- latched data from SCU_Bus 
    Ext_Adr_Val:        in      std_logic;                      -- '1' => "ADR_from_SCUB_LA" is valid
    Ext_Rd_active:      in      std_logic;                      -- '1' => Rd-Cycle is active
    Ext_Wr_active:      in      std_logic;                      -- '1' => Wr-Cycle is active
    clk:                in      std_logic;                      -- should be the same clk, used by SCU_Bus_Slave
    nReset:             in      std_logic := '1';
    Rd_Port:            out     std_logic_vector(15 downto 0);  -- output for all read sources of this macro
    Rd_Active:          out     std_logic;                      -- this acro has read data available at the Rd_Port.
    Dtack:              out     std_logic;
    dreq:               out     std_logic;
    sw_out:             out     std_logic_vector(23 downto 0);
    sw_strobe:          out     std_logic
    );
end component fg_quad_scu_bus;

end package fg_quad_pkg;