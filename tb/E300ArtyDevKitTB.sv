module E300ArtyDevKitTB;

  //--------------------------------------------------------------------
  // Internal constant and parameter definitions.
  //--------------------------------------------------------------------
  parameter FAST_CLK_HALF_PERIOD    = 7.7;  // 65MHz
  parameter FAST_CLK_PERIOD         = 2 * FAST_CLK_HALF_PERIOD;
  parameter SLOW_CLK_HALF_PERIOD    = 15.4; // 32.5MHz
  parameter SLOW_CLK_PERIOD         = 2 * SLOW_CLK_HALF_PERIOD;
  parameter UART_BAUD_RATE          = 115200; // bits per second
  parameter integer UART_BIT_PERIOD = 1000000000 * 1 / UART_BAUD_RATE;
  parameter integer UART_DIV        = UART_BIT_PERIOD / FAST_CLK_PERIOD;

  //--------------------------------------------------------------------
  // Register and Wire declarations.
  //--------------------------------------------------------------------
  reg         tb_cpu_ext_clk;
  reg         tb_cpu_clock;
  reg         tb_cpu_rst_n;
  reg         tb_jtag_rst_n;
  reg         tb_jtag_tck;
  reg         tb_jtag_tms;
  reg         tb_jtag_tdi;
  wire        tb_jtag_tdo;
  reg         tb_qspi_reset;
  wire [31:0] tb_gpios;
  wire        tb_qspi_sck;
  wire        tb_qspi_cs;
  wire [3:0]  tb_qspi_dq;

  //--------------------------------------------------------------------
  // External devices.
  //--------------------------------------------------------------------
  uart_rx #(
    .NAME("UART0"),
    .DIV(UART_DIV)
  ) debug_uart
  (
    .uart_clk           (tb_cpu_clock  ),
    .rx_data            (tb_gpios[17]  )
  );

  s25fl256s qspi_flash_mem
  (
    .RSTNeg             (tb_qspi_reset ),
    .SCK                (tb_qspi_sck   ),
    .CSNeg              (tb_qspi_cs    ),
    .SI                 (tb_qspi_dq[0] ),
    .SO                 (tb_qspi_dq[1] ),
    .WPNeg              (tb_qspi_dq[2] ),
    .HOLDNeg            (tb_qspi_dq[3] )
  );

  //--------------------------------------------------------------------
  // Device Under Test.
  //--------------------------------------------------------------------
  E300ArtyDevKitTop E300ArtyDevKitTop_inst
  (
    .cpu_ext_clk        (tb_cpu_ext_clk),
    .cpu_clock          (tb_cpu_clock  ),
    .cpu_rst_n          (tb_cpu_rst_n  ),
    .jtag_rst_n         (tb_jtag_rst_n ),

    .jtag_tck           (tb_jtag_tck   ),
    .jtag_tms           (tb_jtag_tms   ),
    .jtag_tdi           (tb_jtag_tdi   ),
    .jtag_tdo           (tb_jtag_tdo   ),

    .gpios              (tb_gpios      ),

    .qspi_sck           (tb_qspi_sck   ),
    .qspi_cs            (tb_qspi_cs    ),
    .qspi_dq            (tb_qspi_dq    )
  );

  //--------------------------------------------------------------------
  // clk_gen
  //
  // Always running clock generator process.
  //--------------------------------------------------------------------
  always begin: fast_clk_gen
    #FAST_CLK_HALF_PERIOD;
    tb_cpu_clock = ~tb_cpu_clock;
  end // fast_clk_gen

  always begin: slow_clk_gen
    #SLOW_CLK_HALF_PERIOD;
    tb_cpu_ext_clk = ~tb_cpu_ext_clk;
  end

  //--------------------------------------------------------------------
  // reset_dut()
  //
  // Toggle reset to put the DUT into a well known state.
  //--------------------------------------------------------------------
  task reset_dut;
    begin
      $display("[TB]: Toggle reset");
      #(5 * SLOW_CLK_PERIOD);
      tb_jtag_rst_n = 1;
      tb_qspi_reset = 0;
      #(5 * FAST_CLK_PERIOD);
      tb_cpu_rst_n  = 1;
      tb_qspi_reset = 1;
    end
  endtask // reset_dut

  //--------------------------------------------------------------------
  // init_sim()
  //
  // Initialize all counters and testbed functionality as well
  // as setting the DUT inputs to defined values.
  //--------------------------------------------------------------------
  task init_sim;
    begin
      tb_cpu_clock   = 0;
      tb_cpu_ext_clk = 0;
      tb_cpu_rst_n   = 0;
      tb_jtag_rst_n  = 0;
      tb_qspi_reset  = 1;
    end
  endtask // init_sim

  //--------------------------------------------------------------------
  // main
  //
  // The main test functionality.
  //--------------------------------------------------------------------
  initial begin: main
    init_sim();
    reset_dut();
    #15ms;
    $finish;
  end // main

endmodule