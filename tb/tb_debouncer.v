`timescale 1ns / 1ps

module tb_debouncer;

    // Señales del testbench
    reg clk;
    reg rst;
    reg noisy_in;
    wire clean_out;

    // Instancia del módulo a probar
    // Usamos un MAX_COUNT pequeño para que la simulación sea rápida
    debouncer #(
        .MAX_COUNT(5)
    ) uut (
        .clk(clk),
        .rst(rst),
        .noisy_in(noisy_in),
        .clean_out(clean_out)
    );

    // Generación del reloj
    // Periodo = 10 ns
    always #5 clk = ~clk;

    initial begin
        // Valores iniciales
        clk = 0;
        rst = 1;
        noisy_in = 0;

        // Mostrar señales en consola
        $display("Tiempo\tclk\trst\tnoisy_in\tclean_out");
        $monitor("%0t\t%b\t%b\t%b\t\t%b", $time, clk, rst, noisy_in, clean_out);

        // =========================
        // 1. Reset
        // =========================
        #20;
        rst = 0;

        // =========================
        // 2. Rebote al subir
        // =========================
        #10 noisy_in = 1;
        #10 noisy_in = 0;
        #10 noisy_in = 1;
        #10 noisy_in = 0;
        #10 noisy_in = 1;

        // Ahora dejamos la entrada estable en 1
        // para que el debouncer la acepte
        #100;

        // =========================
        // 3. Rebote al bajar
        // =========================
        #10 noisy_in = 0;
        #10 noisy_in = 1;
        #10 noisy_in = 0;
        #10 noisy_in = 1;
        #10 noisy_in = 0;

        // Dejamos estable en 0
        #100;

        // Fin de simulación
        $finish;
    end

endmodule