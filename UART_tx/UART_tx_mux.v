module mux(
    input [1:0] mux_sel,
    input serialdata, paritybit,
    output reg out
);

always @(*) begin
    case(mux_sel)
        0: out = 0;           // start bit
        1: out = 1;           // stop bit
        2: out = serialdata;  // data bits
        3: out = paritybit;   // parity
    endcase
end

endmodule