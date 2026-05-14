`timescale 1ns / 1ps

module tb_vram_read_addr_gen;

    reg [9:0] pixel_x;
    reg [9:0] pixel_y;
    reg       video_on;

    wire [18:0] rd_addr;

    // Instancia del modulo
    vram_read_addr_gen uut (
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .video_on(video_on),
        .rd_addr(rd_addr)
    );

    initial begin
        $display("Tiempo\tvideo_on\tpixel_x\tpixel_y\trd_addr");
        $monitor("%0t\t%b\t\t%0d\t%0d\t%0d",
                 $time, video_on, pixel_x, pixel_y, rd_addr);

        // ==========================================
        // 1. Primer pixel de la pantalla
        // Direccion esperada: 0
        // ==========================================
        video_on = 1;
        pixel_x  = 0;
        pixel_y  = 0;
        #10;

        // ==========================================
        // 2. Segundo pixel de la primera fila
        // Direccion esperada: 1
        // ==========================================
        pixel_x = 1;
        pixel_y = 0;
        #10;

        // ==========================================
        // 3. Ultimo pixel de la primera fila
        // Direccion esperada: 639
        // ==========================================
        pixel_x = 639;
        pixel_y = 0;
        #10;

        // ==========================================
        // 4. Primer pixel de la segunda fila
        // Direccion esperada: 640
        // ==========================================
        pixel_x = 0;
        pixel_y = 1;
        #10;

        // ==========================================
        // 5. Un pixel cualquiera
        // Direccion esperada: (2 * 640) + 10 = 1290
        // ==========================================
        pixel_x = 10;
        pixel_y = 2;
        #10;

        // ==========================================
        // 6. Fuera de zona visible
        // Direccion esperada: 0
        // ==========================================
        video_on = 0;
        pixel_x  = 100;
        pixel_y  = 50;
        #10;

        $finish;
    end

endmodule