library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.gencores_pkg.all;
use work.lpc_uart_pkg.all;
use work.monster_pkg.all;

entity scu_control is
  port(
    clk_20m_vcxo_i    : in std_logic;  -- 20MHz VCXO clock
    clk_125m_pllref_i : in std_logic;  -- 125 MHz PLL reference
    clk_125m_local_i  : in std_logic;  -- local clk from 125Mhz oszillator
    nres              : in std_logic; -- powerup reset
    
    -----------------------------------------
    -- UART on front panel
    -----------------------------------------
    uart_rxd_i     : in  std_logic_vector(1 downto 0);
    uart_txd_o     : out std_logic_vector(1 downto 0);
    serial_to_cb_o : out std_logic;
    
    -----------------------------------------
    -- PCI express pins
    -----------------------------------------
    pcie_refclk_i  : in  std_logic;
    pcie_rx_i      : in  std_logic_vector(3 downto 0);
    pcie_tx_o      : out std_logic_vector(3 downto 0);
    nPCI_RESET     : in std_logic;
    
    ------------------------------------------------------------------------
    -- WR DAC signals
    ------------------------------------------------------------------------
    dac_sclk       : out std_logic;
    dac_din        : out std_logic;
    ndac_cs        : out std_logic_vector(2 downto 1);

    -----------------------------------------
    -- LEMO on front panel (LED        = B1/B2 act)
    --                     (lemo_en_in = B1/B2 out)
    -----------------------------------------
    lemo_io        : inout std_logic_vector(2 downto 1);
    lemo_en_in     : out   std_logic_vector(2 downto 1);
    lemo_led       : out   std_logic_vector(2 downto 1);
    
    -----------------------------------------------------------------------
    -- LPC interface from ComExpress
    -----------------------------------------------------------------------
    LPC_AD         : inout std_logic_vector(3 downto 0);
    LPC_FPGA_CLK   : in    std_logic;
    LPC_SERIRQ     : inout std_logic;
    nLPC_DRQ0      : in    std_logic;
    nLPC_FRAME     : in    std_logic;

    -----------------------------------------------------------------------
    -- User LEDs (U1-U4)
    -----------------------------------------------------------------------
    leds_o         : out std_logic_vector(4 downto 1);
    
    -----------------------------------------------------------------------
    -- OneWire
    -----------------------------------------------------------------------
    OneWire_CB     : inout std_logic;
    
    -----------------------------------------------------------------------
    -- QL1 serdes
    -----------------------------------------------------------------------
--    QL1_GXB_RX        : in std_logic_vector(3 downto 0);
--    QL1_GXB_TX        : out std_logic_vector(3 downto 0);
    
    -----------------------------------------------------------------------
    -- AUX SFP 
    -----------------------------------------------------------------------
    sfp1_tx_disable_o : out std_logic := '0';
    --sfp1_txp_o        : out std_logic;
    --sfp1_rxp_i        : in  std_logic;
    
    sfp1_mod0         : in    std_logic; -- grounded by module
    sfp1_mod1         : inout std_logic; -- SCL
    sfp1_mod2         : inout std_logic; -- SDA
    
    -----------------------------------------------------------------------
    -- Timing SFP 
    -----------------------------------------------------------------------
    sfp2_ref_clk_i    : in  std_logic;
    
    sfp2_tx_disable_o : out std_logic := '0';
    sfp2_txp_o        : out std_logic;
    sfp2_rxp_i        : in  std_logic;
    
    sfp2_mod0         : in    std_logic; -- grounded by module
    sfp2_mod1         : inout std_logic; -- SCL
    sfp2_mod2         : inout std_logic; -- SDA
    
    -----------------------------------------------------------------------
    -- LA port
    -----------------------------------------------------------------------
    hpla_ch           : out std_logic_vector(15 downto 0);
    hpla_clk          : out std_logic;

    -----------------------------------------------------------------------
    -- Ext_Conn2
    -----------------------------------------------------------------------
      -- IO_2_5V(0)       -> EXT_CONN2 pin b4
      -- IO_2_5V(1)       -> EXT_CONN2 pin b5
      -- IO_2_5V(2)       -> EXT_CONN2 pin b6
      -- IO_2_5V(3)       -> EXT_CONN2 pin b7
      -- IO_2_5V(4)       -> EXT_CONN2 pin b8
      -- IO_2_5V(5)       -> EXT_CONN2 pin b9
      -- IO_2_5V(6)       -> EXT_CONN2 pin b10
      -- IO_2_5V(7)       -> EXT_CONN2 pin b11
      -- IO_2_5V(8)       -> EXT_CONN2 pin b14
      -- IO_2_5V(9)       -> EXT_CONN2 pin b15
      -- IO_2_5V(10)      -> EXT_CONN2 pin b16
      -- IO_2_5V(11)      -> EXT_CONN2 pin b17
      -- IO_2_5V(12)      -> EXT_CONN2 pin b18
      -- IO_2_5V(13)      -> EXT_CONN2 pin b19
      -- IO_2_5V(14)      -> EXT_CONN2 pin b20
      -- IO_2_5V(15)      -> EXT_CONN2 pin b21
    IO_2_5V:          inout std_logic_vector(15 downto 0);
    
      -- EIO(0)           -> EXT_CONN2 pin a4
      -- EIO(1)           -> EXT_CONN2 pin a5
      -- EIO(2)           -> EXT_CONN2 pin a6
      -- EIO(3)           -> EXT_CONN2 pin a7
      -- EIO(4)           -> EXT_CONN2 pin a8
      -- EIO(5)           -> EXT_CONN2 pin a9
      -- EIO(6)           -> EXT_CONN2 pin a10
      -- EIO(7)           -> EXT_CONN2 pin a11
      -- EIO(8)           -> EXT_CONN2 pin a14
      -- EIO(9)           -> EXT_CONN2 pin a15
      -- EIO(10)          -> EXT_CONN2 pin a16
      -- EIO(11)          -> EXT_CONN2 pin a17
      -- EIO(12)          -> EXT_CONN2 pin a18
      -- EIO(13)          -> EXT_CONN2 pin a19
      -- EIO(14)          -> EXT_CONN2 pin a20
      -- EIO(15)          -> EXT_CONN2 pin a21
      -- EIO(16)          -> EXT_CONN2 pin a23
      -- EIO(17)          -> EXT_CONN2 pin a24
    EIO:              inout std_logic_vector(17 downto 0);
    
    onewire_ext:      inout std_logic;        -- to extension board

    -----------------------------------------------------------------------
    -- EXT CONN3
    -----------------------------------------------------------------------

 --   A_EXT_LVDS_RX     : in  std_logic_vector( 3 downto 0);    -- von Mil-Extension verwendet
 --   A_EXT_LVDS_TX     : out std_logic_vector( 3 downto 0);    -- von Mil-Extension verwendet
 --   A_EXT_LVDS_CLKOUT : out std_logic;                        -- von Mil-Extension verwendet
    A_EXT_LVDS_CLKIN  : in    std_logic;

    a_ext_conn3_a2:     inout std_logic;        -- Optokoppler Interlock
    a_ext_conn3_a3:     inout std_logic;        -- Optokoppler Data Ready
    a_ext_conn3_a6:     inout std_logic;        -- Optokoppler Data Request
    a_ext_conn3_a7:     inout std_logic;        -- Optokoppler Timing
    a_ext_conn3_a10:    inout std_logic;
    a_ext_conn3_a11:    inout std_logic;
    a_ext_conn3_a14:    inout std_logic;
    a_ext_conn3_a15:    inout std_logic;
    a_ext_conn3_a18:    inout std_logic;
    a_ext_conn3_a19:    inout std_logic;
    a_ext_conn3_b4:     inout std_logic;
    a_ext_conn3_b5:     inout std_logic;
    
    -----------------------------------------------------------------------
    -- serial channel SCU bus
    -----------------------------------------------------------------------
    
    --A_MASTER_CON_RX   : in std_logic_vector(3 downto 0);
    --A_MASTER_CON_TX   : out std_logic_vector(3 downto 0);
    
    -----------------------------------------------------------------------
    -- SCU Bus
    -----------------------------------------------------------------------
    A_D               : inout std_logic_vector(15 downto 0);
    A_A               : out   std_logic_vector(15 downto 0);
    A_nTiming_Cycle   : out   std_logic;
    A_nDS             : out   std_logic;
    A_nReset          : out   std_logic;
    nSel_Ext_Data_DRV : out   std_logic;
    A_RnW             : out   std_logic;
    A_Spare           : out   std_logic_vector(1 downto 0);
    A_nSEL            : out   std_logic_vector(12 downto 1);
    A_nDtack          : in    std_logic;
    A_nSRQ            : in    std_logic_vector(12 downto 1);
    A_SysClock        : out   std_logic;
    ADR_TO_SCUB       : out   std_logic;
    nADR_EN           : out   std_logic;
    A_OneWire         : inout std_logic;
    
    -----------------------------------------------------------------------
    -- ComExpress signals
    -----------------------------------------------------------------------
    nTHRMTRIP         : in  std_logic;
    nEXCD0_PERST      : in  std_logic;
    WDT               : in  std_logic;
    A20GATE           : out std_logic := 'Z';
    KBD_RESET         : out std_logic := 'Z';
    nPWRBTN           : out std_logic;
    nFPGA_Res_Out     : out std_logic;
    A_nCONFIG         : out std_logic := '1';
    npci_pme          : out std_logic;                    -- pci power management event, low activ

    
    -----------------------------------------------------------------------
    -- SCU-CB Version
    -----------------------------------------------------------------------
    scu_cb_version    : in  std_logic_vector(3 downto 0); -- must be assigned with weak pull ups
    
    
    -----------------------------------------------------------------------
    -- Parallel Flash
    -----------------------------------------------------------------------
    AD                : out   std_logic_vector(25 downto 1);
    DF                : inout std_logic_vector(15 downto 0);
    ADV_FSH           : out   std_logic;
    nCE_FSH           : out   std_logic;
    CLK_FSH           : out   std_logic;
    nWE_FSH           : out   std_logic;
    nOE_FSH           : out   std_logic;
    nRST_FSH          : out   std_logic;
    WAIT_FSH          : in    std_logic;
    
    -----------------------------------------------------------------------
    -- DDR3
    -----------------------------------------------------------------------
    DDR3_DQ           : inout std_logic_vector(15 downto 0);
    DDR3_DM           : out   std_logic_vector( 1 downto 0);
    DDR3_BA           : out   std_logic_vector( 2 downto 0);
    DDR3_ADDR         : out   std_logic_vector(12 downto 0);
    DDR3_CS_n         : out   std_logic_vector( 0 downto 0);
--    DDR3_DQS          : inout std_logic_vector(1 downto 0);
--    DDR3_DQSn         : inout std_logic_vector(1 downto 0);
    DDR3_RES_n        : out   std_logic;
    DDR3_CKE          : out   std_logic_vector( 0 downto 0);
    DDR3_ODT          : out   std_logic_vector( 0 downto 0);
    DDR3_CAS_n        : out   std_logic;
    DDR3_RAS_n        : out   std_logic;
--    DDR3_CLK          : inout std_logic_vector(0 downto 0);
--    DDR3_CLK_n        : inout std_logic_vector(0 downto 0);
    DDR3_WE_n         : out   std_logic);
    
end scu_control;

architecture rtl of scu_control is
  
  signal kbc_out_port : std_logic_vector(7 downto 0);
  signal s_leds       : std_logic_vector(4 downto 1);
  signal s_lemo_leds  : std_logic_vector(2 downto 1);
  signal clk_ref      : std_logic;
  signal rstn_ref     : std_logic;
  
begin

  main : monster
    generic map(
      g_family     => "Arria II",
      g_project    => "scu_control",
      g_gpio_in    => 1,
      g_gpio_out   => 1,
      g_flash_bits => 24,
      g_lm32_ramsizes => 98304,
      g_en_pcie    => true,
      g_en_scubus  => true,
      g_en_mil     => true,
      g_en_oled    => true,
      g_en_user_ow => true,
      g_en_power_test => false)
    port map(
      core_clk_20m_vcxo_i    => clk_20m_vcxo_i,
      core_clk_125m_sfpref_i => sfp2_ref_clk_i,
      core_clk_125m_pllref_i => clk_125m_pllref_i,
      core_clk_125m_local_i  => clk_125m_local_i,
      core_clk_wr_ref_o      => clk_ref,
      core_rstn_wr_ref_o     => rstn_ref,
      gpio_o(0)              => lemo_io(1),
      gpio_i(0)              => lemo_io(2),
      wr_onewire_io          => OneWire_CB,
      wr_sfp_sda_io          => sfp2_mod2,
      wr_sfp_scl_io          => sfp2_mod1,
      wr_sfp_det_i           => sfp2_mod0,
      wr_sfp_tx_o            => sfp2_txp_o,
      wr_sfp_rx_i            => sfp2_rxp_i,
      wr_dac_sclk_o          => dac_sclk,
      wr_dac_din_o           => dac_din,
      wr_ndac_cs_o           => ndac_cs,
      wr_uart_o              => uart_txd_o(0),
      wr_uart_i              => uart_rxd_i(0),
      led_link_up_o          => s_leds(3),
      led_link_act_o         => s_leds(2),
      led_track_o            => s_leds(4),
      led_pps_o              => s_leds(1),
      pcie_refclk_i          => pcie_refclk_i,
      pcie_rstn_i            => nPCI_RESET,
      pcie_rx_i              => pcie_rx_i,
      pcie_tx_o              => pcie_tx_o,
      scubus_a_a             => A_A,
      scubus_a_d             => A_D,
      scubus_nsel_data_drv   => nSel_Ext_Data_DRV,
      scubus_a_nds           => A_nDS,
      scubus_a_rnw           => A_RnW,
      scubus_a_ndtack        => A_nDtack,
      scubus_a_nsrq          => A_nSRQ,
      scubus_a_nsel          => A_nSEL,
      scubus_a_ntiming_cycle => A_nTiming_Cycle,
      scubus_a_sysclock      => A_SysClock,
      mil_nme_boo_i          => io_2_5v(11),
      mil_nme_bzo_i          => io_2_5v(12),
      mil_me_sd_i            => io_2_5v(10),
      mil_me_esc_i           => io_2_5v(9),
      mil_me_sdi_o           => eio(4),
      mil_me_ee_o            => eio(5),
      mil_me_ss_o            => eio(6),
      mil_me_boi_o           => eio(1),
      mil_me_bzi_o           => eio(2),
      mil_me_udi_o           => eio(3),
      mil_me_cds_i           => io_2_5v(7),
      mil_me_sdo_i           => io_2_5v(5),
      mil_me_dsc_i           => io_2_5v(4),
      mil_me_vw_i            => io_2_5v(6),
      mil_me_td_i            => io_2_5v(8),
      mil_me_12mhz_o         => eio(0),
      mil_boi_i              => io_2_5v(13),
      mil_bzi_i              => io_2_5v(14),
      mil_sel_drv_o          => eio(9),
      mil_nsel_rcv_o         => eio(7),
      mil_nboo_o             => eio(10),
      mil_nbzo_o             => eio(8),
      mil_nled_rcv_o         => a_ext_conn3_b4,
      mil_nled_trm_o         => a_ext_conn3_b5,
      mil_nled_err_o         => a_ext_conn3_a19,
      mil_timing_i           => not a_ext_conn3_a7,
      mil_nled_timing_o      => eio(17),
      mil_nled_fifo_ne_o     => a_ext_conn3_a19,
      mil_interlock_intr_i   => not a_ext_conn3_a2,
      mil_data_rdy_intr_i    => not a_ext_conn3_a3,
      mil_data_req_intr_i    => not a_ext_conn3_a6,
      mil_nled_interl_o      => a_ext_conn3_a15,
      mil_nled_dry_o         => a_ext_conn3_a11,
      mil_nled_drq_o         => a_ext_conn3_a14,
      mil_io1_o              => eio(11),
      mil_io1_is_in_o        => eio(12),
      mil_nled_io1_o         => eio(13),
      mil_io2_o              => eio(14),
      mil_io2_is_in_o        => eio(15),
      mil_nled_io2_o         => eio(16),
      oled_rstn_o            => hpla_ch(8),
      oled_dc_o              => hpla_ch(6),
      oled_ss_o              => hpla_ch(4),
      oled_sck_o             => hpla_ch(2), 
      oled_sd_o              => hpla_ch(10),
      oled_sh_vr_o           => hpla_ch(0),
      ow_io(0)               => onewire_ext,
      ow_io(1)               => A_OneWire,
      power_test_pwm_o       => hpla_ch(14));
 
  -- LPC UART
  lpc_slave: lpc_uart
    port map(
      lpc_clk         => LPC_FPGA_CLK,
      lpc_serirq      => LPC_SERIRQ,
      lpc_ad          => LPC_AD,
      lpc_frame_n     => nLPC_FRAME,
      lpc_reset_n     => nPCI_RESET,
      kbc_out_port    => kbc_out_port,
      kbc_in_port     => x"00",
      serial_rxd      => uart_rxd_i(1),
      serial_txd      => uart_txd_o(1),
      serial_dtr      => open,
      serial_dcd      => '0',
      serial_dsr      => '0',
      serial_ri       => '0',
      serial_cts      => '0',
      serial_rts      => open,
      seven_seg_L     => open,
      seven_seg_H     => open);

  -- fixed scubus signals
  ADR_TO_SCUB <= '1';
  nADR_EN     <= '0';
  A_nReset    <= rstn_ref;
  A_Spare     <= (others => 'Z');
  A_OneWire   <= 'Z';
  
  A20GATE     <= kbc_out_port(1);
  a_ext_conn3_a10 <= '1'; -- wishbone errors should never leave the FPGA!
  
  -- connects the serial ports to the carrier board
  serial_to_cb_o <= '0';
  
  -- Disable SFP1, SFP2=timing
  sfp1_tx_disable_o <= '1';
  sfp2_tx_disable_o <= '0';
  sfp1_mod1 <= 'Z';
  sfp1_mod2 <= 'Z';
  
  -- LEMO control
  lemo_en_in(1) <= '0'; -- output
  lemo_en_in(2) <= '1'; -- input
  lemo_io(2) <= 'Z';
  
  -- Extend LEMO input/outputs to LEDs at 20Hz
  lemo_leds : for i in 1 to 2 generate
    lemo_ledx : gc_extend_pulse
      generic map(
        g_width => 125_000_000/20) -- 20 Hz
      port map(
        clk_i      => clk_ref,
        rst_n_i    => rstn_ref,
        pulse_i    => lemo_io(i),
        extended_o => s_lemo_leds(i));
  end generate;
  
  -- LEDs
  leds_o   <= not s_leds;
  lemo_led <= not s_lemo_leds;
  
  -- Logic analyzer port (0,2,4,6,8,10 = OLED)
  -- Don't put debug clocks too close (makes display flicker)
--  hpla_clk <= 'Z';
  hpla_ch <= (others => 'Z');
  
  -- Parallel Flash not connected
  nRST_FSH <= '0';
  AD <= (others => 'Z');
  DF <= (others => 'Z');
  ADV_FSH  <= 'Z';
  nCE_FSH  <= 'Z';
  CLK_FSH  <= 'Z';
  nWE_FSH  <= 'Z';
  nOE_FSH  <= 'Z';
  
  -- DDR3 not connected
  DDR3_RES_n <= '0';
  DDR3_DQ    <= (others => 'Z');
  DDR3_DM    <= (others => 'Z');
  DDR3_BA    <= (others => 'Z');
  DDR3_ADDR  <= (others => 'Z');
  DDR3_CS_n  <= (others => 'Z');
  DDR3_CKE   <= (others => 'Z');
  DDR3_ODT   <= (others => 'Z');
  DDR3_CAS_n <= 'Z';
  DDR3_RAS_n <= 'Z';
  DDR3_WE_n  <= 'Z';
  
  -- External reset values
  nFPGA_Res_Out <= rstn_ref;
  nPWRBTN    <= '1'; -- never power off atom
  A_nCONFIG  <= '1'; -- altremote_update used instead

end rtl;
