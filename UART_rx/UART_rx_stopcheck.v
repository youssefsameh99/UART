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