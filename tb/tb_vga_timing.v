`timescale 1ns / 1ps

module tb_vga_timing;

    reg clk;
    reg rst;

    wire hsync;
    wire vsync;
    wire video_on;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;

    vga_timing uut (
        .clk(clk),
        .rst(rst),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );

    // Reloj de simulacion
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        $display("Tiempo\tclk\trst\thsync\tvsync\tvideo_on\tpixel_x\tpixel_y");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b\t\t%0d\t%0d",
                 $time, clk, rst, hsync, vsync, video_on, pixel_x, pixel_y);

        // Reset inicial
        #20;
        rst = 0;

        // Dejar correr un rato
        #10000;

        $finish;
    end

endmodule