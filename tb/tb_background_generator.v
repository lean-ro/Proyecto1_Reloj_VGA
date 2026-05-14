`timescale 1ns / 1ps

module tb_background_generator;

    reg  [9:0]  pixel_x;
    reg  [9:0]  pixel_y;
    wire [11:0] bg_color;

    reg  [15:0] expected_addr;
    wire [11:0] expected_color;

    integer errors;

    // Modulo bajo prueba
    background_generator uut (
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .bg_color(bg_color)
    );

    // ROM de referencia para comparar colores
    background_rom ref_rom (
        .addr(expected_addr),
        .bg_data(expected_color)
    );

    task check_dark_margin;
        input [9:0] test_x;
        input [9:0] test_y;
        begin
            pixel_x = test_x;
            pixel_y = test_y;
            #1;

            if (bg_color !== 12'h000) begin
                $display("ERROR: margen oscuro x=%0d y=%0d esperado=000 obtenido=%03h",
                         test_x, test_y, bg_color);
                errors = errors + 1;
            end else begin
                $display("OK: margen oscuro x=%0d y=%0d valor=%03h",
                         test_x, test_y, bg_color);
            end
        end
    endtask

    task check_image_pixel;
        input [9:0] test_x;
        input [9:0] test_y;
        input [15:0] addr_ref;
        begin
            pixel_x       = test_x;
            pixel_y       = test_y;
            expected_addr = addr_ref;
            #1;

            if (bg_color !== expected_color) begin
                $display("ERROR: imagen x=%0d y=%0d addr=%0d esperado=%03h obtenido=%03h",
                         test_x, test_y, addr_ref, expected_color, bg_color);
                errors = errors + 1;
            end else begin
                $display("OK: imagen x=%0d y=%0d addr=%0d valor=%03h",
                         test_x, test_y, addr_ref, bg_color);
            end
        end
    endtask

    initial begin
        pixel_x       = 0;
        pixel_y       = 0;
        expected_addr = 0;
        errors        = 0;

        // ==========================================
        // 1. Margen oscuro izquierdo
        // ==========================================
        check_dark_margin(10'd0,   10'd0);
        check_dark_margin(10'd79,  10'd100);

        // ==========================================
        // 2. Primer pixel visible de la imagen
        // VGA (80,0) -> imagen (0,0) -> addr 0
        // ==========================================
        check_image_pixel(10'd80, 10'd0, 16'd0);

        // ==========================================
        // 3. Escalado x2 horizontal
        // VGA (81,0) -> imagen (0,0) -> addr 0
        // ==========================================
        check_image_pixel(10'd81, 10'd0, 16'd0);

        // VGA (82,0) -> imagen (1,0) -> addr 1
        check_image_pixel(10'd82, 10'd0, 16'd1);

        // ==========================================
        // 4. Escalado x2 vertical
        // VGA (80,1) -> imagen (0,0) -> addr 0
        // VGA (80,2) -> imagen (0,1) -> addr 240
        // ==========================================
        check_image_pixel(10'd80, 10'd1, 16'd0);
        check_image_pixel(10'd80, 10'd2, 16'd240);

        // ==========================================
        // 5. Ultimo pixel de la imagen mostrada
        // VGA (559,479) -> imagen (239,239) -> addr 57599
        // ==========================================
        check_image_pixel(10'd559, 10'd479, 16'd57599);

        // ==========================================
        // 6. Margen oscuro derecho
        // ==========================================
        check_dark_margin(10'd560, 10'd200);
        check_dark_margin(10'd639, 10'd479);

        // Resultado final
        if (errors == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED - errores = %0d", errors);

        $finish;
    end

endmodule