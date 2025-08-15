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
