`timescale 1ns / 1ps

module tb_font_rom;

    reg  [3:0] char_code;
    reg  [2:0] row;
    reg  [2:0] col;
    wire       pixel_on;

    // Instancia del modulo
    font_rom uut (
        .char_code(char_code),
        .row(row),
        .col(col),
        .pixel_on(pixel_on)
    );

    initial begin
        $display("Tiempo\tchar_code\trow\tcol\tpixel_on");
        $monitor("%0t\t%0d\t\t%0d\t%0d\t%b",
                 $time, char_code, row, col, pixel_on);

        // ==========================================
        // Pruebas con el digito 0
        // Fila 0 = 00111100
        // ==========================================
        char_code = 4'd0; row = 3'd0; col = 3'd0; #10; // esperado: 0
        char_code = 4'd0; row = 3'd0; col = 3'd2; #10; // esperado: 1
        char_code = 4'd0; row = 3'd0; col = 3'd5; #10; // esperado: 1
        char_code = 4'd0; row = 3'd0; col = 3'd7; #10; // esperado: 0

        // ==========================================
        // Pruebas con el digito 1
        // Fila 0 = 00011000
        // ==========================================
        char_code = 4'd1; row = 3'd0; col = 3'd3; #10; // esperado: 1
        char_code = 4'd1; row = 3'd0; col = 3'd4; #10; // esperado: 1
        char_code = 4'd1; row = 3'd0; col = 3'd0; #10; // esperado: 0

        // ==========================================
        // Pruebas con el digito 5
        // Fila 0 = 01111110
        // ==========================================
        char_code = 4'd5; row = 3'd0; col = 3'd0; #10; // esperado: 0
        char_code = 4'd5; row = 3'd0; col = 3'd1; #10; // esperado: 1
        char_code = 4'd5; row = 3'd0; col = 3'd6; #10; // esperado: 1
        char_code = 4'd5; row = 3'd0; col = 3'd7; #10; // esperado: 0

        // ==========================================
        // Pruebas con el caracter :
        // Fila 1 = 00011000
        // ==========================================
        char_code = 4'd10; row = 3'd1; col = 3'd3; #10; // esperado: 1
        char_code = 4'd10; row = 3'd1; col = 3'd4; #10; // esperado: 1
        char_code = 4'd10; row = 3'd1; col = 3'd0; #10; // esperado: 0

        // ==========================================
        // Fila vacia del :
        // Fila 0 = 00000000
        // ==========================================
        char_code = 4'd10; row = 3'd0; col = 3'd3; #10; // esperado: 0

        // ==========================================
        // Caracter no definido
        // esperado: 0
        // ==========================================
        char_code = 4'd15; row = 3'd2; col = 3'd4; #10; // esperado: 0

        $finish;
    end

endmodule