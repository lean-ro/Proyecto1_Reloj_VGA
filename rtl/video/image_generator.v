module image_generator (
    input  wire        clk,      // reloj del sistema
    input  wire        rst,      // reset
    input  wire [5:0]  hh,       // horas
    input  wire [5:0]  mm,       // minutos
    input  wire [5:0]  ss,       // segundos

    input  wire        start,    // inicia la escritura del frame

    output wire        wr_en,    // habilita escritura en VRAM
    output wire [18:0] wr_addr,  // direccion de escritura
    output wire [11:0] wr_data,  // dato a escribir

    output wire        busy,      // indica que se esta escribiendo el frame
    output wire        frame_done // pulso al terminar el frame
);

    wire [9:0] pixel_x;
    wire [9:0] pixel_y;

    wire [11:0] bg_color;
    wire        clock_fill_on;
    wire        clock_border_on;

    // ==========================================
    // Generador de fondo
    // ==========================================
    background_generator u_background_generator (
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .bg_color(bg_color)
    );

    // ==========================================
    // Renderizador del reloj
    // ==========================================
    digit_renderer u_digit_renderer (
        .hh(hh),
        .mm(mm),
        .ss(ss),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .pixel_on(clock_fill_on)
    );

    // ==========================================
    // Borde del reloj
    // Primera version: desactivado
    // ==========================================
    assign clock_border_on = 1'b0;

    // ==========================================
    // Escritor de VRAM
    // ==========================================
    vram_writer_fsm u_vram_writer_fsm (
        .clk(clk),
        .rst(rst),
        .start(start),
        .bg_color(bg_color),
        .clock_fill_on(clock_fill_on),
        .clock_border_on(clock_border_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .busy(busy),
        .frame_done(frame_done)
    );

endmodule