`timescale 1ns / 1ps

module tb_clock_control;

    reg clk;
    reg rst;
    reg tick_1Hz_en;

    reg sw_edit;
    reg sw_hh;
    reg sw_mm;
    reg sw_ss;

    reg btn_up;
    reg btn_down;

    wire [5:0] hh;
    wire [5:0] mm;
    wire [5:0] ss;

    // Instancia del modulo
    clock_control uut (
        .clk(clk),
        .rst(rst),
        .tick_1Hz_en(tick_1Hz_en),
        .sw_edit(sw_edit),
        .sw_hh(sw_hh),
        .sw_mm(sw_mm),
        .sw_ss(sw_ss),
        .btn_up(btn_up),
        .btn_down(btn_down),
        .hh(hh),
        .mm(mm),
        .ss(ss)
    );

    // Reloj de 10 ns
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        tick_1Hz_en = 0;

        sw_edit = 0;
        sw_hh = 0;
        sw_mm = 0;
        sw_ss = 0;

        btn_up = 0;
        btn_down = 0;

        $display("Tiempo\tclk\trst\ttick\tedit\thh_sel\tmm_sel\tss_sel\tup\tdown\thh\tmm\tss");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%0d\t%0d\t%0d",
                 $time, clk, rst, tick_1Hz_en, sw_edit, sw_hh, sw_mm, sw_ss,
                 btn_up, btn_down, hh, mm, ss);

        // ==========================================
        // 1. Reset inicial
        // ==========================================
        #20;
        rst = 0;

        // ==========================================
        // 2. Modo normal: avanzar 3 segundos
        // ==========================================
        #10 tick_1Hz_en = 1;
        #10 tick_1Hz_en = 0;

        #20 tick_1Hz_en = 1;
        #10 tick_1Hz_en = 0;

        #20 tick_1Hz_en = 1;
        #10 tick_1Hz_en = 0;

        // ==========================================
        // 3. Entrar en modo edicion y subir horas
        // ==========================================
        #20;
        sw_edit = 1;
        sw_hh = 1;

        #10 btn_up = 1;
        #10 btn_up = 0;

        // ==========================================
        // 4. Editar minutos
        // ==========================================
        #20;
        sw_hh = 0;
        sw_mm = 1;

        #10 btn_up = 1;
        #10 btn_up = 0;

        #10 btn_up = 1;
        #10 btn_up = 0;

        // ==========================================
        // 5. Editar segundos y bajar
        // ==========================================
        #20;
        sw_mm = 0;
        sw_ss = 1;

        #10 btn_down = 1;
        #10 btn_down = 0;

        // ==========================================
        // 6. Seleccion invalida: hh y mm al mismo tiempo
        // No debe hacer nada
        // ==========================================
        #20;
        sw_hh = 1;
        sw_mm = 1;
        sw_ss = 0;

        #10 btn_up = 1;
        #10 btn_up = 0;

        // ==========================================
        // 7. Salir de modo edicion y avanzar 2 segundos
        // ==========================================
        #20;
        sw_edit = 0;
        sw_hh = 0;
        sw_mm = 0;
        sw_ss = 0;

        #10 tick_1Hz_en = 1;
        #10 tick_1Hz_en = 0;

        #20 tick_1Hz_en = 1;
        #10 tick_1Hz_en = 0;

        #30;
        $finish;
    end

endmodule