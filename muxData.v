module muxData (
    input  [7:0] A,         // No se usa, solo para consistencia
    input  [7:0] B,         // Registro B
    input  [7:0] K,         // Literal de la instruccion
    input  [1:0] sel,       // Selector S de Control Unit **Revisarlo, porque estoy confundido con si es 1 o 2 bits**
    output reg [7:0] out    // Salida Address hacia Data Memory
);

  always @(*) begin
    case (sel)
      2'b00: out = B;        // B
      2'b01: out = A;        // A
      2'b10: out = K;        // K
      2'b11: out = 8'h00;    // 0
    endcase
  end
endmodule
