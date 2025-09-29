module alu (
    a,
    b,
    s,
    out
);
  input [7:0] a, b;
  input [1:0] s;
  output [7:0] out;

  wire [7:0] a, b;
  wire [1:0] s;
  reg  [7:0] out;

  always @(a, b, s) begin
    case (s)
      2'b00: out = a + b;
      2'b01: out = a - b;
      2'b10: out = a & b;
      2'b11: out = a | b;
    endcase
  end
endmodule
