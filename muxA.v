module muxA (
  input  [7:0] A, B,
  input  [7:0] K_unused,      // no se usa en este mux, solo para firma homogénea
  input  [7:0] mem_data,      // datos de memoria
  input  [1:0] sel,
  output reg [7:0] out
);
  always @(*) begin
    case (sel)
      2'b00: out = A;        // A
      2'b01: out = B;        // B
      2'b10: out = 8'h00;    // 0
      2'b11: out = mem_data; // Memoria
    endcase
  end
endmodule
