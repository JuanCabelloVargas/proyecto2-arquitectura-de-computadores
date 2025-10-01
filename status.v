module status (
    input  clk,           
    input  Z_in,          
    input  N_in,          
    input  V_in,          
    input  C_in,          
    output [3:0] status_out          
);

    reg Z, N, V, C;
    
    assign status_out = {Z, N, C, V};

    always @(posedge clk) begin 
        Z <= Z_in;   
        N <= N_in;   
        V <= V_in;   
        C <= C_in;   
    end
endmodule
