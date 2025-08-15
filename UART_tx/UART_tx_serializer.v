module serializer(
    input ser_en , clk , rst ,
    input [7:0] data ,
    output serialdata , 
    output ser_done 
);

reg [3:0] counter;


assign serialdata = data[counter];
assign ser_done = (counter == 6) ? 1 : 0;

always@(posedge clk) begin
if (rst) begin
    counter <= 0;
end else if (ser_en) begin
    if (counter == 7) begin
        counter <= 0;
    end else begin
        counter <= counter + 1;
    end
end else begin
    counter <= 0;
end
end
endmodule