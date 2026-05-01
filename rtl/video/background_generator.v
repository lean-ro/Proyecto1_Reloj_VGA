module background_generator (
    input  wire [9:0]  pixel_x,   // coordenada horizontal VGA
    input  wire [9:0]  pixel_y,   // coordenada vertical VGA
    output reg  [11:0] bg_color   // color de fondo
);

    // ==========================================
    // Parametros del fondo
    // ==========================================
    localparam X_MARGIN   = 80;    // margen oscuro izquierdo y derecho
    localparam IMG_WIDTH  = 240;   // ancho real de la imagen base
    localparam IMG_HEIGHT = 240;   // alto real de la imagen base
    localparam DARK_COLOR = 12'h000;

    reg  [7:0]  bg_x;       // coordenada X dentro de la imagen 240x240
    reg  [7:0]  bg_y;       // coordenada Y dentro de la imagen 240x240
    reg  [15:0] bg_addr;    // direccion para la ROM del fondo
    wire [11:0] rom_data;   // color leido desde la ROM

    // ROM del fondo
    background_rom u_background_rom (
        .addr(bg_addr),
        .bg_data(rom_data)
    );

    always @(*) begin
        // Valores por defecto
        bg_x    = 0;
        bg_y    = 0;
        bg_addr = 0;
        bg_color = DARK_COLOR;

        // ==========================================
        // Zona central donde va la imagen
        // x = 80 a 559   -> 480 pixeles
        // y = 0  a 479   -> 480 pixeles
        // Se escala x2 desde 240x240
        // ==========================================
        if (pixel_x >= X_MARGIN && pixel_x < (X_MARGIN + 480) &&
            pixel_y < 480) begin

            // Convertir coordenadas VGA a coordenadas de la imagen base
            bg_x = (pixel_x - X_MARGIN) >> 1;
            bg_y = pixel_y >> 1;

            // Convertir (x, y) en direccion lineal
            bg_addr = (bg_y * IMG_WIDTH) + bg_x;

            // Tomar color desde la ROM
            bg_color = rom_data;
        end
        else begin
            // Margenes oscuros
            bg_color = DARK_COLOR;
        end
    end

endmodule