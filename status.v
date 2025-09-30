module status (
    input  clk,           
    input  Z_in,          
    input  N_in,          
    input  V_in,          
    input  C_in,          
    output reg Z,         
    output reg N,         
    output reg V,         
    output reg C          
);

    always @(posedge clk) begin 
        Z <= Z_in;   
        N <= N_in;   
        V <= V_in;   
        C <= C_in;   
    end
endmodule
