`timescale 1ns / 1ps

module tb_sync_2ff;

    // Señales del testbench
    reg clk;
    reg rst;
    reg async_in;
    wire sync_out;

    // Instancia del módulo a probar
    sync_2ff uut (
        .clk(clk),
        .rst(rst),
        .async_in(async_in),
        .sync_out(sync_out)
    );

    // Generación del reloj
    // Periodo = 10 ns
    always #5 clk = ~clk;

    initial begin
        // Valores iniciales
        clk = 0;
        rst = 1;
        async_in = 0;

        // Mostrar señales en consola
        $display("Tiempo\tclk\trst\tasync_in\tsync_out");
        $monitor("%0t\t%b\t%b\t%b\t\t%b", $time, clk, rst, async_in, sync_out);

        // =========================
        // 1. Reset
        // =========================
        #20;
        rst = 0;

        // =========================
        // 2. Cambiar la entrada a 1
        // La salida no debe cambiar de inmediato
        // Debe tardar dos flancos positivos
        // =========================
        #7;
        async_in = 1;

        #40;

        // =========================
        // 3. Cambiar la entrada a 0
        // De nuevo, la salida debe tardar
        // =========================
        #7;
        async_in = 0;

        #40;

        // =========================
        // 4. Otro cambio a 1
        // =========================
        #3;
        async_in = 1;

        #40;

        // Fin de simulación
        $finish;
    end

endmodule