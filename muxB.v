module muxB (
  input  [7:0] A, B,
  input  [7:0] K,
  input  [7:0] mem_data,
  input  [1:0] sel,        // 00->B, 01->A, 10->K, 11->Mem
  output reg [7:0] out
);
  always @(*) begin
    out = 8'h00;                 // default para evitar X/latches
    case (sel)
      2'b00: out = B;
      2'b01: out = A;
      2'b10: out = K;
      2'b11: out = mem_data;
      default: out = 8'h00;
    endcase
  end
endmodule

