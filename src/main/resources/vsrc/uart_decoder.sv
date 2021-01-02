//////////////////////////////////////////////////////////////////////
// Emulator-friendly implementation of uart decoder
//
// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87
//////////////////////////////////////////////////////////////////////

module uart_decoder #
(
    parameter NAME = "UART",
    parameter CLKS_PER_BIT = 10
)
(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       rx
);

    localparam LINE_FEED = 8'h0A; // Linefeed characters
    localparam CARR_RET  = 8'h0D; // Carriage returns

    typedef enum logic [2:0]
    {
        IDLE,
        START_BIT,
        DATA_BITS,
        STOP_BIT,
        DONE
    } uart_state_t;
    uart_state_t state;

    logic [9:0] clk_count;
    logic [2:0] bit_index;
    logic [7:0] byte_out;
    logic       byte_ready;
    logic [120*8-1:0] line;
    logic [8:0] pos;
    string str;

    always_ff @(posedge clk) begin
        if (~rst_n) begin
            clk_count  <= 10'h0;
            bit_index  <= 3'h0;
            byte_out   <= 8'h0;
            byte_ready <= 1'b0;
            state      <= IDLE;
        end
        else begin
            case (state)
                IDLE: begin
                    clk_count <= 10'h0;
                    bit_index <= 3'h0;
                    if (rx == 1'b0) begin
                        state <= START_BIT;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                START_BIT: begin
                    if (clk_count == (CLKS_PER_BIT-1)/2) begin
                        if (rx == 1'b0) begin
                            clk_count <= 10'h0;
                            state     <= DATA_BITS;
                        end
                        else begin
                            state <= IDLE;
                        end
                    end
                    else begin
                        clk_count <= clk_count + 1;
                        state     <= DATA_BITS;
                    end
                end
                DATA_BITS: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                        state     <= DATA_BITS;
                    end
                    else begin
                        clk_count           <= 10'h0;
                        byte_out[bit_index] <= rx;

                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                            state     <= DATA_BITS;
                        end
                        else begin
                            bit_index <= 3'h0;
                            state     <= STOP_BIT;
                        end
                    end
                end
                STOP_BIT: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                        state     <= STOP_BIT;
                    end
                    else begin
                        clk_count  <= 10'h0;
                        byte_ready <= 1'b1;
                        state      <= DONE;
                    end
                end
                DONE: begin
                    byte_ready <= 1'b0;
                    state      <= IDLE;
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (~rst_n) begin
            str <= "";
        end
        else if (byte_ready) begin
            // Only take-in ASCII characters
            if (byte_out >= 8'h00 && byte_out <= 8'h7F) begin
                // Linefeed character detected
                if(byte_out == LINE_FEED) begin
                    $display("%s: %s", NAME, str);
                end
                else if (byte_out != CARR_RET) begin
                    str <= $sformatf("%s%s", str, string'(byte_out));
                end
            end
        end
    end

endmodule