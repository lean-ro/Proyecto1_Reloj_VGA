module font_rom (
    input  wire [3:0] char_code,  // caracter a dibujar
    input  wire [2:0] row,        // fila dentro del caracter (0 a 7)
    input  wire [2:0] col,        // columna dentro del caracter (0 a 7)
    output reg        pixel_on    // 1 si el pixel esta encendido
);

    // Codigos de caracteres
    localparam CHAR_0     = 4'd0;
    localparam CHAR_1     = 4'd1;
    localparam CHAR_2     = 4'd2;
    localparam CHAR_3     = 4'd3;
    localparam CHAR_4     = 4'd4;
    localparam CHAR_5     = 4'd5;
    localparam CHAR_6     = 4'd6;
    localparam CHAR_7     = 4'd7;
    localparam CHAR_8     = 4'd8;
    localparam CHAR_9     = 4'd9;
    localparam CHAR_COLON = 4'd10; // :

    reg [7:0] row_data;

    // ==========================================
    // Seleccion de la fila del caracter
    // ==========================================
    always @(*) begin
        row_data = 8'b00000000;

        case (char_code)

            // ----------------------------------
            // Digito 0
            // ----------------------------------
            CHAR_0: begin
                case (row)
                    3'd0: row_data = 8'b00111100;
                    3'd1: row_data = 8'b01100110;
                    3'd2: row_data = 8'b01101110;
                    3'd3: row_data = 8'b01110110;
                    3'd4: row_data = 8'b01100110;
                    3'd5: row_data = 8'b01100110;
                    3'd6: row_data = 8'b00111100;
                    3'd7: row_data = 8'b00000000;
                endcase
            end

            // ----------------------------------
            // Digito 1
            // ----------------------------------
            CHAR_1: begin
                case (row)
                    3'd0: row_data = 8'b00011000;
                    3'd1: row_data = 8'b00111000;
                    3'd2: row_data = 8'b00011000;
                    3'd3: row_data = 8'b00011000;
                    3'd4: row_data = 8'b00011000;
                    3'd5: row_data = 8'b00011000;
                    3'd6: row_data = 8'b00111100;
                    3'd7: row_data = 8'b00000000;
                endcase
            end

            // ----------------------------------
            // Digito 2
            // ----------------------------------
            CHAR_2: begin
                case (row)
                    3'd0: row_data = 8'b00111100;
                    3'd1: row_data = 8'b01100110;
                    3'd2: row_data = 8'b00000110;
                    3'd3: row_data = 8'b00001100;
                    3'd4: row_data = 8'b00110000;
                    3'd5: row_data = 8'b01100000;
                    3'd6: row_data = 8'b01111110;
                    3'd7: row_data = 8'b00000000;
                endcase
            end

            // ----------------------------------
            // Digito 3
            // ----------------------------------
            CHAR_3: begin
                case (row)
                    3'd0: row_data = 8'b00111100;
                    3'd1: row_data = 8'b01100110;
                    3'd2: row_data = 8'b00000110;
                    3'd3: row_data = 8'b00011100;
                    3'd4: row_data = 8'b00000110;
                    3'd5: row_data = 8'b01100110;
                    3'd6: row_data = 8'b00111100;
                    3'd7: row_data = 8'b00000000;
                endcase
            end

            // ----------------------------------
            // Digito 4
            // ----------------------------------
            CHAR_4: begin
                case (row)
                    3'd0: row_data = 8'b00001100;
                    3'd1: row_data = 8'b00011100;
                    3'd2: row_data = 8'b00101100;
                    3'd3: row_data = 8'b01001100;
                    3'd4: row_data = 8'b01111110;
                    3'd5: row_data = 8'b00001100;
                    3'd6: row_data = 8'b00001100;
                    3'd7: row_data = 8'b00000000;
                endcase
            end

            // ----------------------------------
            // Digito 5
            // ----------------------------------
            CHAR_5: begin
                case (row)
                    3'd0: row_data = 8'b01111110;
                    3'd1: row_data = 8'b01100000;
                    3'd2: row_data = 8'b01111100;
                    3'd3: row_data = 8'b00000110;
                    3'd4: row_data = 8'b00000110;
                    3'd5: row_data = 8'b01100110;
                    3'd6: row_data = 8'b00111100;
                    3'd7: row_data = 8'b00000000;
                endcase
            end

            // ----------------------------------
            // Digito 6
            // ----------------------------------
            CHAR_6: begin
                case (row)
                    3'd0: row_data = 8'b00111100;
                    3'd1: row_data = 8'b01100110;
                    3'd2: row_data = 8'b01100000;
                    3'd3: row_data = 8'b01111100;
                    3'd4: row_data = 8'b01100110;
                    3'd5: row_data = 8'b01100110;
                    3'd6: row_data = 8'b00111100;
                    3'd7: row_data = 8'b00000000;
                endcase
            end

            // ----------------------------------
            // Digito 7
            // ----------------------------------
            CHAR_7: begin
                case (row)
                    3'd0: row_data = 8'b01111110;
                    3'd1: row_data = 8'b00000110;
                    3'd2: row_data = 8'b00001100;
                    3'd3: row_data = 8'b00011000;
                    3'd4: row_data = 8'b00110000;
                    3'd5: row_data = 8'b00110000;
                    3'd6: row_data = 8'b00110000;
                    3'd7: row_data = 8'b00000000;
                endcase
            end

            // ----------------------------------
            // Digito 8
            // ----------------------------------
            CHAR_8: begin
                case (row)
                    3'd0: row_data = 8'b00111100;
                    3'd1: row_data = 8'b01100110;
                    3'd2: row_data = 8'b01100110;
                    3'd3: row_data = 8'b00111100;
                    3'd4: row_data = 8'b01100110;
                    3'd5: row_data = 8'b01100110;
                    3'd6: row_data = 8'b00111100;
                    3'd7: row_data = 8'b00000000;
                endcase
            end

            // ----------------------------------
            // Digito 9
            // ----------------------------------
            CHAR_9: begin
                case (row)
                    3'd0: row_data = 8'b00111100;
                    3'd1: row_data = 8'b01100110;
                    3'd2: row_data = 8'b01100110;
                    3'd3: row_data = 8'b00111110;
                    3'd4: row_data = 8'b00000110;
                    3'd5: row_data = 8'b01100110;
                    3'd6: row_data = 8'b00111100;
                    3'd7: row_data = 8'b00000000;
                endcase
            end

            // ----------------------------------
            // :
            // ----------------------------------
            CHAR_COLON: begin
                case (row)
                    3'd0: row_data = 8'b00000000;
                    3'd1: row_data = 8'b00011000;
                    3'd2: row_data = 8'b00011000;
                    3'd3: row_data = 8'b00000000;
                    3'd4: row_data = 8'b00011000;
                    3'd5: row_data = 8'b00011000;
                    3'd6: row_data = 8'b00000000;
                    3'd7: row_data = 8'b00000000;
                endcase
            end

            // ----------------------------------
            // Caracter no definido
            // ----------------------------------
            default: begin
                row_data = 8'b00000000;
            end
        endcase

        // Seleccion del bit correspondiente a la columna
        // col = 0 toma el bit mas a la izquierda
        pixel_on = row_data[3'd7 - col];
    end

endmodule