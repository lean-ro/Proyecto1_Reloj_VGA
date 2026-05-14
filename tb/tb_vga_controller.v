`timescale 1ns / 1ps

module tb_vga_controller;

    reg clk;
    reg rst;
    reg [11:0] pixel_data;

    wire [18:0] rd_addr;
    wire hsync_out;
    wire vsync_out;
    wire [11:0] rgb_out;

    // Instancia del modulo
    vga_controller uut (
        .clk(clk),
        .rst(rst),
        .pixel_data(pixel_data),
        .rd_addr(rd_addr),
        .hsync_out(hsync_out),
        .vsync_out(vsync_out),
        .rgb_out(rgb_out)
    );

    // Reloj de simulacion
    always #5 clk = ~clk;

    // Emulacion simple de una VRAM con lectura sincronica
    always @(posedge clk) begin
        pixel_data <= rd_addr[11:0];
    end

    initial begin
        clk = 0;
        rst = 1;
        pixel_data = 12'h000;

        $display("Tiempo\tclk\trst\trd_addr\thsync\tvsync\trgb_out");
        $monitor("%0t\t%b\t%b\t%0d\t%b\t%b\t%0h",
                 $time, clk, rst, rd_addr, hsync_out, vsync_out, rgb_out);

        // Reset inicial
        #20;
        rst = 0;

        // Dejar correr suficiente tiempo
        #20000;

        $finish;
    end

endmodule