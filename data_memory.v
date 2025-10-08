module DM (
    input  clk,
    input  W,               
    input  [7:0] address,   
    input  [7:0] data_in,  
    output [7:0] data_out   
);
    reg [7:0] mem [0:255];

    assign data_out = mem[address];

    always @(posedge clk) begin
        if (W) begin 
            mem[address] <= data_in; // Escribe data_in en la dirección address
        end
    end

    initial begin
        $readmemb("mem.dat", mem);
    end

endmodule
