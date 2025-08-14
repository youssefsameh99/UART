module rx#(
    parameter IDLE = 0;
    parameter START_BIT = 1;
    parameter DATA = 2;
    parameter PAR_BIT = 3;
    parameter STOP_BIT = 4;
    parameter CHK_ERRORS = 5;
)(
    input clk , rst , PAR_TYP , PAR_EN , RX_IN ,
    input [5:0] prescale ,
    output [7:0] P_DATA ,
    output data_valid , parity_error , stop_error
);


reg [2:0] cs , ns;
reg strt_chk_en;
reg par_chk_en;
reg stp_chk_en;
reg enable;


always@(posedge clk) begin
    if(rst) begin
    cs <= IDLE;
    end else cs <= ns;
end


always@(*) begin


end

endmodule





     
module strt_check(
    input data, strt_chk_en,
    output strt_glitch
);
always@(*) begin
    if(strt_chk_en) begin
        if(~data) strt_glitch = 0;
        else strt_glitch = 1;
    end
end
endmodule


module stop_check(
    input data, stp_chk_en,
    output stp_err
);
always@(*) begin
    if(strt_chk_en) begin
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
    output       par_err       
);

wire expected_par;
assign expected_par = (PAR_TYP == 1'b0) ? 
                      (^data_bits)       :
                      (~(^data_bits));     
assign par_err = (par_chk_en) ? (par_bit != expected_par) : 1'b0;
endmodule

module edge_bit_counter (
    input        clk, rst,
    input        enable,     
    input  [5:0] prescale,      
    output reg [3:0] bit_cnt,  
    output reg [5:0] edge_cnt   
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        bit_cnt  <= 0;
        edge_cnt <= 0;
    end else if (enable) begin
        if (edge_cnt == prescale - 1) begin
            edge_cnt <= 0;
            bit_cnt  <= bit_cnt + 1;
        end else begin
            edge_cnt <= edge_cnt + 1;
        end
    end
end

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

always @(posedge clk or posedge rst) begin
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

module deserializer(
    input deser_en , sampled_bit , clk , rst ,
    output [10:0] parallel_data
);







