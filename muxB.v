module muxB (
  input  [7:0] A, B,
  input  [7:0] K,            // literal
  input  [7:0] mem_data,     // datos de memoria
  input  [1:0] sel,
  output reg [7:0] out
);
  always @(*) begin
    case (sel)
      2'b00: out = B;        // B
      2'b01: out = A;        // A
      2'b10: out = K;        // K
      2'b11: out = mem_data; // Memoria
    endcase
  end
endmodule
