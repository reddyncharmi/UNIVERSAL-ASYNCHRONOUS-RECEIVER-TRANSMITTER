`timescale 1ns/1ps

module uart_tb();

    // Testbench signals
    reg clk;
    reg rst;
    reg [7:0] tx_in;
    reg start;
    wire [7:0] rx_out;
    wire done;

    // 1. Instantiate the Top Module (DUT - Device Under Test)
    uart_top dut (
        .clk(clk),
        .rst(rst),
        .tx_in(tx_in),
        .start(start),
        .rx_out(rx_out),
        .done(done)
    );

    // 2. Clock Generation (50 MHz = 20ns period)
    always #10 clk = ~clk;

    // 3. Stimulus Process
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        start = 0;
        tx_in = 8'h00;

        // Apply Reset
        $display("--- Starting UART Loopback Simulation ---");
        #100 rst = 0;
        #100;

        // --- Test Case 1: Send Data 0x55 ---
        $display("Sending data: 8'h55...");
        tx_in = 8'h55;
        start = 1;      // Pulse start signal
        #20 start = 0;

        // Wait for 'done' signal from Receiver
        // This will take a while because of the 9600 Baud rate
        wait(done); 
        
        #100; // Small delay to observe result
        if (rx_out === 8'h55) begin
            $display("SUCCESS: Received 0x%h correctly!", rx_out);
        end else begin
            $display("ERROR: Received 0x%h, but expected 0x55", rx_out);
        end

        // --- Test Case 2: Send Data 0xAA ---
        #500;
        $display("Sending data: 8'hAA...");
        tx_in = 8'hAA;
        start = 1;
        #20 start = 0;

        wait(done);
        
        #100;
        if (rx_out === 8'hAA) begin
            $display("SUCCESS: Received 0x%h correctly!", rx_out);
        end else begin
            $display("ERROR: Received 0x%h, but expected 0xAA", rx_out);
        end

        $display("--- Simulation Finished ---");
        $finish;
    end

    // 4. (Optional) Waveform Dump
    initial begin
        $dumpfile("uart_sim.vcd");
        $dumpvars(0, uart_tb);
    end

endmodule
