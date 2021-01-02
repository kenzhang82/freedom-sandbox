module E300ArtyDevKitTB;

  //--------------------------------------------------------------------
  // Internal constant and parameter definitions.
  //--------------------------------------------------------------------
  parameter TB_CLK_HALF_PERIOD      = 7.5;  // 60MHz
  parameter TB_CLK_PERIOD           = 2 * TB_CLK_HALF_PERIOD;
  parameter UART_BAUD_RATE          = 115200; // bits per second
  parameter integer UART_BIT_PERIOD = 1000000000 * 1 / UART_BAUD_RATE;
  parameter integer UART_DIV        = UART_BIT_PERIOD / TB_CLK_PERIOD;

  //--------------------------------------------------------------------
  // Register and Wire declarations.
  //--------------------------------------------------------------------
  logic tb_cpu_clock;
  logic tb_cpu_rst_n;
  logic tb_jtag_rst_n;

  //--------------------------------------------------------------------
  // Device Under Test.
  //--------------------------------------------------------------------
  E300ArtyDevKitChip #
  (
    .UART_DIV (UART_DIV)
  )
  E300ArtyDevKitChip_inst
  (
    .cpu_clock          (tb_cpu_clock  ),
    .cpu_rst_n          (tb_cpu_rst_n  ),
    .jtag_rst_n         (tb_jtag_rst_n )
  );

  //--------------------------------------------------------------------
  // clk_gen
  //
  // Always running clock generator process.
  //--------------------------------------------------------------------
  always begin: fast_clk_gen
    #TB_CLK_HALF_PERIOD;
    tb_cpu_clock = ~tb_cpu_clock;
  end // fast_clk_gen

  //--------------------------------------------------------------------
  // reset_dut()
  //
  // Toggle reset to put the DUT into a well known state.
  //--------------------------------------------------------------------
  task reset_dut;
    begin
      $display("[TB]: Toggle reset");
      #(5 * TB_CLK_PERIOD);
      tb_jtag_rst_n = 1;
      #(5 * TB_CLK_PERIOD);
      tb_cpu_rst_n  = 1;
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
      tb_cpu_rst_n   = 0;
      tb_jtag_rst_n  = 0;
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