// Proyecto para FPGA Go Board - Computador de 8-bits optimizado
// Contador de 15 a 0 mostrado en LEDs (binario)
// Para flashear y probar el computador

module main (
    // Entrada de reloj
    input i_clk,
    
    // Botones de entrada (4 botones en la Go Board)
    input i_button_1,
    input i_button_2,
    input i_button_3,
    input i_button_4,
    
    // LEDs de salida (4 LEDs en la Go Board)
    output o_led_1,
    output o_led_2,
    output o_led_3,
    output o_led_4
);

    // Divisor de reloj para hacer visible el conteo
    // Reloj de 25MHz dividido por 2^23 ≈ 3Hz
    reg [23:0] clk_divider;
    wire slow_clk;
    
    always @(posedge i_clk) begin
        clk_divider <= clk_divider + 1;
    end
    
    assign slow_clk = clk_divider[23]; // Reloj lento para ver el conteo
    
    // Instanciar el computador de 8-bits optimizado
    wire [7:0] computer_output;
    
    computer mi_computador (
        .clk(slow_clk),  // Usar reloj lento
        .alu_out_bus(computer_output)
    );
    
    // Lógica para controlar los LEDs:
    // Si algún botón está presionado, ese LED se enciende (para pruebas)
    // Si no hay botones presionados, mostrar la salida del computador en binario
    
    wire any_button_pressed = ~(i_button_1 & i_button_2 & i_button_3 & i_button_4);
    
    // Mapeo de botones a LEDs (para pruebas)
    wire button_led_1 = ~i_button_1;
    wire button_led_2 = ~i_button_2;
    wire button_led_3 = ~i_button_3;
    wire button_led_4 = ~i_button_4;
    
    // Salida del computador en los 4 bits menos significativos
    wire computer_led_1 = computer_output[0];
    wire computer_led_2 = computer_output[1];
    wire computer_led_3 = computer_output[2];
    wire computer_led_4 = computer_output[3];
    
    // Multiplexar entre control manual (botones) y automático (computador)
    assign o_led_1 = any_button_pressed ? button_led_1 : computer_led_1;
    assign o_led_2 = any_button_pressed ? button_led_2 : computer_led_2;
    assign o_led_3 = any_button_pressed ? button_led_3 : computer_led_3;
    assign o_led_4 = any_button_pressed ? button_led_4 : computer_led_4;

endmodule