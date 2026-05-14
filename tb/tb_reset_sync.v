`timescale 1ns / 1ps

module tb_reset_sync;

    // Señales del testbench
    reg clk;
    reg rst_raw;
    wire rst_sync;

    // Instancia del módulo a probar
    reset_sync uut (
        .clk(clk),
        .rst_raw(rst_raw),
        .rst_sync(rst_sync)
    );

    // Generación del reloj
    // Periodo = 10 ns
    always #5 clk = ~clk;

    initial begin
        // Valores iniciales
        clk = 0;
        rst_raw = 0;

        // Mostrar señales en consola
        $display("Tiempo\tclk\trst_raw\trst_sync");
        $monitor("%0t\t%b\t%b\t%b", $time, clk, rst_raw, rst_sync);

        // =========================
        // 1. Activar reset
        // rst_sync debe subir de inmediato
        // =========================
        #12;
        rst_raw = 1;

        // Mantener reset activo un rato
        #20;

        // =========================
        // 2. Desactivar reset
        // rst_sync no debe bajar de inmediato
        // debe bajar después de 2 flancos positivos
        // =========================
        rst_raw = 0;

        #40;

        // =========================
        // 3. Activar reset otra vez
        // =========================
        #7;
        rst_raw = 1;

        #15;

        // =========================
        // 4. Desactivar reset otra vez
        // =========================
        rst_raw = 0;

        #40;

        // Fin de simulación
        $finish;
    end

endmodule