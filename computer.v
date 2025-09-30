module computer (
    input  clk,
    output [7:0] alu_out_bus
);
  // Buses visibles para wave
  wire [7:0]  pc_out_bus;
  wire [15:0] im_out_bus;
  wire [7:0]  regA_out_bus;
  wire [7:0]  regB_out_bus;

  // decodificar instruccion
  wire [6:0] opcode = im_out_bus[15:9];
  wire [7:0] K      = im_out_bus[7:0];

  // señal para la Cu
  wire       LA, LB;
  wire [1:0] selA, selB;
  wire [3:0] alu_op;

  // conexion de mux hacia alu
  wire [7:0] alu_a_bus;
  wire [7:0] alu_b_bus;

// flags
  wire Z, N, C, V;

  
  pc PC (
      .clk(clk),
      .pc (pc_out_bus)
  );

  instruction_memory IM (
      .address(pc_out_bus),
      .out(im_out_bus)
  );

 
  control CU (
      .opcode(opcode),
      .LA(LA),
      .LB(LB),
      .selA(selA),   
      .selB(selB),
      .alu_op(alu_op)
  );


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

  mux2 muxA (
      .e0(regA_out_bus), // A
      .e1(regB_out_bus), // B
      .e2(K),            // K (literal)
      .e3(8'h00),        // 0
      .sel(selA),
      .out(alu_a_bus)
  );

  mux2 muxB (
      .e0(regA_out_bus), // A 
      .e1(regB_out_bus), // B
      .e2(K),            // K
      .e3(8'h00),        // 0
      .sel(selB),
      .out(alu_b_bus)
  );


  alu ALU (
      .a  (alu_a_bus),
      .b  (alu_b_bus),
      .s  (alu_op),
      .out(alu_out_bus),
      .Z  (Z),
      .N  (N),
      .C  (C),
      .V  (V)
  );

endmodule
