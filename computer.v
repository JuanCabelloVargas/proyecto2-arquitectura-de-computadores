module computer (
    input clk,
    output [7:0] alu_out_bus
);
  // señales internas visibles
  wire [7:0]  pc_out_bus;
  wire [14:0] im_out_bus;
  wire [7:0]  regA_out_bus;
  wire [7:0]  regB_out_bus;

  // instrucción -> opcode (7 bits) + literal (8 bits)
  wire [6:0] opcode = im_out_bus[14:8];
  wire [7:0] K      = im_out_bus[7:0];

  // señales de control  
  wire LA, LB, LP, W, mem_we;
  wire [1:0] selA, selB, selData;  // selData ahora es 2 bits para muxData
  wire       wbSel;                // nuevo: 1 bit para muxWB
  wire [3:0] alu_op;
  
  // señales de status (flags)
  wire Z, N, C, V;
  wire [3:0] status_out = {Z, N, C, V};

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
    .status(status_out),
    .LA(LA),
    .LB(LB),
    .LP(LP),
    .mem_we(mem_we),   // <-- nuevo
    .wbSel(wbSel),     // <-- nuevo
    .selA(selA),
    .selB(selB),
    .selData(selData), // <-- ahora es [1:0]
    .alu_op(alu_op)
);

  // ==== DATA MEMORY ====
  wire [7:0] dmem_addr;
  wire [7:0] dmem_out;

  muxData MUXD (
    .A(regA_out_bus),
    .B(regB_out_bus),
    .K(K),
    .PC(pc_out_bus),   // <-- ahora sí matchea
    .sel(selData),
    .out(dmem_addr)
);


  data_memory DM (
    .clk(clk),
    .address(dmem_addr),
    .data_in(regB_out_bus),  // típico: stores escriben B -> MEM[addr]
    .W(mem_we),
    .data_out(dmem_out)
);

  // ==== WRITE-BACK ====
  wire [7:0] wb_data;
  muxWB muxWB (
      .alu_out(alu_out_bus),
      .mem_out(dmem_out),
      .sel(wbSel),
      .out(wb_data)
  );

  // ==== REGISTROS ====
  register regA (
      .clk (clk),
      .data(wb_data),
      .load(LA),
      .out (regA_out_bus)
  );

  register regB (
      .clk (clk),
      .data(wb_data),
      .load(LB),
      .out (regB_out_bus)
  );

  // ==== MUX A y B ====
  muxA muxA (
      .A  (regA_out_bus),
      .B  (regB_out_bus),
      .K_unused(8'h00),
      .sel(selA),
      .out(alu_a_bus)
  );

  muxB muxB (
      .A  (regA_out_bus),
      .B  (regB_out_bus),
      .K  (K),
      .sel(selB),
      .out(alu_b_bus)
  );

  // ==== ALU ====
  alu ALU (
      .a  (alu_a_bus),
      .b  (alu_b_bus),
      .s  (alu_op),
      .out(alu_out_bus),
      .Z(Z),
      .N(N),
      .C(C),
      .V(V)
  );

  // ==== REGISTRO DE ESTADO ====
  status status_reg (
      .clk(clk),
      .Z_in(Z),
      .N_in(N),
      .C_in(C),
      .V_in(V),
      .status_out(status_out)
  );

endmodule
