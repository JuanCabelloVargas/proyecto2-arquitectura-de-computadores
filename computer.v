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
  wire [6:0] opcode  = im_out_bus[15:9];      // 7-bit opcode
  wire [7:0] K       = im_out_bus[7:0];       // Literal / inmediato (renombrado de 'literal' a 'K')


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
      // MOV A, Lit (A = K)
      // A, Lit => A = Lit. Se implementa como A = 0 + 
      7'b0000010: begin
        LA     = 1'b1;
        selA   = 2'b10;    // 0
        selB   = 2'b10;    // K
        alu_op = 4'b0000;  // ADD => 0 + K
      end
      // MOV B, Lit (B = K)
      7'b0000011: begin
        LB     = 1'b1;
        selA   = 2'b10;    // 0
        selB   = 2'b10;    // K
        alu_op = 4'b0000;
      end
      // ADD A,B (A = A + B)
      7'b0000100: begin
        LA     = 1'b1;
        selA   = 2'b00;    // A
        selB   = 2'b00;    // Mux B selecciona RegB
        alu_op = 4'b0000;  // ALU hace ADD
      end
      // ADD A, Lit (A = A + K)
      7'b0000110: begin
        LA     = 1'b1;
        selA   = 2'b00;    // A
        selB   = 2'b10;    // K
        alu_op = 4'b0000;
      end
      // ADD B, Lit (B = B + K)
      7'b0000111: begin
        LB     = 1'b1;
        selA   = 2'b01;    // B (necesitamos B en 'a')
        selB   = 2'b10;    // K
        alu_op = 4'b0000;
      end
      // SHL A,A (A = A << 1)
      7'b0011100: begin
        LA     = 1'b1;
        selA   = 2'b00;    // Mux A selecciona RegA
        selB   = 2'b11;    // Mux B no importa para SHL
        alu_op = 4'b0111;  // ALU hace SHL
      end
      // Aquí se agregarían los demás opcodes de la sección 1.1...
      default: begin
        // NOP por defecto
      end
    endcase
  end

  // --- Lógica de Datapath ---
  // MUX A: Selecciona la primera entrada de la ALU
  wire [7:0] alu_in_a = (selA == 2'b00) ? regA_out_bus :
                        (selA == 2'b01) ? regB_out_bus :
                        (selA == 2'b10) ? 8'h00        : 8'h01;

  // MUX B: Selecciona la segunda entrada de la ALU
  wire [7:0] alu_in_b = (selB == 2'b00) ? regB_out_bus :
                        (selB == 2'b01) ? regA_out_bus :
                        (selB == 2'b10) ? K            : 8'h00; // 2'b11 (Corregido: usa K)


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
      .load(LA), // Controlado por la nueva lógica de control
      .out (regA_out_bus)
  );
  register regB (
      .clk (clk),
      .data(alu_out_bus),
      .load(LB), // Controlado por la nueva lógica de control
      .out (regB_out_bus)
  );
  // La instancia de mux2 se elimina porque su lógica ahora está arriba
  alu ALU (
      .a  (alu_in_a),   // Conectado a la salida de MUX A
      .b  (alu_in_b),   // Conectado a la salida de MUX B
      .s  (alu_op),     // Conectado a la señal de control de la ALU
      .out(alu_out_bus),
      .Z(alu_Z), .N(alu_N), .C(alu_C), .V(alu_V) // Flags conectados
  );
endmodule
