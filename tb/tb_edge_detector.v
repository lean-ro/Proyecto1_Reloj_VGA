`timescale 1ns / 1ps

module tb_edge_detector;

    // Señales del testbench
    reg clk;
    reg rst;
    reg signal_in;
    wire pulse_out;

    // Instancia del módulo a probar
    edge_detector uut (
        .clk(clk),
        .rst(rst),
        .signal_in(signal_in),
        .pulse_out(pulse_out)
    );

    // Generación del reloj
    // Periodo = 10 ns
    always #5 clk = ~clk;

    initial begin
        // Valores iniciales
        clk = 0;
        rst = 1;
        signal_in = 0;

        // Mensajes en consola
        $display("Tiempo\tclk\trst\tsignal_in\tpulse_out");
        $monitor("%0t\t%b\t%b\t%b\t\t%b", $time, clk, rst, signal_in, pulse_out);

        // =========================
        // 1. Reset
        // =========================
        #20;
        rst = 0;

        // =========================
        // 2. Primer flanco ascendente
        // Aquí debería aparecer un pulso de 1 ciclo
        // =========================
        #10;
        signal_in = 1;

        // Mantener la señal en 1
        // No deberían salir más pulsos
        #30;

        // =========================
        // 3. Bajar la señal a 0
        // Aquí NO debe salir pulso
        // =========================
        signal_in = 0;
        #20;

        // =========================
        // 4. Segundo flanco ascendente
        // Debe volver a salir un pulso de 1 ciclo
        // =========================
        signal_in = 1;
        #30;

        // =========================
        // 5. Fin de simulación
        // =========================
        $finish;
    end

endmodule