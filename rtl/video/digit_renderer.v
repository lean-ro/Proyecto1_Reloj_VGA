module digit_renderer (
    input  wire [5:0] hh,       // horas
    input  wire [5:0] mm,       // minutos
    input  wire [5:0] ss,       // segundos
    input  wire [9:0] pixel_x,  // coordenada horizontal de pantalla
    input  wire [9:0] pixel_y,  // coordenada vertical de pantalla
    output reg        pixel_on  // 1 si el pixel pertenece al reloj
);

    // ==========================================
    // Parametros de posicion y escala
    // ==========================================
    localparam X_START      = 164; // inicio horizontal del reloj
    localparam Y_START      = 100; // inicio vertical del reloj
    localparam SCALE        = 4;   // cada pixel de la fuente se escala x4
    localparam CHAR_SIZE    = 8;   // fuente de 8x8
    localparam CHAR_WIDTH   = 32;  // 8 * 4
    localparam CHAR_HEIGHT  = 32;  // 8 * 4
    localparam CHAR_SPACING = 8;   // espacio entre caracteres
    localparam SLOT_WIDTH   = 40;  // ancho total por caracter con separacion
    localparam TOTAL_WIDTH  = 312; // ancho total de "HH:MM:SS"

    // ==========================================
    // Separacion de digitos
    // ==========================================
    wire [3:0] hh_tens;
    wire [3:0] hh_units;
    wire [3:0] mm_tens;
    wire [3:0] mm_units;
    wire [3:0] ss_tens;
    wire [3:0] ss_units;

    assign hh_tens  = hh / 10;
    assign hh_units = hh % 10;
    assign mm_tens  = mm / 10;
    assign mm_units = mm % 10;
    assign ss_tens  = ss / 10;
    assign ss_units = ss % 10;

    // ==========================================
    // Señales internas para font_rom
    // ==========================================
    reg  [3:0] selected_char;
    reg  [2:0] font_row;
    reg  [2:0] font_col;
    wire       font_pixel_on;

    reg inside_char;

    reg [9:0] local_x;
    reg [9:0] local_y;

    // Instancia de la ROM de fuente
    font_rom u_font_rom (
        .char_code(selected_char),
        .row(font_row),
        .col(font_col),
        .pixel_on(font_pixel_on)
    );

    always @(*) begin
        // Valores por defecto
        pixel_on      = 0;
        selected_char = 0;
        font_row      = 0;
        font_col      = 0;
        inside_char   = 0;
        local_x       = 0;
        local_y       = 0;

        // Verificar si el pixel esta dentro del area general del reloj
        if (pixel_x >= X_START &&
            pixel_x <  X_START + TOTAL_WIDTH &&
            pixel_y >= Y_START &&
            pixel_y <  Y_START + CHAR_HEIGHT) begin

            local_x = pixel_x - X_START;
            local_y = pixel_y - Y_START;

            // Fila de la fuente
            font_row = local_y / SCALE;

            // ==========================================
            // Seleccionar que caracter corresponde
            // ==========================================
            if (local_x < 32) begin
                selected_char = hh_tens;
                font_col      = local_x / SCALE;
                inside_char   = 1;
            end
            else if (local_x < 40) begin
                inside_char = 0;
            end
            else if (local_x < 72) begin
                selected_char = hh_units;
                font_col      = (local_x - 40) / SCALE;
                inside_char   = 1;
            end
            else if (local_x < 80) begin
                inside_char = 0;
            end
            else if (local_x < 112) begin
                selected_char = 4'd10; // :
                font_col      = (local_x - 80) / SCALE;
                inside_char   = 1;
            end
            else if (local_x < 120) begin
                inside_char = 0;
            end
            else if (local_x < 152) begin
                selected_char = mm_tens;
                font_col      = (local_x - 120) / SCALE;
                inside_char   = 1;
            end
            else if (local_x < 160) begin
                inside_char = 0;
            end
            else if (local_x < 192) begin
                selected_char = mm_units;
                font_col      = (local_x - 160) / SCALE;
                inside_char   = 1;
            end
            else if (local_x < 200) begin
                inside_char = 0;
            end
            else if (local_x < 232) begin
                selected_char = 4'd10; // :
                font_col      = (local_x - 200) / SCALE;
                inside_char   = 1;
            end
            else if (local_x < 240) begin
                inside_char = 0;
            end
            else if (local_x < 272) begin
                selected_char = ss_tens;
                font_col      = (local_x - 240) / SCALE;
                inside_char   = 1;
            end
            else if (local_x < 280) begin
                inside_char = 0;
            end
            else if (local_x < 312) begin
                selected_char = ss_units;
                font_col      = (local_x - 280) / SCALE;
                inside_char   = 1;
            end
            else begin
                inside_char = 0;
            end

            // Si estamos dentro del area activa del caracter,
            // tomamos el valor del pixel desde font_rom
            if (inside_char)
                pixel_on = font_pixel_on;
            else
                pixel_on = 0;
        end
        else begin
            pixel_on = 0;
        end
    end

endmodule