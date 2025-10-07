module control (
  input  [6:0] opcode,
  input  [3:0] status,      // {Z,N,C,V}
  output reg   LA,          // Load A
  output reg   LB,          // Load B
  output reg   LP,          // Load PC (salto)
  output reg   mem_we,      // DataMem write enable
  output reg   wbSel,       // 0: ALU, 1: Mem
  output reg [1:0] selA,    // 00:A, 01:B, 10:0, 11:1
  output reg [1:0] selB,    // 00:B, 01:A, 10:K, 11:mem_data
  output reg [1:0] selData, // 00:B, 10:K
  output reg [3:0] alu_op
);

  // ALU ops (ajusta si tu ALU usa otros códigos)
  localparam ALU_ADD = 4'b0000,
             ALU_SUB = 4'b0001,
             ALU_AND = 4'b0010,
             ALU_XOR = 4'b0100,
             ALU_NOT = 4'b0101,
             ALU_SHL = 4'b0111,
             ALU_SHR = 4'b1000,
             ALU_INC = 4'b1001,
             ALU_CLR = 4'b1010;

  // Flags
  wire Z = status[3];
  wire N = status[2];
  wire C = status[1];
  wire V = status[0];

  always @(*) begin
    // Defaults
    LA      = 1'b0;
    LB      = 1'b0;
    LP      = 1'b0;
    mem_we  = 1'b0;
    wbSel   = 1'b0;   // ALU
    selA    = 2'b00;  // A
    selB    = 2'b00;  // B
    selData = 2'b00;  // addr = B (cuando aplique)
    alu_op  = ALU_ADD;

    case (opcode)
      // ===== MOV =====
      // A = B
      7'b0000000: begin
        LA     = 1'b1;
        selA   = 2'b10; // 0
        selB   = 2'b00; // B
        alu_op = ALU_ADD;
      end
      // B = A
      7'b0000001: begin
        LB     = 1'b1;
        selA   = 2'b10; // 0
        selB   = 2'b01; // A
        alu_op = ALU_ADD;
      end
      // A = K
      7'b0000010: begin
        LA     = 1'b1;
        selA   = 2'b10; // 0
        selB   = 2'b10; // K
        alu_op = ALU_ADD;
      end
      // B = K
      7'b0000011: begin
        LB     = 1'b1;
        selA   = 2'b10; // 0
        selB   = 2'b10; // K
        alu_op = ALU_ADD;
      end

      // ===== ADD =====
      7'b0000100: begin // A = A + B
        LA     = 1'b1; selA = 2'b00; selB = 2'b00; alu_op = ALU_ADD;
      end
      7'b0000101: begin // B = B + A
        LB     = 1'b1; selA = 2'b01; selB = 2'b01; alu_op = ALU_ADD;
      end
      7'b0000110: begin // A = A + K
        LA     = 1'b1; selA = 2'b00; selB = 2'b10; alu_op = ALU_ADD;
      end
      7'b0000111: begin // B = B + K
        LB     = 1'b1; selA = 2'b01; selB = 2'b10; alu_op = ALU_ADD;
      end

      // ===== SUB =====
      7'b0001000: begin // A = A - B
        LA     = 1'b1; selA = 2'b00; selB = 2'b00; alu_op = ALU_SUB;
      end
      7'b0001001: begin // B = B - A
        LB     = 1'b1; selA = 2'b01; selB = 2'b01; alu_op = ALU_SUB;
      end
      7'b0001010: begin // A = A - K
        LA     = 1'b1; selA = 2'b00; selB = 2'b10; alu_op = ALU_SUB;
      end
      7'b0001011: begin // B = B - K
        LB     = 1'b1; selA = 2'b01; selB = 2'b10; alu_op = ALU_SUB;
      end

      // ===== AND =====
      7'b0001100: begin // A = A & B
        LA     = 1'b1; selA = 2'b00; selB = 2'b00; alu_op = ALU_AND;
      end
      7'b0001101: begin // B = B & A
        LB     = 1'b1; selA = 2'b01; selB = 2'b01; alu_op = ALU_AND;
      end
      7'b0001110: begin // A = A & K
        LA     = 1'b1; selA = 2'b00; selB = 2'b10; alu_op = ALU_AND;
      end
      7'b0001111: begin // B = B & K
        LB     = 1'b1; selA = 2'b01; selB = 2'b10; alu_op = ALU_AND;
      end

      // ===== OR =====
      7'b0010000: begin // A = A | B
        LA     = 1'b1; selA = 2'b00; selB = 2'b00; alu_op = 4'b0011;
      end
      7'b0010001: begin // B = B | A
        LB     = 1'b1; selA = 2'b01; selB = 2'b01; alu_op = 4'b0011;
      end
      7'b0010010: begin // A = A | K
        LA     = 1'b1; selA = 2'b00; selB = 2'b10; alu_op = 4'b0011;
      end
      7'b0010011: begin // B = B | K
        LB     = 1'b1; selA = 2'b01; selB = 2'b10; alu_op = 4'b0011;
      end

      // ===== NOT (unario) =====
      7'b0010100: begin // A = ~A
        LA     = 1'b1; selA = 2'b00; alu_op = ALU_NOT;
      end
      7'b0010101: begin // A = ~B
        LA     = 1'b1; selA = 2'b01; alu_op = ALU_NOT;
      end
      7'b0010110: begin // B = ~A
        LB     = 1'b1; selA = 2'b00; alu_op = ALU_NOT;
      end
      7'b0010111: begin // B = ~B
        LB     = 1'b1; selA = 2'b01; alu_op = ALU_NOT;
      end

      // ===== XOR =====
      7'b0011000: begin // A = A ^ B
        LA     = 1'b1; selA = 2'b00; selB = 2'b00; alu_op = ALU_XOR;
      end
      7'b0011001: begin // B = B ^ A
        LB     = 1'b1; selA = 2'b01; selB = 2'b01; alu_op = ALU_XOR;
      end
      7'b0011010: begin // A = A ^ K
        LA     = 1'b1; selA = 2'b00; selB = 2'b10; alu_op = ALU_XOR;
      end
      7'b0011011: begin // B = B ^ K
        LB     = 1'b1; selA = 2'b01; selB = 2'b10; alu_op = ALU_XOR;
      end

      // ===== SHL / SHR (unario) =====
      7'b0011100: begin LA=1'b1; selA=2'b00; alu_op=ALU_SHL; end // A<<=1 (sobre A)
      7'b0011101: begin LA=1'b1; selA=2'b01; alu_op=ALU_SHL; end // A = B<<1
      7'b0011110: begin LB=1'b1; selA=2'b00; alu_op=ALU_SHL; end // B = A<<1
      7'b0011111: begin LB=1'b1; selA=2'b01; alu_op=ALU_SHL; end // B = B<<1
      7'b0100000: begin LA=1'b1; selA=2'b00; alu_op=ALU_SHR; end // A>>=1
      7'b0100001: begin LA=1'b1; selA=2'b01; alu_op=ALU_SHR; end // A = B>>1
      7'b0100010: begin LB=1'b1; selA=2'b00; alu_op=ALU_SHR; end // B = A>>1
      7'b0100011: begin LB=1'b1; selA=2'b01; alu_op=ALU_SHR; end // B>>=1

      // ===== INC (unario) =====
      7'b0100100: begin // B = B + 1
        LB     = 1'b1; selA = 2'b01; alu_op = ALU_INC;
      end

      // ===== Direccionamiento (lectura y escritura) =====
      7'b0100101: begin // MOV A, [K]
        LA      = 1'b1; wbSel = 1'b1; selData = 2'b10;
      end
      7'b0100110: begin // MOV B, [K]
        LB      = 1'b1; wbSel = 1'b1; selData = 2'b10;
      end
      7'b0100111: begin // [K] = A
        mem_we  = 1'b1; selData = 2'b10; selA = 2'b00; // dato típico: regB_out o ALU según tu RAM
      end
      7'b0101000: begin // [K] = B
        mem_we  = 1'b1; selData = 2'b10; selB = 2'b00;
      end
      7'b0101001: begin // MOV A, [B]
        LA      = 1'b1; wbSel = 1'b1; selData = 2'b00; // addr=B
      end
      7'b0101010: begin // MOV B, [B]
        LB      = 1'b1; wbSel = 1'b1; selData = 2'b00;
      end
      7'b0101011: begin // [B] = A
        mem_we  = 1'b1; selData = 2'b00; selA = 2'b00;
      end

      // A = A + [K]
      7'b0101100: begin
        LA      = 1'b1; wbSel = 1'b0; selA = 2'b00; selB = 2'b11; selData = 2'b10; alu_op = ALU_ADD;
      end
      // B = B + [K]
      7'b0101101: begin
        LB      = 1'b1; wbSel = 1'b0; selA = 2'b01; selB = 2'b11; selData = 2'b10; alu_op = ALU_ADD;
      end
      // A = A + [B]
      7'b0101110: begin
        LA      = 1'b1; wbSel = 1'b0; selA = 2'b00; selB = 2'b11; selData = 2'b00; alu_op = ALU_ADD;
      end
      // [K] = A + B
      7'b0101111: begin
        mem_we  = 1'b1; selA = 2'b00; selB = 2'b01; selData = 2'b10; alu_op = ALU_ADD;
      end

      // SUB/AND/OR/XOR con [K] o [B] (formatos análogos)
      7'b0110000: begin // A = A - [K]
        LA=1; wbSel=0; selA=2'b00; selB=2'b11; selData=2'b10; alu_op=ALU_SUB;
      end
      7'b0110001: begin // B = B - [K]
        LB=1; wbSel=0; selA=2'b01; selB=2'b11; selData=2'b10; alu_op=ALU_SUB;
      end
      7'b0110010: begin // A = A - [B]
        LA=1; wbSel=0; selA=2'b00; selB=2'b11; selData=2'b00; alu_op=ALU_SUB;
      end
      7'b0110011: begin // [K] = A - B
        mem_we=1; selA=2'b00; selB=2'b01; selData=2'b10; alu_op=ALU_SUB;
      end

      7'b0110100: begin // A = A & [K]
        LA=1; wbSel=0; selA=2'b00; selB=2'b11; selData=2'b10; alu_op=ALU_AND;
      end
      7'b0110101: begin // B = B & [K]
        LB=1; wbSel=0; selA=2'b01; selB=2'b11; selData=2'b10; alu_op=ALU_AND;
      end
      7'b0110110: begin // A = A & [B]
        LA=1; wbSel=0; selA=2'b00; selB=2'b11; selData=2'b00; alu_op=ALU_AND;
      end
      7'b0110111: begin // [K] = A & B
        mem_we=1; selA=2'b00; selB=2'b01; selData=2'b10; alu_op=ALU_AND;
      end

      7'b0111000: begin // A = A | [K]
        LA=1; wbSel=0; selA=2'b00; selB=2'b11; selData=2'b10; alu_op=4'b0011;
      end
      7'b0111001: begin // B = B | [K]
        LB=1; wbSel=0; selA=2'b01; selB=2'b11; selData=2'b10; alu_op=4'b0011;
      end
      7'b0111010: begin // A = A | [B]
        LA=1; wbSel=0; selA=2'b00; selB=2'b11; selData=2'b00; alu_op=4'b0011;
      end
      7'b0111011: begin // [K] = A | B
        mem_we=1; selA=2'b00; selB=2'b01; selData=2'b10; alu_op=4'b0011;
      end

      // NOT / SHL / SHR escribiendo en memoria (sobre A o B, no RMW)
      7'b0111100: begin // [K] = ~A
        mem_we=1; selA=2'b00; selData=2'b10; alu_op=ALU_NOT;
      end
      7'b0111101: begin // [K] = ~B
        mem_we=1; selA=2'b01; selData=2'b10; alu_op=ALU_NOT;
      end
      7'b0111110: begin // [B] = ~A
        mem_we=1; selA=2'b00; selData=2'b00; alu_op=ALU_NOT;
      end

      7'b0111111: begin // A = A ^ [K]
        LA=1; wbSel=0; selA=2'b00; selB=2'b11; selData=2'b10; alu_op=ALU_XOR;
      end
      7'b1000000: begin // B = B ^ [K]
        LB=1; wbSel=0; selA=2'b01; selB=2'b11; selData=2'b10; alu_op=ALU_XOR;
      end
      7'b1000001: begin // A = A ^ [B]
        LA=1; wbSel=0; selA=2'b00; selB=2'b11; selData=2'b00; alu_op=ALU_XOR;
      end
      7'b1000010: begin // [K] = A ^ B
        mem_we=1; selA=2'b00; selB=2'b01; selData=2'b10; alu_op=ALU_XOR;
      end

      7'b1000011: begin // [K] = A<<1
        mem_we=1; selA=2'b00; selData=2'b10; alu_op=ALU_SHL;
      end
      7'b1000100: begin // [K] = B<<1
        mem_we=1; selA=2'b01; selData=2'b10; alu_op=ALU_SHL;
      end
      7'b1000101: begin // [B] = A<<1
        mem_we=1; selA=2'b00; selData=2'b00; alu_op=ALU_SHL;
      end
      7'b1000110: begin // [K] = A>>1
        mem_we=1; selA=2'b00; selData=2'b10; alu_op=ALU_SHR;
      end
      7'b1000111: begin // [K] = B>>1
        mem_we=1; selA=2'b01; selData=2'b10; alu_op=ALU_SHR;
      end
      7'b1001000: begin // [B] = A>>1
        mem_we=1; selA=2'b00; selData=2'b00; alu_op=ALU_SHR;
      end

      // ===== RST (escribir 0 en memoria) =====
      7'b1001011: begin // [K] = 0
        mem_we=1; selData=2'b10; alu_op=ALU_CLR;
      end
      7'b1001100: begin // [B] = 0
        mem_we=1; selData=2'b00; alu_op=ALU_CLR;
      end

      // ===== Comparación (solo flags) =====
      7'b1001101: begin // CMP A,B
        selA=2'b00; selB=2'b00; alu_op=ALU_SUB;
      end
      7'b1001110: begin // CMP A,K
        selA=2'b00; selB=2'b10; alu_op=ALU_SUB;
      end
      7'b1001111: begin // CMP B,K
        selA=2'b01; selB=2'b10; alu_op=ALU_SUB;
      end
      7'b1010000: begin // CMP A,[K]
        selA=2'b00; selB=2'b11; selData=2'b10; alu_op=ALU_SUB;
      end
      7'b1010001: begin // CMP B,[K]
        selA=2'b01; selB=2'b11; selData=2'b10; alu_op=ALU_SUB;
      end
      7'b1010010: begin // CMP A,[B]
        selA=2'b00; selB=2'b11; selData=2'b00; alu_op=ALU_SUB;
      end

      // ===== Saltos (LP) =====
      7'b1010011: begin // JMP literal
        LP = 1'b1;
      end
      7'b1010100: begin // JEQ literal (Z==1)
        if (Z) LP = 1'b1;
      end
      7'b1010101: begin // JNE literal (Z==0)
        if (!Z) LP = 1'b1;
      end
      7'b1010110: begin // JGT literal (N==0 && Z==0) para enteros con signo
        if (!N && !Z) LP = 1'b1;
      end
      7'b1010111: begin // JLT literal (N==1)
        if (N) LP = 1'b1;
      end
      7'b1011000: begin // JGE literal (N==0)
        if (!N) LP = 1'b1;
      end
      7'b1011001: begin // JLE literal (N==1 || Z==1)
        if (N || Z) LP = 1'b1;
      end
      7'b1011010: begin // JCR literal (C==1)
        if (C) LP = 1'b1;
      end
      7'b1011011: begin // JOV literal (V==1)
        if (V) LP = 1'b1;
      end

      default: begin
        // keep defaults
      end
    endcase
  end
endmodule

