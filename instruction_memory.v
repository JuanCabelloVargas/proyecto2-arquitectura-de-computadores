module instruction_memory (
    address,
    out
);
  input [7:0] address;
  output [15:0] out;

  wire [7:0]   address;
  wire [15:0]   out;

  reg [15:0]    mem [0:255];

  assign out = mem[address];

  initial begin  // lee el archivo im.dat que nos entregaran
  $readmemb("im.dat",mem);
endmodule
