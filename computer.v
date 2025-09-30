module computer (
    input clk,
    output [7:0] alu_out_bus
);
  // señales internas visibles
  wire [7:0]  pc_out_bus;
  wire [15:0] im_out_bus;
  wire [7:0]  regA_out_bus;
  wire [7:0]  regB_out_bus;

  // instrucción -> opcode (7 bits) + literal (8 bits)
  wire [6:0] opcode = im_out_bus[15:9];
  wire [7:0] K      = im_out_bus[7:0];

  // señales de control
  wire LA, LB;
  wire [1:0] selA, selB;
  wire [3:0] alu_op;

  // salidas de mux hacia ALU
  wire [7:0] alu_a_bus;
  wire [7:0] alu_b_bus;

  // ==== FETCH ====
  pc PC (
      .clk(clk),
      .pc(pc_out_bus)
  );

  instruction_memory IM (
      .address(pc_out_bus),
      .out(im_out_bus)
  );

  // ==== CONTROL ====
  control CU (
      .opcode(opcode),
      .LA(LA),
      .LB(LB),
      .selA(selA),
      .selB(selB),
      .alu_op(alu_op)
  );

  // ==== REGISTROS ====
  register regA (
      .clk (clk),
      .data(alu_out_bus),
      .load(LA),
      .out (regA_out_bus)
  );

  register regB (
      .clk (clk),
      .data(alu_out_bus),
      .load(LB),
      .out (regB_out_bus)
  );

  // ==== MUXES 4→1 de 8 bits ====
  mux2 muxA (
      .e0(regA_out_bus), // A
      .e1(regB_out_bus), // B
      .e2(K),            // literal
      .e3(8'h00),        // 0
      .sel(selA),
      .out(alu_a_bus)
  );

  mux2 muxB (
      .e0(regA_out_bus), // A
      .e1(regB_out_bus), // B
      .e2(K),
      .e3(8'h00),
      .sel(selB),
      .out(alu_b_bus)
  );

  // ==== ALU ====
  alu ALU (
      .a  (alu_a_bus),
      .b  (alu_b_bus),
      .s  (alu_op),
      .out(alu_out_bus),
      .Z(),
      .N(),
      .C(),
      .V()
  );

endmodule
