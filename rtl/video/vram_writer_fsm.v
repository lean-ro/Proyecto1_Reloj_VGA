module vram_writer_fsm (
    input  wire        clk,              // reloj del sistema
    input  wire        rst,              // reset
    input  wire        start,            // inicia el dibujo de un frame completo

    input  wire [11:0] bg_color,         // color del fondo en el pixel actual
    input  wire        clock_fill_on,    // 1 si el pixel actual pertenece al reloj
    input  wire        clock_border_on,  // 1 si el pixel actual pertenece al borde

    output reg  [9:0]  pixel_x,          // coordenada X actual
    output reg  [9:0]  pixel_y,          // coordenada Y actual

    output wire        wr_en,            // habilita escritura en VRAM
    output wire [18:0] wr_addr,          // direccion de escritura en VRAM
    output wire [11:0] wr_data,          // dato a escribir en VRAM

    output reg         busy,             // indica que esta dibujando
    output reg         frame_done        // pulso de 1 ciclo al terminar el frame
);

    localparam STATE_IDLE  = 1'b0;
    localparam STATE_WRITE = 1'b1;

    reg state;

    // ==========================================
    // La escritura esta activa solo en STATE_WRITE
    // ==========================================
    assign wr_en = (state == STATE_WRITE);

    // Direccion lineal de la VRAM: y * 640 + x
    assign wr_addr = (pixel_y * 19'd640) + pixel_x;

    // Prioridad de colores:
    // 1. reloj blanco
    // 2. borde negro
    // 3. fondo
    assign wr_data = (clock_fill_on)   ? 12'hFFF :
                     (clock_border_on) ? 12'h000 :
                                         bg_color;

    always @(posedge clk) begin
        if (rst) begin
            state      <= STATE_IDLE;
            pixel_x    <= 10'd0;
            pixel_y    <= 10'd0;
            busy       <= 1'b0;
            frame_done <= 1'b0;
        end else begin
            // Por defecto, frame_done solo dura 1 ciclo
            frame_done <= 1'b0;

            case (state)

                // ==========================================
                // Espera a que llegue start
                // ==========================================
                STATE_IDLE: begin
                    busy <= 1'b0;

                    if (start) begin
                        state   <= STATE_WRITE;
                        pixel_x <= 10'd0;
                        pixel_y <= 10'd0;
                        busy    <= 1'b1;
                    end
                end

                // ==========================================
                // Recorre toda la pantalla y escribe cada pixel
                // ==========================================
                STATE_WRITE: begin
                    busy <= 1'b1;

                    if (pixel_x == 10'd639) begin
                        if (pixel_y == 10'd479) begin
                            // Ultimo pixel del frame
                            state      <= STATE_IDLE;
                            pixel_x    <= 10'd0;
                            pixel_y    <= 10'd0;
                            busy       <= 1'b0;
                            frame_done <= 1'b1;
                        end else begin
                            // Siguiente fila
                            pixel_x <= 10'd0;
                            pixel_y <= pixel_y + 10'd1;
                        end
                    end else begin
                        // Siguiente pixel en la misma fila
                        pixel_x <= pixel_x + 10'd1;
                    end
                end

                default: begin
                    state      <= STATE_IDLE;
                    pixel_x    <= 10'd0;
                    pixel_y    <= 10'd0;
                    busy       <= 1'b0;
                    frame_done <= 1'b0;
                end
            endcase
        end
    end

endmodule