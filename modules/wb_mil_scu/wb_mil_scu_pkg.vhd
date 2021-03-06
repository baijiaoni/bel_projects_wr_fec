library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.wishbone_pkg.all;

library work;


package wb_mil_scu_pkg is

constant  c_mil_byte_addr_range:  integer := 16#2000# * 4;              -- all resources (byte, word, double word) are alligned to modulo 4 addresses,
                                                                        -- so multiply the c_mil_byte_addr_range by 4.
constant  c_mil_addr_width:       integer := integer(ceil(log2(real(c_mil_byte_addr_range))));

constant c_xwb_gsi_mil_scu : t_sdb_device := (
  abi_class     => x"0000",             -- undocumented device
  abi_ver_major => x"01",
  abi_ver_minor => x"00",
  wbd_endian    => c_sdb_endian_big,    -- '1' = little, '0' = big
  wbd_width     => x"4",                -- only 32-bit port granularity allowed
  sdb_component => (
  addr_first    => x"0000000000000000",
  addr_last     => std_logic_vector(to_unsigned(c_mil_byte_addr_range-1, t_sdb_component.addr_last'length)),
  product => (
  vendor_id     => x"0000000000000651", -- GSI
  device_id     => x"35aa6b96",
  version       => x"00000001",
  date          => x"20130826",
  name          => "GSI_MIL_SCU        ")));  -- should be 19 Char


constant  filter_data_width:  integer := 6;
constant  filter_ram_size:    integer := 4096;
constant  filter_addr_width:  integer := integer(ceil(log2(real(filter_ram_size))));

--------------------------------------------------------------------------------------------------------------------------
-- allowed wishbone address offsets for calulating the true wishbone address you have to multiply the constant by 4.    --
-- Only 32 bit access allowed.                                                                                          --
--------------------------------------------------------------------------------------------------------------------------
constant  mil_rd_wr_data_a:   integer := 16#00#;  -- read mil bus:                wb_mil_scu_offset + 16#00#, only allowed when mil data received. Data[31..16] always zero.
                                                  -- write data to mil bus:       wb_mil_scu_offset + 16#00#, only allowed when transmiter free. Data[31..16] don't care.
constant  mil_wr_cmd_a:       integer := 16#01#;  -- write command to mil bus:    wb_mil_scu_offset + 16#04#, only allowed when transmiter free. Data[31..16] don't care.
constant  mil_wr_rd_status_a: integer := 16#02#;  -- read mil status:             wb_mil_scu_offset + 16#08#, data[31..16] always zero.
                                                  -- write mil control reg:       wb_mil_scu_offset + 16#08#, only secific bits can be changed. Data[31..16] don't care.
constant  rd_clr_no_vw_cnt_a: integer := 16#03#;  -- read no valid counters:           wb_mil_scu_offset + 16#0C#. Data[31..16] always zero.
                                                  -- write (clears )no valid counters: wb_mil_scu_offset + 16#0C#. Data[31..0] don't care
constant  rd_wr_not_eq_cnt_a: integer := 16#04#;  -- read not equal counters:     wb_mil_scu_offset + 16#10#. Data[31..16] always zero.
                                                  -- write (clears) not equal counters: wb_mil_scu_offset + 16#10#. Data[31..0] don't care.
constant  rd_clr_ev_fifo_a:   integer := 16#05#;  -- read event fifo:             wb_mil_scu_offset + 16#14#, only allowed when event fifo is not empty. Data[31..16] always zero.
                                                  -- write (clears) event fifo:   wb_mil_scu_offset + 16#14#. Data[31..0] don't care. 
constant  rd_clr_ev_timer_a:  integer := 16#06#;  -- read event timer:            wb_mil_scu_offset + 16#18#.
                                                  -- write (sw-clear) event fifo: wb_mil_scu_offset + 16#18#.
constant  rd_wr_dly_timer_a:  integer := 16#07#;  -- read delay timer:            wb_mil_scu_offset + 16#1C#.
                                                  -- write delay timer:           wb_mil_scu_offset + 16#1C#.
constant  rd_clr_wait_timer_a:integer := 16#08#;  -- read wait timer:             wb_mil_scu_offset + 16#20#.
                                                  -- write (clear) wait timer:    wb_mil_scu_offset + 16#20#.

constant  ev_filt_first_a:    integer := 16#1000#;  -- first event filter ram address: wb_mil_scu_offset + 16#4000. 
constant  ev_filt_last_a:     integer := 16#1FFF#;  -- last event filter  ram address: wb_mil_scu_offset + 16#7FFC.


-- bit positions of mil control/status register
constant  b_sel_fpga_n6408: integer := 15;  -- '1' => fpga manchester endecoder selected, '0' => external hardware manchester endecoder 6408 selected.
constant  b_ev_filt_12_8b:  integer := 14;  -- '1' => event filter decode 12 bit of the event, '0' => event filter decode 8 bit of the event.
constant  b_ev_filt_on:     integer := 13;  -- '1' => event filter is on, '0' => event filter is off.
constant  b_debounce_on:    integer := 12;  -- '1' => debounce of device bus interrupt input is on.
constant  b_puls2_frame:    integer := 11;  -- '1' => aus zwei events wird der Rahmenpuls2 gebildet. Vorausgesetzt das Eventfilter ist richtig programmiert.
constant  b_puls1_frame:    integer := 10;  -- '1' => aus zwei events wird der Rahmenpuls1 gebildet. Vorausgesetzt das Eventfilter ist richtig programmiert.
constant  b_ev_reset_on:    integer := 9;   -- '1' => events koennen den event timer auf Null setzen, vorausgesetzt das Eventfilter ist richtig programmiert.
constant  b_mil_rcv_err:    integer := 8;   -- '1' => an receive error okkurs. If this bit is '1', then it holds information
                                            --        until it's cleared by writing a one to this position of thencontrol register.
constant  b_mil_trm_rdy:    integer := 7;   -- '1' => ready to tranmit data or commands.
constant  b_mil_cmd_rcv:    integer := 6;   -- '1' => command received.
constant  b_mil_rcv_rdy:    integer := 5;   -- '1' => command or data received from mil bus.
constant  b_ev_fifo_full:   integer := 4;   -- '1' => event fifo is full.
constant  b_ev_fifo_ne:     integer := 3;   -- '1' => event fifo is not empty.
constant  b_data_req:       integer := 2;   -- '1' => data request interrupt of device bus is active.
constant  b_data_rdy:       integer := 1;   -- '1' => data ready interrupt of device bus is active.
constant  b_interlock:      integer := 0;   -- '1' => Interlock of device bus is active.



component wb_mil_scu IS 
generic (
    Clk_in_Hz:  INTEGER := 125_000_000    -- Um die Flanken des Manchester-Datenstroms von 1Mb/s genau genug ausmessen zu koennen
                                          -- (kuerzester Flankenabstand 500 ns), muss das Makro mit mindestens 20 Mhz getaktet werden.
    );
port  (
    clk_i:          in    std_logic;
    nRst_i:         in    std_logic;
    slave_i:        in    t_wishbone_slave_in;
    slave_o:        out   t_wishbone_slave_out;
    
    -- encoder (transmiter) signals of HD6408 --------------------------------------------------------------------------------
    nME_BOO:        in      std_logic;      -- HD6408-output: transmit bipolar positive.
    nME_BZO:        in      std_logic;      -- HD6408-output: transmit bipolar negative.
    
    ME_SD:          in      std_logic;      -- HD6408-output: '1' => send data is active.
    ME_ESC:         in      std_logic;      -- HD6408-output: encoder shift clock for shifting data into the encoder. The
                                            --                encoder samples ME_SDI on low-to-high transition of ME_ESC.
    ME_SDI:         out     std_logic;      -- HD6408-input:  serial data in accepts a serial data stream at a data rate
                                            --                equal to encoder shift clock.
    ME_EE:          out     std_logic;      -- HD6408-input:  a high on encoder enable initiates the encode cycle.
                                            --                (Subject to the preceding cycle being completed).
    ME_SS:          out     std_logic;      -- HD6408-input:  sync select actuates a Command sync for an input high
                                            --                and data sync for an input low.

    -- decoder (receiver) signals of HD6408 ---------------------------------------------------------------------------------
    ME_BOI:         out     std_logic;      -- HD6408-input:  A high input should be applied to bipolar one in when the bus is in its
                                            --                positive state, this pin must be held low when the Unipolar input is used.
    ME_BZI:         out     std_logic;      -- HD6408-input:  A high input should be applied to bipolar zero in when the bus is in its
                                            --                negative state. This pin must be held high when the Unipolar input is used.
    ME_UDI:         out     std_logic;      -- HD6408-input:  With ME_BZI high and ME_BOI low, this pin enters unipolar data in to the
                                            --                transition finder circuit. If not used this input must be held low.
    ME_CDS:         in      std_logic;      -- HD6408-output: high occurs during output of decoded data which was preced
                                            --                by a command synchronizing character. Low indicares a data sync.
    ME_SDO:         in      std_logic;      -- HD6408-output: serial data out delivers received data in correct NRZ format.
    ME_DSC:         in      std_logic;      -- HD6408-output: decoder shift clock delivers a frequency (decoder clock : 12),
                                            --                synchronized by the recovered serial data stream.
    ME_VW:          in      std_logic;      -- HD6408-output: high indicates receipt of a VALID WORD.
    ME_TD:          in      std_logic;      -- HD6408-output: take data is high during receipt of data after identification
                                            --                of a sync pulse and two valid Manchester data bits

    -- decoder/encoder signals of HD6408 ------------------------------------------------------------------------------------
--    ME_12MHz:       out     std_logic;      -- HD6408-input:  is connected on layout to ME_DC (decoder clock) and ME_EC (encoder clock)
    

    Mil_BOI:        in      std_logic;      -- connect positive bipolar receiver, in FPGA directed to the external
                                            -- manchester en/decoder HD6408 via output ME_BOI or to the internal FPGA
                                            -- vhdl manchester macro.
    Mil_BZI:        in      std_logic;      -- connect negative bipolar receiver, in FPGA directed to the external
                                            -- manchester en/decoder HD6408 via output ME_BZI or to the internal FPGA
                                            -- vhdl manchester macro.
    Sel_Mil_Drv:    out     std_logic;      -- HD6408-output: active high, enable the external open collector driver to the transformer
    nSel_Mil_Rcv:   out     std_logic;      -- HD6408-output: active low, enable the external differtial receive circuit.
    Mil_nBOO:       out     std_logic;      -- connect bipolar positive output to external open collector driver of
                                            -- the transformer. Source is the external manchester en/decoder HD6408 via
                                            -- nME_BOO or the internal FPGA vhdl manchester macro.
    Mil_nBZO:       out     std_logic;      -- connect bipolar negative output to external open collector driver of
                                            -- the transformer. Source is the external manchester en/decoder HD6408 via
                                            -- nME_BZO or the internal FPGA vhdl manchester macro.
    nLed_Mil_Rcv:   out     std_logic;
    nLed_Mil_Trm:   out     std_logic;
    nLed_Mil_Err:   out     std_logic;
    error_limit_reached:  out   std_logic;
    Mil_Decoder_Diag_p: out   std_logic_vector(15 downto 0);
    Mil_Decoder_Diag_n: out   std_logic_vector(15 downto 0);
    timing:         in      std_logic;
    nLed_Timing:    out     std_logic;
    dly_intr_o:     out     std_logic;
    nLed_Fifo_ne:   out     std_logic;
    ev_fifo_ne_intr_o:  out   std_logic;
    Interlock_Intr_i: in      std_logic;
    Data_Rdy_Intr_i:  in      std_logic;
    Data_Req_Intr_i:  in      std_logic;
    Interlock_Intr_o: out     std_logic;
    Data_Rdy_Intr_o:  out     std_logic;
    Data_Req_Intr_o:  out     std_logic;
    nLed_Interl:    out     std_logic;
    nLed_Dry:       out     std_logic;
    nLed_Drq:       out     std_logic;
    every_10ms_intr_o:  out std_logic;
    io_1:           out     std_logic;
    io_1_is_in:     out     std_logic := '0';
    nLed_io_1:      out     std_logic;
    io_2:           out     std_logic;
    io_2_is_in:     out     std_logic := '0';
    nLed_io_2:      out     std_logic;
    nsig_wb_err:    out     std_logic       -- '0' => gestretchte wishbone access Fehlermeldung

    );
end component wb_mil_scu;

component event_processing is 
  generic (
    clk_in_hz:  INTEGER := 125_000_000    -- Um die Flanken des Manchester-Datenstroms von 1Mb/s genau genug ausmessen zu koennen
                                          -- (kuerzester Flankenabstand 500 ns), muss das Makro mit mindestens 20 Mhz getaktet werden.
    );
  port (
    ev_filt_12_8b:    in    std_logic;
    ev_filt_on:       in    std_logic;
    ev_reset_on:      in    std_logic;
    puls1_frame:      in    std_logic;
    puls2_frame:      in    std_logic;
    timing_i:         in    std_logic;
    clk_i:            in    std_logic;
    nRst_i:           in    std_logic;
    wr_filt_ram:      in    std_logic;
    rd_filt_ram:      in    std_logic;
    rd_ev_fifo:       in    std_logic;
    clr_ev_fifo:      in    std_logic;
    filt_addr:        in    std_logic_vector(filter_addr_width-1 downto 0);
    filt_data_i:      in    std_logic_vector(filter_data_width-1 downto 0);
    stall_o:          out   std_logic;
    read_port_o:      out   std_logic_vector(15 downto 0);
    ev_fifo_ne:       out   std_logic;
    ev_fifo_full:     out   std_logic;
    ev_timer_res:     out   std_logic;
    ev_puls1:         out   std_logic;
    ev_puls2:         out   std_logic;
    timing_received:  out   std_logic
    );
end component event_processing;

component mil_pll is
  port(
    inclk0 : in  std_logic;
    c0     : out std_logic;
    locked : out std_logic);
end component mil_pll;

end package wb_mil_scu_pkg;
