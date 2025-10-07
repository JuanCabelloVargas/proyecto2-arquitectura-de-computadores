module computer (
    input clk,
    output [7:0] alu_out_bus
);

  // --- Buses principales
  wire [7:0]  pc_out_bus;
  wire [14:0] im_out_bus;
  wire [7:0]  regA_out_bus;
  wire [7:0]  regB_out_bus;

  // Campos de instrucción
  wire [6:0] opcode = im_out_bus[14:8];
  wire [7:0] K      = im_out_bus[7:0];

  // Señales de control
  wire LA, LB, LP;          // cargas a A, B, PC
  wire mem_we;              // write enable de data memory
  wire wbSel;               // 0=ALU, 1=Mem
  wire [1:0] selA, selB;    // selects para muxA/muxB (entradas de la ALU)
  wire [1:0] selData;       // select para dirección de DataMemory
  wire [3:0] alu_op;

  // Flags de ALU (combinacionales)
  wire Z, N, C, V;

  // Bus de status REGISTRADO que ve la Control Unit (¡UN solo driver!)
  wire [3:0] status_bus;

  // Entradas a la ALU
  wire [7:0] alu_a_bus;
  wire [7:0] alu_b_bus;

  // --- PC e Instrucciones
  pc PC (
    .clk(clk),
    .pc(pc_out_bus)
  );

  instruction_memory IM (
    .address(pc_out_bus),
    .out(im_out_bus)
  );

  // --- Unidad de Control
  control CU (
    .opcode(opcode),
    .status(status_bus),  // << usa el bus del registro de status
    .LA(LA),
    .LB(LB),
    .LP(LP),
    .mem_we(mem_we),
    .wbSel(wbSel),
    .selA(selA),
    .selB(selB),
    .selData(selData),
    .alu_op(alu_op)
  );

  // --- Dirección y datos de Data Memory
  wire [7:0] dmem_addr;
  wire [7:0] dmem_out;

  // Selección de dirección para DataMemory: A/B/K/PC
  muxData MUXD (
    .A (regA_out_bus),
    .B (regB_out_bus),
    .K (K),
    .PC(pc_out_bus),
    .sel(selData),
    .out(dmem_addr)
  );

  // Nota: por ahora tus tests no escriben memoria con ALU,
  // así que data_in puede seguir en regB_out_bus.
  data_memory DM (
    .clk(clk),
    .address(dmem_addr),
    .data_in(regB_out_bus),
    .W(mem_we),
    .data_out(dmem_out)
  );

  // --- Write-back: ALU vs Memoria
  wire [7:0] wb_data;
  muxWB muxWB (
    .alu_out(alu_out_bus),
    .mem_out(dmem_out),
    .sel(wbSel),
    .out(wb_data)
  );

  // --- Registros A y B (ambos escriben desde wb_data)
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

  // --- MUX de entradas a la ALU
  // Mapeo selA/selB:
  //   2'b00 -> A
  //   2'b01 -> B
  //   2'b10 -> K (en muxA lo ignoramos -> 0)
  //   2'b11 -> Mem (dmem_out)
  muxA muxA (
    .A        (regA_out_bus),
    .B        (regB_out_bus),
    .K_unused (8'h00),       // no usamos K en 'a'
    .mem_data (dmem_out),
    .sel      (selA),
    .out      (alu_a_bus)
  );

  muxB muxB (
    .A        (regA_out_bus),
    .B        (regB_out_bus),
    .K        (K),
    .mem_data (dmem_out),
    .sel      (selB),
    .out      (alu_b_bus)
  );

  // --- ALU
  alu ALU (
    .a  (alu_a_bus),
    .b  (alu_b_bus),
    .s  (alu_op),
    .out(alu_out_bus),
    .Z(Z), .N(N), .C(C), .V(V)
  );

  // --- Registro de Flags (único driver del bus que ve control)
  status status_reg (
    .clk(clk),
    .Z_in(Z), .N_in(N), .C_in(C), .V_in(V),
    .status_out(status_bus)
  );

  // --- Debug opcional
  // `define DEBUG
`ifdef DEBUG
  always @(posedge clk) begin
    $display("t=%0t PC=%0d op=%b | A=%0d B=%0d | LA=%b LB=%b wbSel=%b selA=%b selB=%b alu_op=%b | a=%0d b=%0d out=%0d | status=%b",
      $time, pc_out_bus, opcode, regA_out_bus, regB_out_bus,
      LA, LB, wbSel, selA, selB, alu_op, alu_a_bus, alu_b_bus, alu_out_bus, status_bus);
  end
`endif

endmodule

