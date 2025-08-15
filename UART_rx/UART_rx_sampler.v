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