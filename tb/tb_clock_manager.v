`timescale 1ns / 1ps

module tb_clock_manager;

    reg clk_in;
    reg rst;

    wire clk_sys;
    wire clk_pix;

    // Instancia del modulo
    clock_manager uut (
        .clk_in(clk_in),
        .rst(rst),
        .clk_sys(clk_sys),
        .clk_pix(clk_pix)
    );

    // Reloj base de 100 MHz
    // Periodo = 10 ns
    always #5 clk_in = ~clk_in;

    initial begin
        clk_in = 0;
        rst    = 1;

        $display("Tiempo\tclk_in\trst\tclk_sys\tclk_pix");
        $monitor("%0t\t%b\t%b\t%b\t%b",
                 $time, clk_in, rst, clk_sys, clk_pix);

        // Reset inicial
        #20;
        rst = 0;

        // Dejar correr un rato
        #100;

        $finish;
    end

endmodule