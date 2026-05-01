`timescale 1ns / 1ps

module tb_vram_writer_fsm;

    reg clk;
    reg rst;
    reg start;

    reg  [11:0] bg_color;
    reg         clock_fill_on;
    reg         clock_border_on;

    wire [9:0]  pixel_x;
    wire [9:0]  pixel_y;
    wire        wr_en;
    wire [18:0] wr_addr;
    wire [11:0] wr_data;
    wire        busy;
    wire        frame_done;

    integer errors;

    // Instancia del modulo
    vram_writer_fsm uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .bg_color(bg_color),
        .clock_fill_on(clock_fill_on),
        .clock_border_on(clock_border_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .busy(busy),
        .frame_done(frame_done)
    );

    // Reloj de simulacion
    always #5 clk = ~clk;

    // ==========================================
    // Generacion simple de entradas visuales
    // ==========================================
    always @(*) begin
        // Fondo por defecto
        bg_color = 12'h123;

        // Casos de prueba del reloj
        // (1,0) -> solo borde
        // (2,0) -> solo relleno
        // (3,0) -> relleno y borde al mismo tiempo
        clock_fill_on   = 1'b0;
        clock_border_on = 1'b0;

        if (pixel_x == 10'd1 && pixel_y == 10'd0)
            clock_border_on = 1'b1;

        if (pixel_x == 10'd2 && pixel_y == 10'd0)
            clock_fill_on = 1'b1;

        if (pixel_x == 10'd3 && pixel_y == 10'd0) begin
            clock_fill_on   = 1'b1;
            clock_border_on = 1'b1;
        end
    end

    // ==========================================
    // Tarea para verificar un pixel especifico
    // ==========================================
    task check_pixel;
        input [9:0]  exp_x;
        input [9:0]  exp_y;
        input [18:0] exp_addr;
        input [11:0] exp_data;
        input [255:0] message;
        begin
            wait (pixel_x == exp_x && pixel_y == exp_y && wr_en == 1'b1);
            #1;

            if (wr_addr !== exp_addr) begin
                $display("ERROR: %s -> wr_addr esperado=%0d obtenido=%0d",
                         message, exp_addr, wr_addr);
                errors = errors + 1;
            end
            else if (wr_data !== exp_data) begin
                $display("ERROR: %s -> wr_data esperado=%03h obtenido=%03h",
                         message, exp_data, wr_data);
                errors = errors + 1;
            end
            else begin
                $display("OK: %s -> addr=%0d data=%03h",
                         message, wr_addr, wr_data);
            end
        end
    endtask

    initial begin
        clk             = 1'b0;
        rst             = 1'b1;
        start           = 1'b0;
        errors          = 0;

        // ==========================================
        // Reset inicial
        // ==========================================
        #20;
        rst = 1'b0;

        // ==========================================
        // Pulso de start
        // ==========================================
        #10;
        start = 1'b1;
        #10;
        start = 1'b0;

        // ==========================================
        // Verificar primeros pixeles
        // ==========================================
        check_pixel(10'd0, 10'd0, 19'd0,   12'h123, "pixel (0,0) fondo");
        check_pixel(10'd1, 10'd0, 19'd1,   12'h000, "pixel (1,0) borde");
        check_pixel(10'd2, 10'd0, 19'd2,   12'hFFF, "pixel (2,0) relleno");
        check_pixel(10'd3, 10'd0, 19'd3,   12'hFFF, "pixel (3,0) relleno y borde");
        check_pixel(10'd4, 10'd0, 19'd4,   12'h123, "pixel (4,0) fondo");
        check_pixel(10'd0, 10'd1, 19'd640, 12'h123, "pixel (0,1) siguiente fila");

        // ==========================================
        // Esperar a que termine el frame completo
        // ==========================================
        wait (frame_done == 1'b1);
        #1;

        if (busy !== 1'b0) begin
            $display("ERROR: al finalizar el frame, busy deberia ser 0");
            errors = errors + 1;
        end
        else begin
            $display("OK: frame_done activado y busy en 0");
        end

        // ==========================================
        // Resultado final
        // ==========================================
        if (errors == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED - errores = %0d", errors);

        $finish;
    end

endmodule