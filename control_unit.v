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

      // MOV A,B => A = B
      7'b0000000: begin
        LA     = 1;
        selA   = 2'b10;   // 0
        selB   = 2'b00;   // B
        alu_op = 4'b0000; // ADD
      end

      // MOV B,A => B = A
      7'b0000001: begin
        LB     = 1;
        selA   = 2'b10;   // 0
        selB   = 2'b01;   // A
        alu_op = 4'b0000;
      end

      // MOV A,K => A = K
      7'b0000010: begin
        LA     = 1;
        selA   = 2'b10;   // 0
        selB   = 2'b10;   // K
        alu_op = 4'b0000;
      end

      // MOV B,K => B = K
      7'b0000011: begin
        LB     = 1;
        selA   = 2'b10;
        selB   = 2'b10;   // K
        alu_op = 4'b0000;
      end

      // ADD A,B
      7'b0000100: begin
        LA     = 1;
        selA   = 2'b00;   // A
        selB   = 2'b00;   // B
        alu_op = 4'b0000;
      end

      // ADD B,A
      7'b0000101: begin
        LB     = 1;
        selA   = 2'b01;   // B
        selB   = 2'b01;   // A
        alu_op = 4'b0000;
      end

      // SUB A,B
      7'b0001000: begin
        LA     = 1;
        selA   = 2'b00;   // A
        selB   = 2'b00;   // B
        alu_op = 4'b0001; // SUB
      end

      // AND A,K
      7'b0001110: begin
        LA     = 1;
        selA   = 2'b00;
        selB   = 2'b10;   // K
        alu_op = 4'b0010; // AND
      end

      // OR B,A
      7'b0010001: begin
        LB     = 1;
        selA   = 2'b01;   // B
        selB   = 2'b01;   // A
        alu_op = 4'b0011; // OR
      end

      // SHL A,A
      7'b0011100: begin
        LA     = 1;
        selA   = 2'b00;   // A
        alu_op = 4'b0111; // SHL
      end

      // SHR B,B
      7'b0100011: begin
        LB     = 1;
        selA   = 2'b01;   // B
        alu_op = 4'b1000; // SHR
      end

      // INC B => B = B + 1
      7'b0100100: begin
        LB     = 1;
        selA   = 2'b11;   // 1
        selB   = 2'b00;   // B
        alu_op = 4'b0000; // ADD
      end

      7'b0101000: begin
        LA      = 1;
        wbSel   = 1'b1;   // MEM -> WB
        mem_we  = 1'b0;   // lectura
        selData = 2'b00;  // addr = A (puedes cambiarlo)
      end

      7'b0101010: begin
        wbSel   = 1'b0;   // no WB
        mem_we  = 1'b1;   // escribir
        selData = 2'b01;  // addr = B (puedes cambiarlo)
      end

      default: begin
        // NOP
      end
    endcase
  end
endmodule
