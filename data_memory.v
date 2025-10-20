
module data_memory (
    input  clk,
    input  W,               
    input  [7:0] address,   
    input  [7:0] data_in,  
    output [7:0] data_out   
);
    // Memoria reducida para FPGA pequeña: solo 64 posiciones en lugar de 256
    reg [7:0] mem [0:63];

    // Solo usar los 6 bits menos significativos de la dirección
    assign data_out = mem[address[5:0]];

    always @(posedge clk) begin
        if (W) begin 
            mem[address[5:0]] <= data_in; // Solo usar los 6 bits menos significativos
        end
    end

    initial begin
        $readmemb("mem.dat", mem);
    end

endmodule
