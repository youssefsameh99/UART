`timescale 1ns/1ps

module tb_rx;

    // DUT signals
    reg        clk;
    reg        rst;
    reg        PAR_TYP;     // 0 = even, 1 = odd
    reg        PAR_EN;      // 0 = no parity, 1 = parity enabled
    reg        RX_IN;
    reg  [5:0] prescale;
    wire [7:0] P_DATA;
    wire       data_valid;
    wire       parity_error;
    wire       stop_error;

    // Instantiate DUT
    rx uut (
        .clk(clk),
        .rst(rst),
        .PAR_TYP(PAR_TYP),
        .PAR_EN(PAR_EN),
        .RX_IN(RX_IN),
        .prescale(prescale),
        .P_DATA(P_DATA),
        .data_valid(data_valid),
        .parity_error(parity_error),
        .stop_error(stop_error)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #1 clk = ~clk;  // 100 MHz clock
    end

    // Hold bit for prescale cycles
    task hold_bit;
        input bit_val;
        integer k;
        begin
            RX_IN = bit_val;
            for (k = 0; k < prescale; k = k + 1)
                @(negedge clk);
        end
    endtask

    // Test sequence
    initial begin
        prescale = 8;
        rst = 1;
        RX_IN = 1;    // idle line high
        PAR_EN = 0;
        PAR_TYP = 0;

        @(negedge clk);
        rst = 0;

        // Frame 1: send 0xA5 (LSB first), no parity
        hold_bit(0);                // start bit
        hold_bit(1);                // bit0
        hold_bit(0);                // bit1
        hold_bit(1);                // bit2
        hold_bit(0);                // bit3
        hold_bit(0);                // bit4
        hold_bit(1);                // bit5
        hold_bit(0);                // bit6
        hold_bit(1);                // bit7
        hold_bit(1);                // stop bit

        // idle between frames
        hold_bit(1);
        hold_bit(1);

        // Frame 2: send 0x3C (LSB first), no parity
        hold_bit(0);                // start bit
        hold_bit(0);                // bit0
        hold_bit(0);                // bit1
        hold_bit(1);                // bit2
        hold_bit(1);                // bit3
        hold_bit(1);                // bit4
        hold_bit(0);                // bit5
        hold_bit(0);                // bit6
        hold_bit(0);                // bit7
        hold_bit(1);                // stop bit

        // idle before parity test
        hold_bit(1);
        hold_bit(1);

        // Frame 3: send 0x55 with even parity (PAR_EN = 1, PAR_TYP = 0)
        // 0x55 = 8'b01010101 → has four 1's (already even), so parity bit = 0
        PAR_EN = 1;
        PAR_TYP = 0;

        hold_bit(0);                // start bit
        hold_bit(1);                // bit0
        hold_bit(0);                // bit1
        hold_bit(1);                // bit2
        hold_bit(0);                // bit3
        hold_bit(1);                // bit4
        hold_bit(0);                // bit5
        hold_bit(1);                // bit6
        hold_bit(0);                // bit7
        hold_bit(1);                // parity bit (even parity)
        hold_bit(1);                // stop bit

        repeat(20) @(negedge clk);
        $stop;
    end

endmodule
