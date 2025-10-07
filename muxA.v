module muxA (
  input  [7:0] A, B,
  input  [7:0] K_unused,   // no usamos K en 'a'
  input  [7:0] mem_data,
  input  [1:0] sel,        // 00->A, 01->B, 10->0, 11->Mem
  output reg [7:0] out
);
  always @(*) begin
    out = 8'h00;                 // default para evitar X/latches
    case (sel)
      2'b00: out = A;
      2'b01: out = B;
      2'b10: out = 8'h00;        // ignoramos K en 'a'
      2'b11: out = mem_data;
      default: out = 8'h00;
    endcase
  end
endmodule

