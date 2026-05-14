module vga_timing (
    input  wire clk,         // reloj de pixeles (25 MHz aprox.)
    input  wire rst,         // reset

    output reg  hsync,       // sincronismo horizontal
    output reg  vsync,       // sincronismo vertical
    output reg  video_on,    // indica zona visible

    output reg [9:0] pixel_x, // posicion horizontal visible
    output reg [9:0] pixel_y  // posicion vertical visible
);

    // ==========================
    // Parametros horizontales
    // ==========================
    localparam H_VISIBLE = 640;
    localparam H_FRONT   = 16;
    localparam H_SYNC    = 96;
    localparam H_BACK    = 48;
    localparam H_TOTAL   = 800;

    // ==========================
    // Parametros verticales
    // ==========================
    localparam V_VISIBLE = 480;
    localparam V_FRONT   = 10;
    localparam V_SYNC    = 2;
    localparam V_BACK    = 33;
    localparam V_TOTAL   = 525;

    // Contadores de barrido
    reg [9:0] h_count;
    reg [9:0] v_count;

    always @(posedge clk) begin
        if (rst) begin
            h_count  <= 0;
            v_count  <= 0;
            hsync    <= 1;
            vsync    <= 1;
            video_on <= 0;
            pixel_x  <= 0;
            pixel_y  <= 0;
        end else begin
            // ==========================
            // Contador horizontal
            // ==========================
            if (h_count == H_TOTAL - 1) begin
                h_count <= 0;

                // Cuando termina una linea, avanzar vertical
                if (v_count == V_TOTAL - 1)
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
            end else begin
                h_count <= h_count + 1;
            end

            // ==========================
            // Generacion de hsync
            // Activo en bajo
            // ==========================
            if (h_count >= (H_VISIBLE + H_FRONT) &&
                h_count <  (H_VISIBLE + H_FRONT + H_SYNC))
                hsync <= 0;
            else
                hsync <= 1;

            // ==========================
            // Generacion de vsync
            // Activo en bajo
            // ==========================
            if (v_count >= (V_VISIBLE + V_FRONT) &&
                v_count <  (V_VISIBLE + V_FRONT + V_SYNC))
                vsync <= 0;
            else
                vsync <= 1;

            // ==========================
            // Zona visible
            // ==========================
            if (h_count < H_VISIBLE && v_count < V_VISIBLE)
                video_on <= 1;
            else
                video_on <= 0;

            // ==========================
            // Coordenadas visibles
            // ==========================
            if (h_count < H_VISIBLE)
                pixel_x <= h_count;
            else
                pixel_x <= 0;

            if (v_count < V_VISIBLE)
                pixel_y <= v_count;
            else
                pixel_y <= 0;
        end
    end

endmodule