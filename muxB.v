module muxB (
  input  [7:0] A, B,
  input  [7:0] K,
  input  [7:0] mem_data,
  input  [1:0] sel,        
  output reg [7:0] out
);
  always @(*) begin
    out = 8'h00;                 
    case (sel)
      2'b00: out = B;         // B
      2'b01: out = A;         // A
      2'b10: out = K;         // K
      2'b11: out = mem_data;  // Mem
      default: out = 8'h00;
    endcase
  end
endmodule

