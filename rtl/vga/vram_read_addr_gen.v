module vram_read_addr_gen (
    input  wire [9:0] pixel_x,   // coordenada horizontal visible
    input  wire [9:0] pixel_y,   // coordenada vertical visible
    input  wire       video_on,  // indica si estamos en la zona visible

    output reg  [18:0] rd_addr   // direccion de lectura para la VRAM
);

    always @(*) begin
        if (video_on) begin
            // Formula para convertir (x, y) en una direccion lineal:
            // direccion = fila * ancho + columna
            rd_addr = (pixel_y * 640) + pixel_x;
        end else begin
            // Fuera de la zona visible no nos interesa leer un pixel valido
            rd_addr = 0;
        end
    end

endmodule