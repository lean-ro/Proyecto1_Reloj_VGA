`timescale 1ns / 1ps

module tb_top_clock_vga;

    reg clk100;
    reg rst_raw;

    reg btn_up_raw;
    reg btn_down_raw;

    reg sw_edit_raw;
    reg sw_hh_raw;
    reg sw_mm_raw;
    reg sw_ss_raw;

    wire vga_hsync;
    wire vga_vsync;
    wire [3:0] vga_r;
    wire [3:0] vga_g;
    wire [3:0] vga_b;

    integer errors;
    reg saw_hsync_low;

    // ==========================================
    // Instancia del TOP
    // ==========================================
    top_clock_vga uut (
        .clk100(clk100),
        .rst_raw(rst_raw),
        .btn_up_raw(btn_up_raw),
        .btn_down_raw(btn_down_raw),
        .sw_edit_raw(sw_edit_raw),
        .sw_hh_raw(sw_hh_raw),
        .sw_mm_raw(sw_mm_raw),
        .sw_ss_raw(sw_ss_raw),
        .vga_hsync(vga_hsync),
        .vga_vsync(vga_vsync),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b)
    );

    // ==========================================
    // Ajustes para simular más rápido
    // ==========================================
    defparam uut.u_btn_up_debounce.MAX_COUNT   = 4;
    defparam uut.u_btn_down_debounce.MAX_COUNT = 4;

    // ==========================================
    // Reloj principal 100 MHz
    // ==========================================
    always #5 clk100 = ~clk100;

    // ==========================================
    // Detectar si HSYNC baja al menos una vez
    // ==========================================
    always @(negedge vga_hsync) begin
        saw_hsync_low = 1'b1;
    end

    // ==========================================
    // Tarea: presionar botón UP
    // ==========================================
    task press_up;
        begin
            btn_up_raw = 1'b1;
            repeat (12) @(posedge clk100);
            btn_up_raw = 1'b0;
            repeat (12) @(posedge clk100);
        end
    endtask

    // ==========================================
    // Tarea: presionar botón DOWN
    // ==========================================
    task press_down;
        begin
            btn_down_raw = 1'b1;
            repeat (12) @(posedge clk100);
            btn_down_raw = 1'b0;
            repeat (12) @(posedge clk100);
        end
    endtask

    initial begin
        clk100       = 1'b0;
        rst_raw      = 1'b1;

        btn_up_raw   = 1'b0;
        btn_down_raw = 1'b0;

        sw_edit_raw  = 1'b0;
        sw_hh_raw    = 1'b0;
        sw_mm_raw    = 1'b0;
        sw_ss_raw    = 1'b0;

        errors       = 0;
        saw_hsync_low = 1'b0;

        // ==========================================
        // Reset inicial
        // ==========================================
        #20;
        rst_raw = 1'b0;

        // ==========================================
        // Esperar a que arranque el primer dibujado
        // ==========================================
        wait (uut.img_busy == 1'b1);
        $display("OK: image_generator arranco despues del reset");

        // Esperar a que termine el primer frame
        wait (uut.img_frame_done == 1'b1);
        #1;
        $display("OK: primer frame completado");

        // ==========================================
        // Entrar en modo edición de horas
        // ==========================================
        sw_edit_raw = 1'b1;
        sw_hh_raw   = 1'b1;
        repeat (6) @(posedge clk100);

        press_up();

        if (uut.hh !== 6'd1) begin
            $display("ERROR: hh esperado=1 obtenido=%0d", uut.hh);
            errors = errors + 1;
        end else begin
            $display("OK: hh incrementado a %0d", uut.hh);
        end

        // ==========================================
        // Cambiar a edición de minutos
        // ==========================================
        sw_hh_raw = 1'b0;
        sw_mm_raw = 1'b1;
        repeat (6) @(posedge clk100);

        press_up();
        press_up();

        if (uut.mm !== 6'd2) begin
            $display("ERROR: mm esperado=2 obtenido=%0d", uut.mm);
            errors = errors + 1;
        end else begin
            $display("OK: mm incrementado a %0d", uut.mm);
        end

        // ==========================================
        // Cambiar a edición de segundos
        // ==========================================
        sw_mm_raw = 1'b0;
        sw_ss_raw = 1'b1;
        repeat (6) @(posedge clk100);

        press_down();

        if (uut.ss !== 6'd59) begin
            $display("ERROR: ss esperado=59 obtenido=%0d", uut.ss);
            errors = errors + 1;
        end else begin
            $display("OK: ss decrementado a %0d", uut.ss);
        end

        // ==========================================
        // Salir de modo edición
        // ==========================================
        sw_edit_raw = 1'b0;
        sw_hh_raw   = 1'b0;
        sw_mm_raw   = 1'b0;
        sw_ss_raw   = 1'b0;

        repeat (20) @(posedge clk100);

        // ==========================================
        // Esperar a que vuelva a completarse un frame
        // tras cambios en la hora
        // ==========================================
        wait (uut.img_busy == 1'b1);
        $display("OK: image_generator se reactivo despues de editar la hora");

        wait (uut.img_frame_done == 1'b1);
        #1;
        $display("OK: frame actualizado completado");

        // ==========================================
        // Verificar que HSYNC haya bajado al menos una vez
        // ==========================================
        if (!saw_hsync_low) begin
            $display("ERROR: HSYNC nunca bajo durante la simulacion");
            errors = errors + 1;
        end else begin
            $display("OK: HSYNC bajo al menos una vez");
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