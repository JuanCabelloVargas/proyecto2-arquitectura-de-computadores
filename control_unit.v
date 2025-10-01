module control(
    input  [6:0] opcode,      // desde Instruction Memory
    input  [3:0] status,      
    output reg   LA,          // Load A
    output reg   LB,          
    output reg   LP,          
    output reg   mem_we,     
    output reg   wbSel,       
    output reg [1:0] selA,    
    output reg [1:0] selB,    
    output reg [1:0] selData, 
    output reg [3:0] alu_op   // operación ALU
);

  always @(*) begin
    LA      = 1'b0;
    LB      = 1'b0;
    LP      = 1'b0;
    mem_we  = 1'b0;
    wbSel   = 1'b0;      // ALU
    selA    = 2'b00;     // A
    selB    = 2'b00;     // B
    selData = 2'b00;     // addr = A
    alu_op  = 4'b0000;   // ADD
    case (opcode)
      // MOV A,B => A = B (A = 0 + B)
      7'b0000000: begin
        LA     = 1; 
        selA   = 2'b10; // 0 
        selB   = 2'b00; // B
        alu_op = 4'b0000; // ALU hace ADD

      end
      // MOV B,A => B = A (B = 0 + A)
      7'b0000001: begin
        LB     = 1; 
        selA   = 2'b10; // 0
        selB   = 2'b01; // A
        alu_op = 4'b0000; // ALU hace ADD
      end

      // MOV A,K => A = K (A = 0 + K)
      7'b0000010: begin
        LA     = 1; 
        selA   = 2'b10; // 0
        selB   = 2'b10; // K
        alu_op = 4'b0000; // ALU hace ADD
      end

      // MOV B,K => B = K (B = 0 + K)
      7'b0000011: begin
        LB     = 1; 
        selA   = 2'b10; // 0
        selB   = 2'b10; // K
        alu_op = 4'b0000; // ALU hace ADD
      end

      // ADD A,B => A = A + B
      7'b0000100: begin
        LA     = 1; 
        selA   = 2'b00; // A
        selB   = 2'b00; // B
        alu_op = 4'b0000; // ALU hace ADD
      end

      // ADD B,A => B = B + A
      7'b0000101: begin
        LB     = 1; 
        selA   = 2'b01; // B
        selB   = 2'b01; // A
        alu_op = 4'b0000; // ALU hace ADD
      end

      // ADD A,K => A = A + K
      7'b0000110: begin
        LA     = 1; 
        selA   = 2'b00; // A
        selB   = 2'b10; // K
        alu_op = 4'b0000; // ALU hace ADD
      end

      // ADD B,K => B = B + K
      7'b0000111: begin
        LB     = 1; 
        selA   = 2'b01; // B
        selB   = 2'b10; // K
        alu_op = 4'b0000; // ALU hace ADD
      end

      // SUB A,B => A = A - B
      7'b0001000: begin
        LA     = 1; 
        selA   = 2'b00; // A
        selB   = 2'b00; // B
        alu_op = 4'b0001; // ALU hace SUB
      end

      // SUB B,A => B = B - A
      7'b0001001: begin
        LB     = 1; 
        selA   = 2'b01; // B
        selB   = 2'b01; // A
        alu_op = 4'b0001; // ALU hace SUB
      end

      // SUB A,K => A = A - K
      7'b0001010: begin
        LA     = 1; 
        selA   = 2'b00; // A
        selB   = 2'b10; // K
        alu_op = 4'b0001; // ALU hace SUB
      end

      // SUB B,K => B = B - K
      7'b0001011: begin
        LB     = 1; 
        selA   = 2'b01; // B
        selB   = 2'b10; // K
        alu_op = 4'b0001; // ALU hace SUB
      end

      // AND A,B => A = A and B
      7'b0001100: begin
        LA     = 1; 
        selA   = 2'b00; // A
        selB   = 2'b00; // B
        alu_op = 4'b0010; // ALU hace AND
      end

      // AND B,A => B = B and A
      7'b0001101: begin
        LB     = 1; 
        selA   = 2'b01; // B
        selB   = 2'b01; // A
        alu_op = 4'b0010; // ALU hace AND
      end

      // AND A,K => A = A and K
      7'b0001110: begin
        LA     = 1; 
        selA   = 2'b00; // A
        selB   = 2'b10; // K
        alu_op = 4'b0010; // ALU hace AND
      end

      // AND B,K => B = B and K
      7'b0001111: begin
        LB     = 1; 
        selA   = 2'b01; // B
        selB   = 2'b10; // K
        alu_op = 4'b0010; // ALU hace AND
      end

      // OR A,B => A = A or B
      7'b0010000: begin
        LA     = 1; 
        selA   = 2'b00; // A
        selB   = 2'b00; // B
        alu_op = 4'b0011; // ALU hace OR
      end

      // OR B,A => B = B or A
      7'b0010001: begin
        LB     = 1; 
        selA   = 2'b01; // B
        selB   = 2'b01; // A
        alu_op = 4'b0011; // ALU hace OR
      end

      // OR A,K => A = A or K
      7'b0010010: begin
        LA     = 1; 
        selA   = 2'b00; // A
        selB   = 2'b10; // K
        alu_op = 4'b0011; // ALU hace OR
      end

      // OR B,K => B = B or K
      7'b0010011: begin
        LB     = 1; 
        selA   = 2'b01; // B
        selB   = 2'b10; // K
        alu_op = 4'b0011; // ALU hace OR
      end

      // NOT A,A => A = ~A 
      7'b0010100: begin
        LA     = 1; 
        selA   = 2'b00; // A
        alu_op = 4'b0101; // ALU hace NOT
      end

      // NOT A,B => A = ~B 
      7'b0010101: begin
        LA     = 1; 
        selA   = 2'b01; // B
        alu_op = 4'b0101; // ALU hace NOT
      end

      // NOT B,A => B = ~A 
      7'b0010110: begin
        LB     = 1; 
        selA   = 2'b00; // A
        selB   = 2'b01; // B
        alu_op = 4'b0110; // ALU hace NOT
      end

      // NOT B,B => B = ~B 
      7'b0010111: begin
        LB     = 1; 
        selA   = 2'b01; // B
        alu_op = 4'b0110; // ALU hace NOT
      end

      // XOR A,B => A = A xor B
      7'b0011000: begin
        LA     = 1; 
        selA   = 2'b00; // A
        selB   = 2'b00; // B
        alu_op = 4'b0100; // ALU hace XOR
      end

      // XOR B,A => B = B xor A
      7'b0011001: begin
        LB     = 1; 
        selA   = 2'b01; // B
        selB   = 2'b01; // A
        alu_op = 4'b0100; // ALU hace XOR
      end

      // XOR A,K => A = A xor K
      7'b0011010: begin
        LA     = 1; 
        selA   = 2'b00; // A
        selB   = 2'b10; // K
        alu_op = 4'b0100; // ALU hace XOR
      end

      // XOR B,K => B = B xor K
      7'b0011011: begin
        LB     = 1; 
        selA   = 2'b01; // B
        selB   = 2'b10; // K
        alu_op = 4'b0100; // ALU hace XOR
      end

      // SHL A,A => A = shift left A 
      7'b0011100: begin
        LA     = 1; 
        selA   = 2'b00; // A
        alu_op = 4'b0111; // ALU hace SHL
      end

      // SHL A,B => A = shift left B
      7'b0011101: begin
        LA     = 1; 
        selA   = 2'b01; // B
        alu_op = 4'b0111; // ALU hace SHL
      end

      // SHL B,A => B = shift left A
      7'b0011110: begin
        LB     = 1; 
        selA   = 2'b00; // A
        alu_op = 4'b0111; // ALU hace SHL
      end

      // SHL B,B => B = shift left B
      7'b0011111: begin
        LB     = 1; 
        selA   = 2'b01; // B
        alu_op = 4'b0111; // ALU hace SHL
      end

      // SHR A,A => A = shift right A
      7'b0100000: begin
        LA     = 1; 
        selA   = 2'b00; // A
        alu_op = 4'b1000; // ALU hace SHR
      end

      // SHR A,B => A = shift right B
      7'b0100001: begin
        LA     = 1; 
        selA   = 2'b01; // B
        alu_op = 4'b1000; // ALU hace SHR
      end

      // SHR B,A => B = shift right A
      7'b0100010: begin
        LB     = 1; 
        selA   = 2'b00; // A
        alu_op = 4'b1000; // ALU hace SHR
      end

      // SHR B,B => B = shift right B
      7'b0100011: begin
        LB     = 1; 
        selA   = 2'b01; // B
        alu_op = 4'b1000; // ALU hace SHR
      end

      // INC B => B = B + 1 
      7'b0100100: begin
        LB     = 1; 
        selA   = 2'b11; // B
        selB   = 2'b00; // 1
        alu_op = 4'b0000; // ALU hace ADD
      end

      default: begin
        // Nada
      end

    endcase
  end

endmodule