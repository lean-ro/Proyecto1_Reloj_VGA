`timescale 1ns / 1ps

module tb_time_base;

    reg clk;
    reg rst;
    wire tick_1Hz_en;

    // Instancia del módulo
    // Usamos un valor pequeño para simular rápido
    time_base #(
        .MAX_COUNT(5)
    ) uut (
        .clk(clk),
        .rst(rst),
        .tick_1Hz_en(tick_1Hz_en)
    );

    // Reloj de 10 ns de periodo
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        $display("Tiempo\tclk\trst\ttick_1Hz_en");
        $monitor("%0t\t%b\t%b\t%b", $time, clk, rst, tick_1Hz_en);

        // Reset inicial
        #20;
        rst = 0;

        // Dejar correr la simulación
        #120;

        $finish;
    end

endmodule