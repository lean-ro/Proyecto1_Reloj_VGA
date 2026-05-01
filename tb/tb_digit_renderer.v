`timescale 1ns / 1ps

module tb_digit_renderer;

    reg [5:0] hh;
    reg [5:0] mm;
    reg [5:0] ss;
    reg [9:0] pixel_x;
    reg [9:0] pixel_y;
    wire      pixel_on;

    // Instancia del modulo
    digit_renderer uut (
        .hh(hh),
        .mm(mm),
        .ss(ss),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .pixel_on(pixel_on)
    );

    initial begin
        hh = 6'd12;
        mm = 6'd34;
        ss = 6'd56;

        $display("Tiempo\thh\tmm\tss\tpixel_x\tpixel_y\tpixel_on");
        $monitor("%0t\t%0d\t%0d\t%0d\t%0d\t%0d\t%b",
                 $time, hh, mm, ss, pixel_x, pixel_y, pixel_on);

        // ==========================================
        // 1. Fuera del reloj
        // esperado: 0
        // ==========================================
        pixel_x = 10;
        pixel_y = 10;
        #10;

        // ==========================================
        // 2. Primer caracter = '1'
        // fila 0 del '1' = 00011000
        // columna 3 debe estar encendida
        // ==========================================
        pixel_x = 164 + (3 * 4);
        pixel_y = 100 + (0 * 4);
        #10;

        // ==========================================
        // 3. Primer caracter = '1'
        // columna 0 debe estar apagada
        // ==========================================
        pixel_x = 164 + (0 * 4);
        pixel_y = 100 + (0 * 4);
        #10;

        // ==========================================
        // 4. Segundo caracter = '2'
        // fila 0 del '2' = 00111100
        // columna 2 debe estar encendida
        // ==========================================
        pixel_x = 204 + (2 * 4);
        pixel_y = 100 + (0 * 4);
        #10;

        // ==========================================
        // 5. Primer ':'
        // fila 1 = 00011000
        // columna 3 debe estar encendida
        // ==========================================
        pixel_x = 244 + (3 * 4);
        pixel_y = 100 + (1 * 4);
        #10;

        // ==========================================
        // 6. Espacio entre caracteres
        // esperado: 0
        // ==========================================
        pixel_x = 198;
        pixel_y = 100;
        #10;

        // ==========================================
        // 7. Ultimo caracter = '6'
        // fila 0 del '6' = 00111100
        // columna 2 debe estar encendida
        // ==========================================
        pixel_x = 444 + (2 * 4);
        pixel_y = 100 + (0 * 4);
        #10;

        $finish;
    end

endmodule