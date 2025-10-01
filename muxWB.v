module muxWB (
    input  [7:0] alu_out,  // Salida ALU
    input  [7:0] mem_out,  // Salida Data Memory
    input        sel,      // 0: ALU, 1: Memoria
    output [7:0] out
);
  assign out = sel ? mem_out : alu_out;
endmodule
