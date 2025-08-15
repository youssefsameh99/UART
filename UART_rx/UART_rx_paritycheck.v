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