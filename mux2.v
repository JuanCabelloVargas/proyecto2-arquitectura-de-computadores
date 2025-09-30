module mux2 (
  input  [7:0] e0, e1, e2, e3,
  input  [1:0] sel,
  output reg [7:0] out
);
  always @(*) begin
    case (sel)
      2'b00: out = e0;
      2'b01: out = e1;
      2'b10: out = e2;
      2'b11: out = e3;
    endcase
  end
endmodule
