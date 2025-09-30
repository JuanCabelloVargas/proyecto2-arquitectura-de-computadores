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

    LA     = 1'b0;
    LB     = 1'b0;
    selA   = 2'b10;
    selB   = 2'b00;
    alu_op = 4'b0000;

    case (opcode)
      // MOV A,B => A = B (A = 0 + B)
      7'b0000000: begin
        LA     = 1'b1;
        selA   = 2'b10; // 0
        selB   = 2'b00; // B
        alu_op = 4'b0000; // ALU hace ADD
      end
      
      // MOV B,A => B = A (B = 0 + A)
      7'b0000001: begin
        LB     = 1'b1;
        selA   = 2'b10; // 0
        selB   = 2'b01; // A
        alu_op = 4'b0000; // ALU hace ADD
      end

      // MOV A,K => A = K (A = 0 + K)
      7'b0000010: begin
        LA     = 1'b1;
        selA   = 2'b10; // 0
        selB   = 2'b10; // K
        alu_op = 4'b0000; // ALU hace ADD
      end

      // MOV B,K => B = K (B = 0 + K)
      7'b0000011: begin
        LB     = 1'b1;
        selA   = 2'b10; // 0
        selB   = 2'b10; // K
        alu_op = 4'b0000; // ALU hace ADD
      end

      // ADD A,B => A = A + B
      7'b0000100: begin
        LA     = 1'b1;
        selA   = 2'b00; // A
        selB   = 2'b00; // B
        alu_op = 4'b0000; // ALU hace ADD
      end

      // ADD A,K => A = A + K
      7'b0000110: begin
        LA     = 1'b1;
        selA   = 2'b00; // A
        selB   = 2'b10; // K
        alu_op = 4'b0000; // ALU hace ADD
      end

      // ADD B,K => B = B + K
      7'b0000111: begin
        LB     = 1'b1;
        selA   = 2'b01; // B
        selB   = 2'b10; // K
        alu_op = 4'b0000; // ALU hace ADD
      end

      // SUB A,B => A = A - B
      7'b0001000: begin
        LA     = 1'b1;
        selA   = 2'b00; // A
        selB   = 2'b00; // B
        alu_op = 4'b0001; // ALU hace SUB
      end

      // SUB B,A => B = B - A
      7'b0001001: begin
        LB     = 1'b1;
        selA   = 2'b01; // B
        selB   = 2'b01; // A
        alu_op = 4'b0001; // ALU hace SUB
      end

      // SUB A,K => A = A - K
      7'b0001010: begin
        LA     = 1'b1;
        selA   = 2'b00; // A
        selB   = 2'b10; // K
        alu_op = 4'b0001; // ALU hace SUB
      end

      // SUB B,K => B = B - K
      7'b0001011: begin
        LB     = 1'b1;
        selA   = 2'b01; // B
        selB   = 2'b10; // K
        alu_op = 4'b0001; // ALU hace SUB
      end

      // AND A,B => A = A and B
      7'b0001100: begin
        LA     = 1'b1;
        selA   = 2'b00; // A
        selB   = 2'b00; // B
        alu_op = 4'b0010; // ALU hace AND
      end

      // AND B,A => B = B and A
      7'b0001101: begin
        LB     = 1'b1;
        selA   = 2'b01; // B
        selB   = 2'b01; // A
        alu_op = 4'b0010; // ALU hace AND
      end

      // AND A,K => A = A and K
      7'b0001110: begin
        LA     = 1'b1;
        selA   = 2'b00; // A
        selB   = 2'b10; // K
        alu_op = 4'b0010; // ALU hace AND
      end

      // AND B,K => B = B and K
      7'b0001111: begin
        LB     = 1'b1;
        selA   = 2'b01; // B
        selB   = 2'b10; // K
        alu_op = 4'b0010; // ALU hace AND
      end

      // OR A,B => A = A or B
      7'b0010000: begin
        LA     = 1'b1;
        selA   = 2'b00; // A
        selB   = 2'b00; // B
        alu_op = 4'b0011; // ALU hace OR
      end

      // OR B,A => B = B or A
      7'b0010001: begin
        LB     = 1'b1;
        selA   = 2'b01; // B
        selB   = 2'b01; // A
        alu_op = 4'b0011; // ALU hace OR
      end

      // OR A,K => A = A or K
      7'b0010010: begin
        LA     = 1'b1;
        selA   = 2'b00; // A
        selB   = 2'b10; // K
        alu_op = 4'b0011; // ALU hace OR
      end

      // OR B,K => B = B or K
      7'b0010011: begin
        LB     = 1'b1;
        selA   = 2'b01; // B
        selB   = 2'b10; // K
        alu_op = 4'b0011; // ALU hace OR
      end

      // NOT A,A => A = ~A
      7'b0010100: begin
        LA     = 1'b1;
        selA   = 2'b00; // A
        alu_op = 4'b0101; // ALU hace NOT
      end

      // NOT A,B => A = ~B
      7'b0010101: begin
        LA     = 1'b1;
        selA   = 2'b01; // B
        alu_op = 4'b0101; // ALU hace NOT
      end

      // NOT B,A => B = ~A
      7'b0010110: begin
        LB     = 1'b1;
        selA   = 2'b00; // A
        selB   = 2'b01; // A mapeado a b, o sea ~A
        alu_op = 4'b0110; // ALU hace NOT B
      end
      
      // NOT B,B => B = ~B
      7'b0010111: begin
        LB     = 1'b1;
        selA   = 2'b01; // B
        alu_op = 4'b0110; // ALU hace NOT B
      end

      // XOR A,B => A = A xor B
      7'b0011000: begin
        LA     = 1'b1;
        selA   = 2'b00; // A
        selB   = 2'b00; // B
        alu_op = 4'b0100; // ALU hace XOR
      end

      // XOR B,A => B = B xor A
      7'b0011001: begin
        LB     = 1'b1;
        selA   = 2'b01; // B
        selB   = 2'b01; // A
        alu_op = 4'b0100; // ALU hace XOR
      end

      // XOR A,K => A = A xor K
      7'b0011010: begin
        LA     = 1'b1;
        selA   = 2'b00; // A
        selB   = 2'b10; // K
        alu_op = 4'b0100; // ALU hace XOR
      end

      // XOR B,K => B = B xor K
      7'b0011011: begin
        LB     = 1'b1;
        selA   = 2'b01; // B
        selB   = 2'b10; // K
        alu_op = 4'b0100; // ALU hace XOR
      end

      // SHL A,A => A = shift left A
      7'b0011100: begin
        LA     = 1'b1;
        selA   = 2'b00; // A
        alu_op = 4'b0111; // ALU hace SHL
      end

      // SHL A,B => A = shift left B
      7'b0011101: begin
        LA     = 1'b1;
        selA   = 2'b01; // B
        alu_op = 4'b0111; // ALU hace SHL
      end

      // SHL B,A => B = shift left A
      7'b0011110: begin
        LB     = 1'b1;
        selA   = 2'b00; // A
        alu_op = 4'b0111; // ALU hace SHL
      end

      // SHL B,B => B = shift left B
      7'b0011111: begin
        LB     = 1'b1;
        selA   = 2'b01; // B
        alu_op = 4'b0111; // ALU hace SHL
      end

      // SHR A,A => A = shift right A
      7'b0100000: begin
        LA     = 1'b1;
        selA   = 2'b00; // A
        alu_op = 4'b1000; // ALU hace SHR
      end

      // SHR A,B => A = shift right B
      7'b0100001: begin
        LA     = 1'b1;
        selA   = 2'b01; // B
        alu_op = 4'b1000; // ALU hace SHR
      end

      // SHR B,A => B = shift right A
      7'b0100010: begin
        LB     = 1'b1;
        selA   = 2'b00; // A
        alu_op = 4'b1000; // ALU hace SHR
      end

      // SHR B,B => B = shift right B
      7'b0100011: begin
        LB     = 1'b1;
        selA   = 2'b01; // B
        alu_op = 4'b1000; // ALU hace SHR
      end

      // INC B => B = B + 1
      7'b0100100: begin
        LB     = 1'b1;
        selA   = 2'b11; // 1
        selB   = 2'b00; // B
        alu_op = 4'b0000; // ALU hace SUMA
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
