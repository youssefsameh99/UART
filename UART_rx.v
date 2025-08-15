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


module sampler (
    input        clk, rst,
    input        data,
    input        enable,  
    input  [5:0] edge_cnt,       
    input  [5:0] prescale,       
    output reg   sampled_bit
);

reg sample1, sample2, sample3;
reg [5:0] mid_point;

always @(*) begin
    mid_point = prescale >> 1; 
end

always @(posedge clk) begin
    if (rst) begin
        sample1 <= 1'b1; 
        sample2 <= 1'b1;
        sample3 <= 1'b1;
        sampled_bit <= 1'b1;
    end else if (enable) begin
          if (edge_cnt == mid_point - 1)
            sample1 <= data;
        else if (edge_cnt == mid_point)
            sample2 <= data;
        else if (edge_cnt == mid_point + 1)
            sample3 <= data;
        if (edge_cnt == mid_point + 1) begin
            sampled_bit <= (sample1 & sample2) |
                           (sample1 & sample3) |
                           (sample2 & sample3);
        end
    end
end
endmodule



     
module strt_check(
    input data, strt_chk_en, 
    input [5:0] prescale ,
    input [5:0] edge_cnt,
    output reg strt_glitch
);
always@(*) begin
    if((strt_chk_en) &&(edge_cnt==(prescale-1))) begin
        if(~data) strt_glitch = 0;
        else strt_glitch = 1;
    end
end
endmodule


module stop_check(
    input data, stp_chk_en,
    input [5:0] prescale ,
    input [5:0] edge_cnt,
    output reg stp_err
);
always@(*) begin
    if((stp_chk_en) &&(edge_cnt==(prescale-1))) begin
        if(data) stp_err = 0;
        else stp_err = 1;
    end
end
endmodule


module parity_check (
    input        PAR_TYP, 
    input        par_chk_en, 
    input  [7:0] data_bits,    
    input        par_bit,      
    output   reg    par_err       
);

wire expected_par;
assign expected_par = (PAR_TYP == 1'b0) ? 
                      (^data_bits)       :
                      (~(^data_bits));     
always@(*) begin
    if(par_chk_en) begin
        if(expected_par != par_bit)
        par_err = 1;
    end
end


endmodule

module edge_bit_counter (
    input        clk,
    input        rst,
    input        enable,
    input  [5:0] prescale,
    output reg [3:0] bit_cnt,
    output reg [5:0] edge_cnt
);

always @(posedge clk) begin
    if (rst) begin
        bit_cnt  <= 0;
        edge_cnt <= 0;
    end
    else if (!enable) begin
        bit_cnt  <= 0;
        edge_cnt <= 0;
    end
    else begin
        if (edge_cnt == prescale - 1) begin
            edge_cnt <= 0;
            bit_cnt  <= bit_cnt + 1;
        end
        else begin
            edge_cnt <= edge_cnt + 1;
        end
    end
end

endmodule


module deserializer #(
    parameter WIDTH = 8
)(
    input        clk,
    input        rst,
    input        sampled_bit,
    input        deser_en,
    input  [5:0] prescale,
    input  [5:0] edge_cnt,
    output reg [WIDTH-1:0] p_data
);

always @(posedge clk) begin
    if (rst) begin
        p_data <= 0;
    end
    else if (deser_en && (edge_cnt == (prescale - 1))) begin
        p_data <= {p_data[WIDTH-2:0], sampled_bit};
    end
end

endmodule







