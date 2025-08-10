module tb_tx;

    reg clk;
    reg rst;
    reg PAR_TYP; 
    reg PAR_EN;        
    reg [7:0] P_DATA;
    reg DATA_VALID;
    wire TX_OUT;
    wire BUSY;

    tx uut (
        .clk(clk),
        .rst(rst),
        .PAR_TYP(PAR_TYP),
        .PAR_EN(PAR_EN),
        .P_DATA(P_DATA),
        .DATA_VALID(DATA_VALID),
        .TX_OUT(TX_OUT),
        .BUSY(BUSY)
    );


    initial clk = 0;
    always #1 clk = ~clk;

    initial begin
        rst = 1;
        PAR_TYP = 0;
        PAR_EN = 1;
        P_DATA = 8'b10101010;
        DATA_VALID = 0;
        @(negedge clk);
        rst = 0;
        DATA_VALID = 1;
        @(negedge clk);
        DATA_VALID = 0;
        repeat(20) @(negedge clk);
        $stop;
    end
endmodule

