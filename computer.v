module computer (
    clk,
    alu_out_bus
);
  input clk;
  output [7:0] alu_out_bus;
  // Recominedo pasar todas estas señales para afuera para poder ser vistas en el waveform
  wire [ 7:0] pc_out_bus;
  wire [15:0] im_out_bus;
  wire [ 7:0] regA_out_bus;
  wire [ 7:0] regB_out_bus;
  wire [ 7:0] muxB_out_bus;
  
  // Flags de la ALU
  wire alu_Z, alu_N, alu_C, alu_V;

  // Decodificación básica
  wire [6:0] opcode  = im_out_bus[15:9]; // OpCode a 7 bits
  wire [7:0] K       = im_out_bus[7:0];


  reg LA; // Load Register A
  reg LB; // Load Register B
  reg [1:0]  selA; // Selector de MuxA
  reg [1:0]  selB; // Selector de MuxB
  reg [3:0]  alu_op; // Operacion de la ALU

  always @(*) begin

    LA      = 1'b0;
    LB      = 1'b0;
    selA    = 2'b00;
    selB    = 2'b00;
    alu_op  = 4'b1001;

    case (opcode)

      // A,B => A=B. Se implementa como A = 0 + B
      7'b0000000: begin
        LA     = 1'b1;
        selA   = 2'b10; // Selecciona '0'
        selB   = 2'b00; // Selecciona RegB
        alu_op = 4'b0000; // ALU hace ADD
      end

      // B,A => B=A. Se implementa como B = 0 + A
      7'b0000001: begin
        LB     = 1'b1;
        selA   = 2'b10; // Selecciona '0'
        selB   = 2'b01; // Selecciona RegA
        alu_op = 4'b0000; // ALU hace ADD
      end

      // A, Lit => A = Lit. Se implementa como A = 0 + K
      7'b0000010: begin
        LA     = 1'b1;
        selA   = 2'b10; // Selecciona '0'
        selB   = 2'b10; // Selecciona K
        alu_op = 4'b0000; // ALU hace ADD
      end

      // B, Lit => B = Lit. Se implementa como B = 0 + K
      7'b0000011: begin
        LB     = 1'b1;
        selA   = 2'b10; // Selecciona '0'
        selB   = 2'b10; // Selecciona K
        alu_op = 4'b0000; // ALU hace ADD
      end

      // A,B => A = A + B
      7'b0000100: begin
        LA     = 1'b1;
        selA   = 2'b00; // A
        selB   = 2'b00; // Selecciona B
        alu_op = 4'b0000; // ALU hace ADD
      end

      // A, Lit => A = A + K
      7'b0000110: begin
        LA     = 1'b1;
        selA   = 2'b00; // A
        selB   = 2'b10; // K
        alu_op = 4'b0000; // ALU hace ADD
      end

      // B, Lit => B = B + K
      7'b0000111: begin
        LB     = 1'b1;
        selA   = 2'b01; // B
        selB   = 2'b10; // K
        alu_op = 4'b0000; // ALU hace ADD
      end
      default: begin

      end
    endcase
  end

  // Selecciona la primera entrada de la ALU
  wire [7:0] alu_in_a = (selA == 2'b00) ? regA_out_bus : // Si selA es 00, selecciona regA
                        (selA == 2'b01) ? regB_out_bus : // Si selA es 01, selecciona regB
                        (selA == 2'b10) ? 8'h00 : 8'h01; // Si selA es 10, selecciona '0', si es 11, selecciona '1'

  // Selecciona la segunda entrada de la ALU
  wire [7:0] alu_in_b = (selB == 2'b00) ? regB_out_bus : // Si selB es 00, selecciona regB
                        (selB == 2'b01) ? regA_out_bus : // Si selB es 01, selecciona regA
                        (selB == 2'b10) ? K : 8'h00; // Si selB es 10, selecciona K, si es 11, selecciona '0'

  pc PC (
      .clk(clk),
      .pc (pc_out_bus)
  );
  instruction_memory IM (
      .address(pc_out_bus),
      .out(im_out_bus)
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
  mux2 muxB (
      .e0 (regB_out_bus),
      .e1 (im_out_bus[3:0]),
      .c  (im_out_bus[8]),
      .out(muxB_out_bus)
  );
  alu ALU (
      .a  (regA_out_bus),
      .b  (muxB_out_bus),
      .s  (im_out_bus[5:4]),
      .out(alu_out_bus)
  );
endmodule
