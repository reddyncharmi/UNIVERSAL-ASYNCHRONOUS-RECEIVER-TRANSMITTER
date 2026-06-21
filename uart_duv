// ==========================================================
// VLSI INTERNSHIP PROJECT: UART COMPLETE DESIGN (TX, RX, TOP)
// ==========================================================

// 1. UART TRANSMITTER MODULE
module uart_tx (
    input wire clk,           // 50 MHz
    input wire rst,           // Active high reset
    input wire [7:0] tx_data, // 8-bit data to send
    input wire tx_start,      // Start signal
    output reg tx_serial,     // Serial output line
    output reg tx_busy        // High during transmission
);
    parameter CLK_FREQ = 50000000;
    parameter BAUD_RATE = 9600;
    localparam TICK_COUNT = CLK_FREQ / BAUD_RATE;

    reg [15:0] baud_counter;
    reg [3:0] bit_index;
    reg [9:0] shift_reg; // [Stop Bit (1), Data(7:0), Start Bit (0)]

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_serial    <= 1'b1; // Idle high
            tx_busy      <= 1'b0;
            baud_counter <= 0;
            bit_index    <= 0;
        end else if (!tx_busy && tx_start) begin
            tx_busy      <= 1'b1;
            shift_reg    <= {1'b1, tx_data, 1'b0}; // LSB First transmission
            bit_index    <= 0;
            baud_counter <= 0;
        end else if (tx_busy) begin
            if (baud_counter < TICK_COUNT - 1) begin
                baud_counter <= baud_counter + 1;
            end else begin
                baud_counter <= 0;
                tx_serial    <= shift_reg[bit_index];
                if (bit_index < 9)
                    bit_index <= bit_index + 1;
                else
                    tx_busy <= 1'b0;
            end
        end
    end
endmodule

// 2. UART RECEIVER MODULE
module uart_rx (
    input wire clk,           // 50 MHz
    input wire rst,           // Active high reset
    input wire rx_serial,     // Serial input line
    output reg [7:0] rx_data, // Reconstructed 8-bit data
    output reg rx_done        // High for one clock when data ready
);
    parameter CLK_FREQ = 50000000;
    parameter BAUD_RATE = 9600;
    localparam TICK_COUNT = CLK_FREQ / BAUD_RATE;

    reg [15:0] baud_counter;
    reg [3:0] bit_index;
    reg rx_busy;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_busy      <= 0;
            rx_done      <= 0;
            baud_counter <= 0;
            bit_index    <= 0;
            rx_data      <= 8'h00;
        end else if (!rx_busy && !rx_serial) begin // Detect Start Bit (0)
            rx_busy      <= 1;
            rx_done      <= 0;
            baud_counter <= 0;
            bit_index    <= 0;
        end else if (rx_busy) begin
            if (baud_counter < TICK_COUNT - 1) begin
                baud_counter <= baud_counter + 1;
            end else begin
                baud_counter <= 0;
                // Capture data bits 1 through 8
                if (bit_index > 0 && bit_index < 9) begin
                    rx_data[bit_index-1] <= rx_serial;
                end
                
                if (bit_index < 9)
                    bit_index <= bit_index + 1;
                else begin
                    rx_busy <= 0;
                    rx_done <= 1; // 8-bit data reconstruction complete
                end
            end
        end else begin
            rx_done <= 0;
        end
    end
endmodule

// 3. TOP MODULE (LOOPBACK)
module uart_top (
    input wire clk,           // 50 MHz
    input wire rst,           // Global Reset
    input wire [7:0] tx_in,   // Parallel Data In
    input wire start,         // Start Pulse
    output wire [7:0] rx_out, // Parallel Data Out
    output wire done          // Reception complete flag
);
    wire loopback_signal; // Connects TX serial out to RX serial in

    // Transmitter Instance
    uart_tx TX_UNIT (
        .clk(clk),
        .rst(rst),
        .tx_data(tx_in),
        .tx_start(start),
        .tx_serial(loopback_signal),
        .tx_busy()
    );

    // Receiver Instance
    uart_rx RX_UNIT (
        .clk(clk),
        .rst(rst),
        .rx_serial(loopback_signal),
        .rx_data(rx_out),
        .rx_done(done)
    );

endmodule

