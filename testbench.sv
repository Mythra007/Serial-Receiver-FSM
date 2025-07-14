`timescale 1ns / 1ps

module tb_receiver;

    // Inputs
    reg clk;
    reg rst;
    reg rx;

    // Outputs
    wire [3:0] data;
    wire done;

    // Instantiate the receiver module (DUT)
    receiver uut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data(data),
        .done(done)
    );

    // Clock generation: 10ns period (100MHz)
    always #5 clk = ~clk;

    // Task to send a 6-bit framed packet: start, 4 data bits (LSB first), stop
    task send_packet(input [3:0] payload);
        integer i;
        begin
            @(posedge clk); #1 rx <= 0; // Start bit
            @(posedge clk); #1;

            for (i = 0; i < 4; i = i + 1) begin
                rx <= payload[i];       // LSB first
                @(posedge clk); #1;
            end

            rx <= 1; // Stop bit
            @(posedge clk); #1;
        end
    endtask

    // Simulation sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        rx  = 1;

        // Hold reset for 2 cycles
        repeat (2) @(posedge clk);
        rst = 0;

        // Send valid packet: 4'b1010
        send_packet(4'b1010);
        repeat (4) @(posedge clk);

        // Send valid packet: 4'b0111
        send_packet(4'b0111);
        repeat (4) @(posedge clk);

        // Send invalid packet: correct start, incorrect stop
        @(posedge clk); #1 rx <= 0;  // Start bit
        @(posedge clk); #1 rx <= 1;
        @(posedge clk); #1 rx <= 0;
        @(posedge clk); #1 rx <= 1;
        @(posedge clk); #1 rx <= 1;
        @(posedge clk); #1 rx <= 0;  // Invalid stop bit

        // Idle recovery
        repeat (6) @(posedge clk); #1;
        rx <= 1;

        // Final valid packet: 4'b1100
        repeat (2) @(posedge clk);
        send_packet(4'b1100);

        // End simulation
        repeat (10) @(posedge clk);
        $finish;
    end

    // EPWave waveform generation
    initial begin
        $dumpfile("receiver.vcd");
        $dumpvars(1, tb_receiver);
        $dumpvars(1, uut);
    end

endmodule
