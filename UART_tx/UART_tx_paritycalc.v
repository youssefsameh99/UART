module paritycalc(
    input PAR_TYP,
    input [7:0] P_DATA,
    output paritybit
);
assign paritybit = (PAR_TYP) ? ~(^P_DATA) : ^P_DATA;
endmodule