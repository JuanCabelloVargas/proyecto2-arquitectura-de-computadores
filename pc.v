
module pc (
    input clk,
    input LP,
    input [7:0] K,
    output reg [7:0] pc
);

  initial begin
    pc = 0;
  end

  always @(posedge clk) begin
    if (LP)
      pc <= K & 8'h3F; // Limitar PC a 6 bits (0-63) para memoria reducida
    else
      pc <= (pc + 1) & 8'h3F; // Limitar incremento también
  end
endmodule
