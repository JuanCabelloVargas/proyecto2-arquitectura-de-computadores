module data_memory (
    input  clk,
    input  W,               // Write desde Control Unit
    input  [7:0] address,   // Dirección desde Mux Data
    input  [7:0] data_in,   // Datos a escribir desde ALU
    output [7:0] data_out   // Datos leídos hacia Mux A y Mux B
);
    // Memoria de 256 bytes
    reg [7:0] mem [0:255];

    // data_out es el contenido en la dirección address
    assign data_out = mem[address];

    // Solo cuando W está activo
    always @(posedge clk) begin
        if (W) begin 
            mem[address] <= data_in; // Escribe data_in en la dirección address
        end
    end

    // Carga inicial desde mem.dat
    initial begin
        $readmemb("mem.dat", mem);
    end

endmodule