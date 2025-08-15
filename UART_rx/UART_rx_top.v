module rx #(
    parameter IDLE       = 0,
    parameter START_BIT  = 1,
    parameter DATA       = 2,
    parameter PAR_BIT    = 3,
    parameter STOP_BIT   = 4,
    parameter CHK_ERRORS = 5
)(
    input        clk, rst,
    input        PAR_TYP, PAR_EN, RX_IN,
    input  [5:0] prescale,
    output [7:0] P_DATA,
    output reg       data_valid,
    output reg       parity_error,
    output reg       stop_error
);

reg [2:0] cs, ns;
reg sampler_enable , edge_bit_counter_enable;
wire sampled_bit;
wire [5:0] edge_cnt;
wire [3:0] bit_cnt;
wire start_glitch;
reg strt_chk_en;
wire stp_err , par_err;
reg stp_chk_en, par_chk_en, deser_en;
    always @(posedge clk or posedge rst) begin
        if (rst)
            cs <= IDLE;
        else
            cs <= ns;
    end
    always @(*) begin
        ns = cs;
        case (cs)
            IDLE: begin
                if (~RX_IN)
                    ns = START_BIT;
            end
            START_BIT: begin
                if((bit_cnt == 0) && (edge_cnt == prescale - 1)) begin
                    if(!start_glitch)
                    ns = DATA;
                    else ns = IDLE;
                end
            end

            DATA: begin
                if((bit_cnt == 8) &&(edge_cnt == prescale - 1)) begin 
                    ns = (PAR_EN) ? PAR_BIT : STOP_BIT;
            end
            end
            PAR_BIT: begin
                if((bit_cnt == 9) && (edge_cnt == prescale - 1))
                ns = STOP_BIT;
            end
            STOP_BIT: begin
                if((PAR_EN)) begin
                    if((bit_cnt == 10) && (edge_cnt == prescale - 2))
                    ns = CHK_ERRORS;
            end
                else if(!PAR_EN) begin
                    if((bit_cnt == 9) &&(edge_cnt == prescale - 2))
                    ns = CHK_ERRORS;
                end
            end

            CHK_ERRORS: begin
                ns = IDLE;
            end
            default : begin
                ns = IDLE;
            end
        endcase
    end
    always@(posedge clk) begin
        if(rst) begin
            sampler_enable <= 0;
            edge_bit_counter_enable <= 0;
            strt_chk_en <= 0;
            stp_chk_en <= 0;
            par_chk_en <= 0;
            deser_en <= 0;
            data_valid <= 0;
            parity_error <= 0;
            stop_error <= 0;
            
        end else begin
            sampler_enable <= 0;
            edge_bit_counter_enable <= 0;
            strt_chk_en <= 0;
            stp_chk_en <= 0;
            par_chk_en <= 0;
            deser_en <= 0;
            data_valid <= 0;
            stop_error <= 0;
            parity_error <= 0;
            case(cs)
            START_BIT : begin
                sampler_enable <= 1;
                edge_bit_counter_enable <= 1;
                strt_chk_en <= 1;
            end
            DATA : begin
                sampler_enable <= 1;
                edge_bit_counter_enable <= 1;
                deser_en <= 1;
            end
            PAR_BIT : begin
                sampler_enable <= 1;
                edge_bit_counter_enable <= 1;
                par_chk_en <= 1;
            end
            STOP_BIT : begin
                sampler_enable <= 1;
                edge_bit_counter_enable <= 1;
                stp_chk_en <= 1;
            end
            CHK_ERRORS : begin
                sampler_enable <= 0;
                edge_bit_counter_enable <= 0;
                parity_error <= par_err;
                stop_error <= stp_err;
                if(stp_err || par_err)
                data_valid <= 0;
                else data_valid <= 1;
            end
            default: begin
            sampler_enable <= 0;
            edge_bit_counter_enable <= 0;
            strt_chk_en <= 0;
            stp_chk_en <= 0;
            par_chk_en <= 0;
            deser_en <= 0;
            data_valid <= 0;
            stop_error <= 0;
            parity_error <= 0;
            end
            endcase
        end
    end


strt_check startcheck(sampled_bit , strt_chk_en , prescale , edge_cnt , start_glitch);
edge_bit_counter edgebitcounter1(clk , rst , edge_bit_counter_enable , prescale , bit_cnt , edge_cnt);
sampler sampler1(clk , rst , RX_IN , sampler_enable , edge_cnt , prescale , sampled_bit);
parity_check par_check1(PAR_TYP , par_chk_en , P_DATA , sampled_bit , par_err);
stop_check stp_check1(sampled_bit , stp_chk_en , prescale , edge_cnt , stp_err);
deserializer deserialiizer1(clk , rst , sampled_bit , deser_en , prescale , edge_cnt , P_DATA);


endmodule






     

















