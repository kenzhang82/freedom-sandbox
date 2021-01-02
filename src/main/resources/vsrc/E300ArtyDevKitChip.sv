module E300ArtyDevKitChip #
(
    parameter UART_DIV = 564
)
(
  input  logic        cpu_clock,
  input  logic        cpu_rst_n,
  input  logic        jtag_rst_n
);

    wire [31:0] gpios;
    wire [3:0]  qspi_dq;
    logic cpu_ext_clk;
    logic qspi_sck, qspi_cs;
    logic jtag_tck, jtag_tms, jtag_tdi, jtag_tdo;

    ClockDivider2 ClockDivider2_inst
    (
        .clk_in  (cpu_clock),
        .clk_out (cpu_ext_clk)
    );

    //------------------------------------------------
    // Core
    //------------------------------------------------
    E300ArtyDevKit E300ArtyDevKit_inst
    (
        .cpu_ext_clk (cpu_ext_clk),
        .cpu_clock   (cpu_clock  ),
        .cpu_rst_n   (cpu_rst_n  ),
        .jtag_rst_n  (jtag_rst_n ),
        .jtag_tck    (jtag_tck   ),
        .jtag_tms    (jtag_tms   ),
        .jtag_tdi    (jtag_tdi   ),
        .jtag_tdo    (jtag_tdo   ),
        .gpios       (gpios      ),
        .qspi_sck    (qspi_sck   ),
        .qspi_cs     (qspi_cs    ),
        .qspi_dq     (qspi_dq    )
    );

    //------------------------------------------------
    // External devices
    //------------------------------------------------
    spiflash spiflash_inst
    (
        .clk(qspi_sck  ),
        .csb(qspi_cs   ),
        .io0(qspi_dq[0]),
        .io1(qspi_dq[1]),
        .io2(qspi_dq[2]),
        .io3(qspi_dq[3])
    );

    uart_decoder #
    (
        .CLKS_PER_BIT (UART_DIV)
    )
    uart_decoder_inst
    (
        .clk   (cpu_clock),
        .rst_n (cpu_rst_n),
        .rx    (gpios[17])
    );

endmodule