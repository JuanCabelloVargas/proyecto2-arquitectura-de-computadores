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

  // Señales de control
  reg LA;  // Load A
  reg LB;  // Load B
  reg [1:0] selA; // Mux A: 00=A, 01=B, 10=0, 11=1
  reg [1:0] selB; // Mux B: 00=B, 01=A, 10=K, 11=0
  reg [3:0] alu_op; // Operación de la ALU

  always @(*) begin
    // Valores por defecto (NOP)
    LA     = 1'b0;
    LB     = 1'b0;
    selA   = 2'b10; // 0
    selB   = 2'b00; // B (irrelevante en NOP)
    alu_op = 4'b0000; // ADD (sin cargas no altera estado)

    case (opcode)
      // MOV A,B => A = B (A = 0 + B)
      7'b0000000: begin
        LA=1; selA=2'b10; selB=2'b00; alu_op=4'b0000; // 0 + B
      end
      // MOV B,A => B = A (B = 0 + A)
      7'b0000001: begin
        LB=1; selA=2'b10; selB=2'b01; alu_op=4'b0000; // 0 + A
      end
      // MOV A,K => A = K (A = 0 + K)
      7'b0000010: begin
        LA=1; selA=2'b10; selB=2'b10; alu_op=4'b0000; // 0 + K
      end
      // MOV B,K => B = K (B = 0 + K)
      7'b0000011: begin
        LB=1; selA=2'b10; selB=2'b10; alu_op=4'b0000; // 0 + K
      end
      // ADD A,B => A = A + B
      7'b0000100: begin
        LA=1; selA=2'b00; selB=2'b00; alu_op=4'b0000;
      end
      // ADD B,A => B = B + A
      7'b0000101: begin
        LB=1; selA=2'b01; selB=2'b01; alu_op=4'b0000;
      end
      // ADD A,K => A = A + K
      7'b0000110: begin
        LA=1; selA=2'b00; selB=2'b10; alu_op=4'b0000;
      end
      // ADD B,K => B = B + K
      7'b0000111: begin
        LB=1; selA=2'b01; selB=2'b10; alu_op=4'b0000;
      end
      // SUB A,B => A = A - B
      7'b0001000: begin
        LA=1; selA=2'b00; selB=2'b00; alu_op=4'b0001;
      end
      // SUB B,A => B = B - A
      7'b0001001: begin
        LB=1; selA=2'b01; selB=2'b01; alu_op=4'b0001;
      end
      // SUB A,K => A = A - K
      7'b0001010: begin
        LA=1; selA=2'b00; selB=2'b10; alu_op=4'b0001;
      end
      // SUB B,K => B = B - K
      7'b0001011: begin
        LB=1; selA=2'b01; selB=2'b10; alu_op=4'b0001;
      end
      // AND A,B => A = A & B
      7'b0001100: begin
        LA=1; selA=2'b00; selB=2'b00; alu_op=4'b0010;
      end
      // AND B,A => B = B & A
      7'b0001101: begin
        LB=1; selA=2'b01; selB=2'b01; alu_op=4'b0010;
      end
      // AND A,K => A = A & K
      7'b0001110: begin
        LA=1; selA=2'b00; selB=2'b10; alu_op=4'b0010;
      end
      // AND B,K => B = B & K
      7'b0001111: begin
        LB=1; selA=2'b01; selB=2'b10; alu_op=4'b0010;
      end
      // OR A,B => A = A | B
      7'b0010000: begin
        LA=1; selA=2'b00; selB=2'b00; alu_op=4'b0011;
      end
      // OR B,A => B = B | A
      7'b0010001: begin
        LB=1; selA=2'b01; selB=2'b01; alu_op=4'b0011;
      end
      // OR A,K => A = A | K
      7'b0010010: begin
        LA=1; selA=2'b00; selB=2'b10; alu_op=4'b0011;
      end
      // OR B,K => B = B | K
      7'b0010011: begin
        LB=1; selA=2'b01; selB=2'b10; alu_op=4'b0011;
      end
      // NOT A,A => A = ~A (usa entrada a)
      7'b0010100: begin
        LA=1; selA=2'b00; alu_op=4'b0101; // selB irrelevante
      end
      // NOT A,B => A = ~B (mapeando B a 'a')
      7'b0010101: begin
        LA=1; selA=2'b01; alu_op=4'b0101; // NOT sobre entrada 'a' (que ahora es B)
      end
      // NOT B,A => B = ~A (usa variante NOT sobre b)
      7'b0010110: begin
        LB=1; selA=2'b00; selB=2'b01; alu_op=4'b0110; // selB=01 => alu_in_b = A, ALU hace ~b = ~A
      end
      // NOT B,B => B = ~B (usa variante NOT sobre b)
      7'b0010111: begin
        LB=1; selA=2'b01; alu_op=4'b0110;
      end
      // XOR A,B => A = A ^ B
      7'b0011000: begin
        LA=1; selA=2'b00; selB=2'b00; alu_op=4'b0100;
      end
      // XOR B,A => B = B ^ A
      7'b0011001: begin
        LB=1; selA=2'b01; selB=2'b01; alu_op=4'b0100;
      end
      // XOR A,K => A = A ^ K
      7'b0011010: begin
        LA=1; selA=2'b00; selB=2'b10; alu_op=4'b0100;
      end
      // XOR B,K => B = B ^ K
      7'b0011011: begin
        LB=1; selA=2'b01; selB=2'b10; alu_op=4'b0100;
      end
      // SHL A,A => A = A << 1
      7'b0011100: begin
        LA=1; selA=2'b00; alu_op=4'b0111;
      end
      // SHL A,B => A = B << 1
      7'b0011101: begin
        LA=1; selA=2'b01; alu_op=4'b0111;
      end
      // SHL B,A => B = A << 1
      7'b0011110: begin
        LB=1; selA=2'b00; alu_op=4'b0111;
      end
      // SHL B,B => B = B << 1
      7'b0011111: begin
        LB=1; selA=2'b01; alu_op=4'b0111;
      end
      // SHR A,A => A = A >> 1
      7'b0100000: begin
        LA=1; selA=2'b00; alu_op=4'b1000;
      end
      // SHR A,B => A = B >> 1
      7'b0100001: begin
        LA=1; selA=2'b01; alu_op=4'b1000;
      end
      // SHR B,A => B = A >> 1
      7'b0100010: begin
        LB=1; selA=2'b00; alu_op=4'b1000;
      end
      // SHR B,B => B = B >> 1
      7'b0100011: begin
        LB=1; selA=2'b01; alu_op=4'b1000;
      end
      // INC B => B = B + 1 (1 + B)
      7'b0100100: begin
        LB=1; selA=2'b11; selB=2'b00; alu_op=4'b0000; // (1) + B
      end

      default: begin
        // NOP
      end
    endcase
  end

  // MUX A y B (implementados con lógica)
  wire [7:0] alu_in_a = (selA == 2'b00) ? regA_out_bus :
                        (selA == 2'b01) ? regB_out_bus :
                        (selA == 2'b10) ? 8'h00        : 8'h01;
  wire [7:0] alu_in_b = (selB == 2'b00) ? regB_out_bus :
                        (selB == 2'b01) ? regA_out_bus :
                        (selB == 2'b10) ? K            : 8'h00; // 2'b11 => 0

  // Instancias
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
  alu ALU (
      .a  (alu_in_a),
      .b  (alu_in_b),
      .s  (alu_op),
      .out(alu_out_bus),
      .Z(alu_Z), .N(alu_N), .C(alu_C), .V(alu_V)
  );
endmodule
