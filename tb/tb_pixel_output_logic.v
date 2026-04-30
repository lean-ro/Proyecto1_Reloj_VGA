`timescale 1ns / 1ps

module tb_pixel_output_logic;

    reg        hsync_in;
    reg        vsync_in;
    reg        video_on;
    reg [11:0] pixel_data;

    wire       hsync_out;
    wire       vsync_out;
    wire [11:0] rgb_out;

    // Instancia del modulo
    pixel_output_logic uut (
        .hsync_in(hsync_in),
        .vsync_in(vsync_in),
        .video_on(video_on),
        .pixel_data(pixel_data),
        .hsync_out(hsync_out),
        .vsync_out(vsync_out),
        .rgb_out(rgb_out)
    );

    initial begin
        $display("Tiempo\thsync_in\tvsync_in\tvideo_on\tpixel_data\thsync_out\tvsync_out\trgb_out");
        $monitor("%0t\t%b\t\t%b\t\t%b\t\t%0h\t\t%b\t\t%b\t\t%0h",
                 $time, hsync_in, vsync_in, video_on, pixel_data,
                 hsync_out, vsync_out, rgb_out);

        // ==========================================
        // 1. Zona visible con color
        // ==========================================
        hsync_in   = 1;
        vsync_in   = 1;
        video_on   = 1;
        pixel_data = 12'hA3F;
        #10;

        // ==========================================
        // 2. Zona visible con otro color
        // ==========================================
        pixel_data = 12'h27C;
        #10;

        // ==========================================
        // 3. Fuera de zona visible
        // Debe salir negro
        // ==========================================
        video_on   = 0;
        pixel_data = 12'hF00;
        #10;

        // ==========================================
        // 4. Cambiar sincronismos
        // Los sincronismos deben pasar igual
        // ==========================================
        hsync_in = 0;
        vsync_in = 1;
        #10;

        hsync_in = 1;
        vsync_in = 0;
        #10;

        // ==========================================
        // 5. Volver a zona visible
        // Debe mostrar el color otra vez
        // ==========================================
        video_on   = 1;
        pixel_data = 12'h0F5;
        #10;

        $finish;
    end

endmodule