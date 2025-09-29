module alu (
    a,
    b,
    s,
    out,
    Z,
    N,
    C,
    V
);
  input [7:0] a, b;
  input [2:0] s;
  output [7:0] out;
  output Z, N, C, V;  //flags para usar despues

  reg [7:0] out_r;
  reg C_r, V_r;

  wire [8:0] sum = {1'b0, a} + {1'b0, b};
  wire [8:0] diff = {1'b0, a} + {1'b0, ~b} + 9'd1;

  always @(*) begin
    C_r = 1'b0;
    V_r = 1'b0;
    case (s)
      3'b000: begin  // Suma
        out_r = sum[7:0];
        C_r   = sum[8];
        V_r   = (a[7] == b[7]) && (out_r[7] != a[7]);
      end
      3'b001: begin  // resta
        out_r = diff[7:0];
        C_r   = ~diff[8];
        V_r   = (a[7] != b[7]) && (out_r[7] != a[7]);
      end
      3'b010: out_r = a & b;  // AND
      3'b011: out_r = a | b;  // OR
      3'b100: out_r = a ^ b;  // XOR
      3'b101: out_r = ~a;  // NOT (sobre a solamente, faltan los otros casos)
      3'b110: begin  // SHL
        out_r = {a[6:0], 1'b0};
        C_r   = a[7];
      end
      3'b111: begin  // SHR 
        out_r = {1'b0, a[7:1]};
        C_r   = a[0];
      end
    endcase
  end

  assign out = out_r;
  assign Z   = (out_r == 8'h00);
  assign N   = out_r[7];
  assign C   = C_r;
  assign V   = V_r;
endmodule













