module instruction_memory (
  input  [7:0]  address,
  output [14:0] out
);
  reg [14:0] mem [0:255];

  // Carga normal (si ya tienes otro $readmemb aquí, déjalo)
  initial begin
    // Si ya tenías este, mantenlo; si no, puedes dejarlo o depender del testbench.
    $readmemb("im.dat", mem);
  end

  // Saneador: cualquier palabra con X -> 0 (NOP)
  integer i;
  initial begin
    // Asegura que esto corra DESPUÉS de los $readmemb de todos lados
    #0.1;
    for (i = 0; i < 256; i = i + 1) begin
      // Si alguna X quedó en la palabra, ponla en 0
      if (^mem[i] === 1'bx) mem[i] = 16'h0000;
    end
  end

  assign out = mem[address];
endmodule
