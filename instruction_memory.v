module instruction_memory (
  input  [7:0]  address,
  output [14:0] out
);
  // Memoria reducida para FPGA pequeña: solo 64 posiciones en lugar de 256
  reg [14:0] mem [0:63];

  initial begin
    $readmemb("im.dat", mem); // Usar im.dat con programa simple
  end

  integer i;
  initial begin
    #0.1;
    for (i = 0; i < 64; i = i + 1) begin
      if (^mem[i] === 1'bx) mem[i] = 15'h0000;
    end
  end

  // Solo usar los 6 bits menos significativos de la dirección
  assign out = mem[address[5:0]];
endmodule
