module muxA (
  input  [7:0] A, B,
  input  [7:0] K_unused,   // no usamos K en 'a'
  input  [7:0] mem_data,
  input  [1:0] sel,        
  output reg [7:0] out
);
  always @(*) begin
    out = 8'h00;                 
    case (sel)
      2'b00: out = A;         // A
      2'b01: out = B;         // B
      2'b10: out = 8'h00;     // 0
      2'b11: out = mem_data;  // Mem
      default: out = 8'h00;
    endcase
  end
endmodule

