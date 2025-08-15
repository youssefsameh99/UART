
module tx#(
    parameter IDLE = 0 ,
    parameter START_BIT = 1 ,
    parameter STOP_BIT = 2 ,
    parameter SER_DATA = 3 ,
    parameter PAR_BIT = 4 
    )(
    input clk , rst , PAR_TYP ,  PAR_EN , 
    input [7:0] P_DATA ,
    input DATA_VALID , 
    output TX_OUT ,
    output reg BUSY
);
reg [2:0] cs , ns;
wire ser_done;
reg ser_en;
wire serialdata;
reg [1:0] mux_sel;
wire paritybit;
reg [3:0] counter;

always@(posedge clk) begin
    if(rst) begin
    cs <= IDLE;
    end else cs <= ns;
end

always@(*) begin
    ns = cs;
    case(cs)
    IDLE : if(DATA_VALID) ns = START_BIT;
    START_BIT : ns = SER_DATA;
    SER_DATA : if(ser_done && PAR_EN) ns = PAR_BIT; else if(ser_done) ns = STOP_BIT;
    PAR_BIT : ns = STOP_BIT;
    STOP_BIT : ns = IDLE; 
    default : ns = IDLE;
    endcase
end


always @(posedge clk) begin
    if (rst) begin
        mux_sel <= 0;
        ser_en  <= 0;
        BUSY    <= 0;
    end else begin
        mux_sel <= 0;
        ser_en  <= 0;
        BUSY    <= 0;
        case(cs)
            START_BIT : begin mux_sel <= 0; BUSY <= 1; end
            STOP_BIT  : begin mux_sel <= 1; BUSY <= 1; end
            SER_DATA  : begin mux_sel <= 2; ser_en <= 1; BUSY <= 1; end
            PAR_BIT   : begin mux_sel <= 3; BUSY <= 1; end
        endcase
    end
end


mux mux1(mux_sel , serialdata , paritybit , TX_OUT);
serializer serializer1(ser_en , clk , rst , P_DATA , serialdata , ser_done);
paritycalc paritycalc1(PAR_TYP , P_DATA , paritybit);

endmodule


    








