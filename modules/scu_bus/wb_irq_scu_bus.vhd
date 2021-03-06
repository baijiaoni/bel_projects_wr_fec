library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

use work.wishbone_pkg.all;
use work.wb_irq_pkg.all;
use work.scu_bus_pkg.all;

entity wb_irq_scu_bus is
  generic (
            g_interface_mode      : t_wishbone_interface_mode       := PIPELINED;
            g_address_granularity : t_wishbone_address_granularity  := BYTE;
            clk_in_hz             : integer := 62_500_000;
            time_out_in_ns        : integer := 250;
            test                  : integer range 0 to 1 := 0);
  port (
        clk_i               : std_logic;
        rst_n_i             : std_logic;
        
        irq_master_o        : out t_wishbone_master_out;
        irq_master_i        : in t_wishbone_master_in;
        
        scu_slave_o         : buffer t_wishbone_slave_out;
        scu_slave_i         : in t_wishbone_slave_in;
        
        scub_data           : inout std_logic_vector(15 downto 0);
        nscub_ds            : out std_logic;
        nscub_dtack         : in std_logic;
        scub_addr           : out std_logic_vector(15 downto 0);
        scub_rdnwr          : out std_logic;
        nscub_srq_slaves    : in std_logic_vector(11 downto 0);
        nscub_slave_sel     : out std_logic_vector(11 downto 0);
        nscub_timing_cycle  : out std_logic;
        nsel_ext_data_drv   : out std_logic);
end entity;


architecture wb_irq_scu_bus_arch of wb_irq_scu_bus is
  signal scu_srq_active : std_logic_vector(11 downto 0);
begin
  scub_master : wb_scu_bus 
    generic map(
      g_interface_mode      => g_interface_mode,
      g_address_granularity => g_address_granularity,
      CLK_in_Hz             => 62_500_000,
      Test                  => 0,
      Time_Out_in_ns        => 350)
   port map(
     clk          => clk_i,
     nrst         => rst_n_i,
     slave_i      => scu_slave_i,
     slave_o      => scu_slave_o,
     srq_active   => scu_srq_active,
     
     SCUB_Data          => scub_data,
     nSCUB_DS           => nscub_ds,
     nSCUB_Dtack        => nscub_dtack,
     SCUB_Addr          => scub_addr,
     SCUB_RDnWR         => scub_rdnwr,
     nSCUB_SRQ_Slaves   => nscub_srq_slaves,
     nSCUB_Slave_Sel    => nscub_slave_sel,
     nSCUB_Timing_Cycle => nscub_timing_cycle,
     nSel_Ext_Data_Drv  => nsel_ext_data_drv);
     
     
  irq_master: irqm_core
  generic map (
    g_channels => 12,     -- 12 scu bus irq lines
    g_round_rb => true,   -- round robin scheduler
    g_det_edge => true)   -- trigger on edge
  port map (
    clk_i   => clk_i,
    rst_n_i => rst_n_i,
    
    -- msi if
    irq_master_o => irq_master_o,
    irq_master_i => irq_master_i,
    
    -- configuration
    -- do not use the lower two bits of the address
    msi_dst_array => (x"00000030",x"0000002c",x"00000028",x"00000024",
                      x"00000020",x"0000001c",x"00000018",x"00000014",
                      x"00000010",x"0000000c",x"00000008",x"00000004"),
    msi_msg_array => (x"00000000",x"00000000",x"00000000",x"00000000",
                      x"00000000",x"00000000",x"00000000",x"00000000",
                      x"00000000",x"00000000",x"00000000",x"00000000"),
                      
    -- irq lines
    en_i    => '1',
    mask_i  => x"FFF",
    irq_i   => scu_srq_active);
                      
end architecture;
