module vga_controller (
    input  wire        clk,        // reloj de pixeles
    input  wire        rst,        // reset
    input  wire [11:0] pixel_data, // dato leido desde la VRAM

    output wire [18:0] rd_addr,    // direccion de lectura hacia la VRAM
    output wire        hsync_out,  // sincronismo horizontal de salida
    output wire        vsync_out,  // sincronismo vertical de salida
    output wire [11:0] rgb_out     // color final hacia VGA
);

    // Señales internas desde vga_timing
    wire timing_hsync;
    wire timing_vsync;
    wire timing_video_on;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;

    // Señales atrasadas un ciclo para alinearlas con pixel_data
    reg delayed_hsync;
    reg delayed_vsync;
    reg delayed_video_on;

    // ==========================
    // Generador de timing VGA
    // ==========================
    vga_timing u_vga_timing (
        .clk(clk),
        .rst(rst),
        .hsync(timing_hsync),
        .vsync(timing_vsync),
        .video_on(timing_video_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );

    // ==========================
    // Generador de direccion de lectura
    // ==========================
    vram_read_addr_gen u_addr_gen (
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .video_on(timing_video_on),
        .rd_addr(rd_addr)
    );

    // ==========================
    // Atraso de 1 ciclo para alinear
    // sincronismos y video_on con pixel_data
    // ==========================
    always @(posedge clk) begin
        if (rst) begin
            delayed_hsync    <= 1'b1;
            delayed_vsync    <= 1'b1;
            delayed_video_on <= 1'b0;
        end else begin
            delayed_hsync    <= timing_hsync;
            delayed_vsync    <= timing_vsync;
            delayed_video_on <= timing_video_on;
        end
    end

    // ==========================
    // Logica final de salida
    // ==========================
    pixel_output_logic u_pixel_output_logic (
        .hsync_in(delayed_hsync),
        .vsync_in(delayed_vsync),
        .video_on(delayed_video_on),
        .pixel_data(pixel_data),
        .hsync_out(hsync_out),
        .vsync_out(vsync_out),
        .rgb_out(rgb_out)
    );

endmodule