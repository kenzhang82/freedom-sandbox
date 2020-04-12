module uart_rx
#(
  parameter NAME = "UART",
  parameter DIV = 10 // 100MHz / 10Mbps = 10
)
(
  input uart_clk,
  input rx_data
);

  logic [7:0] data;
  string      line = "";

  string      finishline = "Program has exited with code: ";
  logic       finish_detect = 1'b0;

  // Generate UART clock
  int         count;
  bit         uart_div_clk;
  always_ff @(posedge uart_clk) begin
    if(count==(DIV / 2)) begin
      uart_div_clk = ~uart_div_clk;
      count = 0;
    end
    else begin
      count++;
    end
  end

  always begin
    @uart_div_clk; // wait for 1us initially to avoid X -> 1 transfer and allow UART to go high again after a transfer

    @(negedge rx_data); // wait for rx_data to go low
    @uart_div_clk // sample in the middle of the frames
    for(int i = 0; i < 8; i++) begin
      @uart_div_clk;
      @uart_div_clk;
      data[i] <= rx_data;
    end
    if(data == 8'h0A) begin // Linefeed character detected
      $display("%s: %s", NAME, line);
      if (line.len() > finishline.len() && line.substr(0,finishline.len() - 1) == finishline)
        finish_detect = 1'b1;
        #1;
        line = "";
      end
    else if (data != 8'h0D) begin // Ignore carriage returns, take any other character
      line=$sformatf("%s%c", line, data);
    end
  end

endmodule