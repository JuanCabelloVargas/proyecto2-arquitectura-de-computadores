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
  output reg [1:0] selMemData, // Para datos a escribir: 00:B, 01:A, 10:K, 11:ALU
  output reg [3:0] alu_op
);

  // ALU ops
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
    LA         = 1'b0;
    LB         = 1'b0;
    LP         = 1'b0;
    mem_we     = 1'b0;
    wbSel      = 1'b0;   // ALU
    selA       = 2'b00;  // A
    selB       = 2'b00;  // B
    selData    = 2'b00;  // addr = B (cuando aplique)
    selMemData = 2'b00;  // data = B (cuando aplique)
    alu_op     = ALU_ADD;

    case (opcode)

      /*
      Instrucciones Basicas
      */

      // MOV A,B => A = B (A = 0 + B)
      7'b0000000: begin
        LA     = 1'b1;
        selA   = 2'b10;
        selB   = 2'b00;
        alu_op = ALU_ADD;
      end

      // MOV B,A => B = A (B = 0 + A)
      7'b0000001: begin
        LB     = 1'b1;
        selA   = 2'b10;
        selB   = 2'b01;
        alu_op = ALU_ADD;
      end

      // MOV A,K => A = K (A = 0 + K)
      7'b0000010: begin
        LA     = 1'b1;
        selA   = 2'b10; 
        selB   = 2'b10; 
        alu_op = ALU_ADD;
      end

      // MOV B,K => B = K (B = 0 + K)
      7'b0000011: begin
        LB     = 1'b1;
        selA   = 2'b10;
        selB   = 2'b10; 
        alu_op = ALU_ADD;
      end

      // ADD A,B => A = A + B
      7'b0000100: begin 
        LA     = 1'b1; 
        selA   = 2'b00; 
        selB   = 2'b00; 
        alu_op = ALU_ADD;
      end

      // ADD B,A => B = B + A
      7'b0000101: begin 
        LB     = 1'b1; 
        selA   = 2'b01; 
        selB   = 2'b01; 
        alu_op = ALU_ADD;
      end

      // ADD A,K => A = A + K
      7'b0000110: begin
        LA     = 1'b1; 
        selA   = 2'b00; 
        selB   = 2'b10; 
        alu_op = ALU_ADD;
      end

      // ADD B,K => B = B + K
      7'b0000111: begin
        LB     = 1'b1; 
        selA   = 2'b01; 
        selB   = 2'b10; 
        alu_op = ALU_ADD;
      end

      // SUB A,B => A = A - B
      7'b0001000: begin 
        LA     = 1'b1; 
        selA   = 2'b00; 
        selB   = 2'b00; 
        alu_op = ALU_SUB;
      end

      // SUB B,A => B = A - B  
      7'b0001001: begin 
        LB     = 1'b1; 
        selA   = 2'b00; 
        selB   = 2'b00; 
        alu_op = ALU_SUB;
      end

      // SUB A,K => A = A - K
      7'b0001010: begin 
        LA     = 1'b1; 
        selA   = 2'b00; 
        selB   = 2'b10; 
         alu_op = ALU_SUB;
      end
      
      // SUB B,K => B = B - K
      7'b0001011: begin
        LB     = 1'b1; 
        selA   = 2'b01; 
        selB   = 2'b10; 
        alu_op = ALU_SUB;
      end

      // AND A,B => A = A and B
      7'b0001100: begin 
        LA     = 1'b1; 
        selA   = 2'b00; 
        selB   = 2'b00; 
        alu_op = ALU_AND;
      end

      // AND B,A => B = B and A
      7'b0001101: begin 
        LB     = 1'b1; 
        selA   = 2'b01; 
        selB   = 2'b01; 
        alu_op = ALU_AND;
      end
      
      // AND A,K => A = A and K
      7'b0001110: begin 
        LA     = 1'b1; 
        selA   = 2'b00; 
        selB   = 2'b10; 
        alu_op = ALU_AND;
      end

      // AND B,K => B = B and K
      7'b0001111: begin 
        LB     = 1'b1; 
        selA   = 2'b01; 
        selB   = 2'b10; 
        alu_op = ALU_AND;
      end

      // OR A,B => A = A or B
      7'b0010000: begin 
        LA     = 1'b1; 
        selA   = 2'b00; 
        selB   = 2'b00; 
        alu_op = 4'b0011;
      end

      // OR B,A => B = B or A
      7'b0010001: begin 
        LB     = 1'b1; 
        selA   = 2'b01; 
        selB   = 2'b01; 
        alu_op = 4'b0011;
      end

      // OR A,K => A = A or K
      7'b0010010: begin 
        LA     = 1'b1; 
        selA   = 2'b00; 
        selB   = 2'b10; 
        alu_op = 4'b0011;
      end

      // OR B,K => B = B or K
      7'b0010011: begin 
        LB     = 1'b1; 
        selA   = 2'b01; 
        selB   = 2'b10; 
        alu_op = 4'b0011;
      end

      // NOT A,A => A = ~A
      7'b0010100: begin 
        LA     = 1'b1; 
        selA   = 2'b00; 
        alu_op = ALU_NOT;
      end

      // NOT B,A => B = ~A
      7'b0010101: begin 
        LA     = 1'b1; 
        selA   = 2'b01; 
        alu_op = ALU_NOT;
      end

      // NOT A,B => A = ~B
      7'b0010110: begin 
        LB     = 1'b1; 
        selA   = 2'b00; 
        alu_op = ALU_NOT;
      end

      // NOT B,B => B = ~B
      7'b0010111: begin
        LB     = 1'b1; 
        selA   = 2'b01; 
        alu_op = ALU_NOT;
      end

      // XOR A,B => A = A xor B
      7'b0011000: begin 
        LA     = 1'b1; 
        selA   = 2'b00; 
        selB   = 2'b00; 
        alu_op = ALU_XOR;
      end

      // XOR B,A => B = B xor A
      7'b0011001: begin 
        LB     = 1'b1; 
        selA   = 2'b01; 
        selB   = 2'b01; 
        alu_op = ALU_XOR;
      end

      // XOR A,K => A = A xor K
      7'b0011010: begin 
        LA     = 1'b1; 
        selA   = 2'b00; 
        selB   = 2'b10; 
        alu_op = ALU_XOR;
      end

      // XOR B,K => B = B xor K
      7'b0011011: begin
        LB     = 1'b1; 
        selA   = 2'b01; 
        selB   = 2'b10; 
        alu_op = ALU_XOR;
      end

      // SHL A,A => A = shift left A
      7'b0011100: begin 
        LA     = 1'b1; 
        selA   = 2'b00; 
        alu_op = ALU_SHL; 
      end 

      // SHL A,B => A = shift left B
      7'b0011101: begin 
        LA     = 1'b1; 
        selA   = 2'b01; 
        alu_op = ALU_SHL; 
      end 

      // SHL B,A => B = shift left A
      7'b0011110: begin 
        LB     = 1'b1; 
        selA   = 2'b00; 
        alu_op = ALU_SHL; 
      end 

      // SHL B,B => B = shift left B
      7'b0011111: begin 
        LB     = 1'b1; 
        selA   = 2'b01; 
        alu_op = ALU_SHL; 
      end 

      // SHR A,A => A = shift right A
      7'b0100000: begin 
        LA     = 1'b1; 
        selA   = 2'b00; 
        alu_op = ALU_SHR; 
      end 

      // SHR A,B => A = shift right B
      7'b0100001: begin 
        LA     = 1'b1; 
        selA   = 2'b01; 
        alu_op = ALU_SHR; 
      end 

      // SHR B,A => B = shift right A
      7'b0100010: begin 
        LB     = 1'b1; 
        selA   = 2'b00; 
        alu_op = ALU_SHR; 
      end 

      // SHR B,B => B = shift right B
      7'b0100011: begin 
        LB     = 1'b1; 
        selA   = 2'b01; 
        alu_op = ALU_SHR; 
      end 

      // INC B => B = B + 1
      7'b0100100: begin
        LB     = 1'b1; 
        selA   = 2'b01; 
        alu_op = ALU_INC;
      end

      /*
      Instrucciones con Direccionamiento
      */

      // MOV A,DIR => A = MEM[LIT]
      7'b0100101: begin 
        LA      = 1'b1; 
        wbSel   = 1'b1; 
        selData = 2'b10;
      end

      // MOV B,DIR => B = MEM[LIT]
      7'b0100110: begin 
        LB      = 1'b1; 
        wbSel   = 1'b1; 
        selData = 2'b10;
      end

      // MOV DIR,A => MEM[LIT] = A
      7'b0100111: begin
        mem_we     = 1'b1; 
        selData    = 2'b10; 
        selMemData = 2'b01; 
      end

      // MOV [K],B => MEM[LIT] = B
      7'b0101000: begin
        mem_we     = 1'b1;
        selData    = 2'b10; 
        selMemData = 2'b00;  
      end

      // MOV A,[B] => A = MEM[B]
      7'b0101001: begin
        LA      = 1'b1; 
        wbSel   = 1'b1; 
        selData = 2'b00;
      end

      // MOV B,[B] => B = MEM[B]
      7'b0101010: begin
        LB      = 1'b1;
        wbSel   = 1'b1;
        selData = 2'b00;
      end

      // MOV [B],A => MEM[B] = A
      7'b0101011: begin
        mem_we     = 1'b1; 
        selData    = 2'b00; 
        selMemData = 2'b01;  
      end

      // ADD A,(DIR) => A = A + MEM[LIT]
      7'b0101100: begin
        LA      = 1'b1; 
        wbSel   = 1'b0; 
        selA    = 2'b00; 
        selB    = 2'b11; 
        selData = 2'b10; 
        alu_op  = ALU_ADD;
      end

      // ADD B,(DIR) => B = B + MEM[LIT]
      7'b0101101: begin
        LB      = 1'b1; 
        wbSel   = 1'b0; 
        selA    = 2'b01; 
        selB    = 2'b11; 
        selData = 2'b10; 
        alu_op  = ALU_ADD;
      end

      // ADD A,(B) => A = A + MEM[B]
      7'b0101110: begin
        LA      = 1'b1; 
        wbSel   = 1'b0; 
        selA    = 2'b00; 
        selB    = 2'b11; 
        selData = 2'b00; 
        alu_op  = ALU_ADD;
      end
      
      // ADD (DIR) => MEM[LIT] = A + B
      7'b0101111: begin
        mem_we  = 1'b1; 
        selA    = 2'b00; 
        selB    = 2'b01; 
        selData = 2'b10; 
        alu_op  = ALU_ADD;
      end

      // SUB A,(DIR) => A = A - MEM[LIT]
      7'b0110000: begin 
        LA      = 1; 
        wbSel   = 0; 
        selA    = 2'b00; 
        selB    = 2'b11; 
        selData = 2'b10; 
        alu_op  = ALU_SUB;
      end

      // SUB B,(DIR) => B = B - MEM[LIT]
      7'b0110001: begin 
        LB      = 1; 
        wbSel   = 0; 
        selA    = 2'b01; 
        selB    = 2'b11; 
        selData = 2'b10; 
        alu_op  = ALU_SUB;
      end

      // SUB A,(B) => A = A - MEM[B]
      7'b0110010: begin
        LA      = 1; 
        wbSel   = 0; 
        selA    = 2'b00; 
        selB    = 2'b11; 
        selData = 2'b00; 
        alu_op  = ALU_SUB;
      end

      // SUB (DIR) => MEM[LIT] = A - B
      7'b0110011: begin
        mem_we  = 1; 
        selA    = 2'b00; 
        selB    = 2'b01; 
        selData = 2'b10; 
        alu_op  = ALU_SUB;
      end

      // AND A,(DIR) => A = A and MEM[LIT]
      7'b0110100: begin
        LA      = 1; 
        wbSel   = 0; 
        selA    = 2'b00; 
        selB    = 2'b11; 
        selData = 2'b10; 
        alu_op  = ALU_AND;
      end

      // AND B,(DIR) => B = B and MEM[LIT]
      7'b0110101: begin
        LB      = 1; 
        wbSel   = 0; 
        selA    = 2'b01; 
        selB    = 2'b11; 
        selData = 2'b10; 
        alu_op  = ALU_AND;
      end

      // AND A,(B) => A = A and MEM[B]
      7'b0110110: begin 
        LA      = 1; 
        wbSel   = 0; 
        selA    = 2'b00; 
        selB    = 2'b11; 
        selData = 2'b00; 
        alu_op  = ALU_AND;
      end

      // AND (DIR) => MEM[LIT] = A and B
      7'b0110111: begin 
        mem_we  = 1; 
        selA    = 2'b00; 
        selB    = 2'b01; 
        selData = 2'b10; 
        alu_op  = ALU_AND;
      end

      // OR A,(DIR) => A = A or MEM[LIT]
      7'b0111000: begin
        LA      = 1; 
        wbSel   = 0; 
        selA    = 2'b00; 
        selB    = 2'b11; 
        selData = 2'b10; 
        alu_op  = 4'b0011;
      end

      // OR B,(DIR) => B = B or MEM[LIT]
      7'b0111001: begin
        LB      = 1; 
        wbSel   = 0; 
        selA    = 2'b01; 
        selB    = 2'b11; 
        selData = 2'b10; 
        alu_op  = 4'b0011;
      end
      
      // OR A,(B) => A = A or MEM[B]
      7'b0111010: begin 
        LA      = 1; 
        wbSel   = 0; 
        selA    = 2'b00; 
        selB    = 2'b11; 
        selData = 2'b00; 
        alu_op  = 4'b0011;
      end

      // OR (DIR) => MEM[LIT] = A or B
      7'b0111011: begin
        mem_we  = 1; 
        selA    = 2'b00; 
        selB    = 2'b01; 
        selData = 2'b10; 
        alu_op  = 4'b0011;
      end

      // NOT (DIR),A => MEM[LIT] = ~A
      7'b0111100: begin 
        mem_we  = 1; 
        selA    = 2'b00; 
        selData = 2'b10; 
        alu_op  = ALU_NOT;
      end

      // NOT (DIR),B => MEM[LIT] = ~B
      7'b0111101: begin 
        mem_we  = 1; 
        selA    = 2'b01; 
        selData = 2'b10; 
        alu_op  = ALU_NOT;
      end

      // NOT (B) => MEM[B] = ~A
      7'b0111110: begin 
        mem_we  = 1; 
        selA    = 2'b00; 
        selData = 2'b00; 
        alu_op  = ALU_NOT;
      end

      // XOR A,(DIR) => A = A xor MEM[LIT]
      7'b0111111: begin 
        LA      = 1; 
        wbSel   = 0; 
        selA    = 2'b00; 
        selB    = 2'b11; 
        selData = 2'b10; 
        alu_op  = ALU_XOR;
      end

      // XOR B,(DIR) => B = B xor MEM[LIT]
      7'b1000000: begin 
        LB      = 1; 
        wbSel   = 0; 
        selA    = 2'b01; 
        selB    = 2'b11; 
        selData = 2'b10; 
        alu_op  = ALU_XOR;
      end

      // XOR A,(B) => A = A xor MEM[B]
      7'b1000001: begin  
        LA      = 1; 
        wbSel   = 0; 
        selA    = 2'b00; 
        selB    = 2'b11; 
        selData = 2'b00; 
        alu_op  = ALU_XOR;
      end

      // XOR (DIR) => MEM[LIT] = A xor B
      7'b1000010: begin 
        mem_we  = 1; 
        selA    = 2'b00; 
        selB    = 2'b01; 
        selData = 2'b10; 
        alu_op  = ALU_XOR;
      end

      // SHL (DIR),A => MEM[LIT] = shift left A
      7'b1000011: begin 
        mem_we  = 1; 
        selA    = 2'b00; 
        selData = 2'b10; 
        alu_op  = ALU_SHL;
      end

      // SHL (DIR),B => MEM[LIT] = shift left B
      7'b1000100: begin  
        mem_we  = 1; 
        selA    = 2'b01; 
        selData = 2'b10; 
        alu_op  = ALU_SHL;
      end
      
      // SHL (B) => MEM[B] = shift left A
      7'b1000101: begin 
        mem_we  = 1; 
        selA    = 2'b00; 
        selData = 2'b00; 
        alu_op  = ALU_SHL;
      end

      // SHR (DIR),A => MEM[LIT] = shift right A
      7'b1000110: begin 
        mem_we  = 1; 
        selA    = 2'b00; 
        selData = 2'b10; 
        alu_op  = ALU_SHR;
      end
      
      // SHR (DIR),B => MEM[LIT] = shift right B
      7'b1000111: begin 
        mem_we  = 1; 
        selA    = 2'b01; 
        selData = 2'b10; 
        alu_op  = ALU_SHR;
      end

      // SHR (B) => MEM[B] = shift right A
      7'b1001000: begin  
        mem_we  = 1; 
        selA    = 2'b00; 
        selData = 2'b00; 
        alu_op  = ALU_SHR;
      end

      // INC (DIR) => MEM[LIT] = MEM[LIT] + 1
      7'b1001001: begin
        mem_we  = 1;        
        selA    = 2'b11;  
        selData = 2'b10;   
        alu_op  = ALU_INC; 
      end

      // INC (B) => MEM[B] = MEM[B] + 1
      7'b1001010: begin
        mem_we  = 1;     
        selA    = 2'b11;  
        selData = 2'b00;   
        alu_op  = ALU_INC; 
      end

      // RST (DIR) => MEM[LIT] = 0
      7'b1001011: begin 
        mem_we  = 1; 
        selData = 2'b10; 
        alu_op  = ALU_CLR;
      end

      // RST (B) => MEM[B] = 0
      7'b1001100: begin 
        mem_we  = 1; 
        selData = 2'b00; 
        alu_op  = ALU_CLR;
      end

      /*
      Instrucciones de salto
      */

      // CMP A,B => A - B
      7'b1001101: begin 
        selA   = 2'b00; 
        selB   = 2'b00; 
        alu_op = ALU_SUB;
      end

      // CMP A,K => A - K
      7'b1001110: begin 
        selA   = 2'b00; 
        selB   = 2'b10; 
        alu_op = ALU_SUB;
      end

      // CMP B,K => B - K
      7'b1001111: begin 
        selA   = 2'b01; 
        selB   = 2'b10; 
        alu_op = ALU_SUB;
      end

      // CMP A,(DIR) => A - MEM[LIT]
      7'b1010000: begin 
        selA   = 2'b00; 
        selB   = 2'b11; 
        selData= 2'b10; 
        alu_op = ALU_SUB;
      end

      // CMP B,(DIR) => B - MEM[LIT]
      7'b1010001: begin 
        selA   = 2'b01; 
        selB   = 2'b11; 
        selData= 2'b10; 
        alu_op = ALU_SUB;
      end

      // CMP A,(B) => A - MEM[B]
      7'b1010010: begin
        selA   = 2'b00; 
        selB   = 2'b11; 
        selData= 2'b00; 
        alu_op = ALU_SUB;
      end

      // JMP DIR => PC = Lit
      7'b1010011: begin 
        LP = 1'b1;
      end

      // JEQ DIR => PC = Lit si Z=1
      7'b1010100: begin
        if (Z) LP = 1'b1; 
      end

      // JNE DIR => PC = Lit si Z=0
      7'b1010101: begin
        if (!Z) LP = 1'b1;
      end

      // JGT DIR => PC = Lit si N=0 y Z=0
      7'b1010110: begin 
        if (!N && !Z) LP = 1'b1;
      end

      // JLT DIR => PC = Lit si N=1
      7'b1010111: begin
        if (N) LP = 1'b1;
      end

      // JGE DIR => PC = Lit si N=0
      7'b1011000: begin
        if (!N) LP = 1'b1;
      end

      // JLE DIR => PC = Lit si N=1 o Z=1
      7'b1011001: begin
        if (N || Z) LP = 1'b1;
      end

      // JCR DIR => PC = Lit si C=1 (carry)
      7'b1011010: begin
        if (C) LP = 1'b1;
      end

      // JOV DIR => PC = Lit si V=1 (overflow)
      7'b1011011: begin
        if (V) LP = 1'b1;
      end

      default: begin
        // Nada
      end
    endcase
  end
endmodule

