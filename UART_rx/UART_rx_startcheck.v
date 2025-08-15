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