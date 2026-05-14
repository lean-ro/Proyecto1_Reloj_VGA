module clock_control (
    input  wire clk,          // reloj del sistema
    input  wire rst,          // reset
    input  wire tick_1Hz_en,  // pulso de 1 segundo

    input  wire sw_edit,      // habilita modo edicion
    input  wire sw_hh,        // seleccionar horas
    input  wire sw_mm,        // seleccionar minutos
    input  wire sw_ss,        // seleccionar segundos

    input  wire btn_up,       // pulso para subir
    input  wire btn_down,     // pulso para bajar

    output reg [5:0] hh,      // horas   : 0 a 23
    output reg [5:0] mm,      // minutos : 0 a 59
    output reg [5:0] ss       // segundos: 0 a 59
);

    // Seleccion valida: solo uno de hh, mm o ss puede estar activo
    wire valid_selection;
    assign valid_selection =
           (sw_hh & ~sw_mm & ~sw_ss) |
           (~sw_hh & sw_mm & ~sw_ss) |
           (~sw_hh & ~sw_mm & sw_ss);

    always @(posedge clk) begin
        if (rst) begin
            hh <= 0;
            mm <= 0;
            ss <= 0;
        end else begin

            // ==========================================
            // MODO EDICION
            // ==========================================
            if (sw_edit) begin
                if (valid_selection) begin

                    // --------------------------
                    // Editar horas
                    // --------------------------
                    if (sw_hh) begin
                        if (btn_up) begin
                            if (hh == 23)
                                hh <= 0;
                            else
                                hh <= hh + 1;
                        end else if (btn_down) begin
                            if (hh == 0)
                                hh <= 23;
                            else
                                hh <= hh - 1;
                        end
                    end

                    // --------------------------
                    // Editar minutos
                    // --------------------------
                    else if (sw_mm) begin
                        if (btn_up) begin
                            if (mm == 59)
                                mm <= 0;
                            else
                                mm <= mm + 1;
                        end else if (btn_down) begin
                            if (mm == 0)
                                mm <= 59;
                            else
                                mm <= mm - 1;
                        end
                    end

                    // --------------------------
                    // Editar segundos
                    // --------------------------
                    else if (sw_ss) begin
                        if (btn_up) begin
                            if (ss == 59)
                                ss <= 0;
                            else
                                ss <= ss + 1;
                        end else if (btn_down) begin
                            if (ss == 0)
                                ss <= 59;
                            else
                                ss <= ss - 1;
                        end
                    end
                end
            end

            // ==========================================
            // MODO NORMAL
            // ==========================================
            else begin
                if (tick_1Hz_en) begin

                    // Incrementar segundos
                    if (ss == 59) begin
                        ss <= 0;

                        // Incrementar minutos
                        if (mm == 59) begin
                            mm <= 0;

                            // Incrementar horas
                            if (hh == 23)
                                hh <= 0;
                            else
                                hh <= hh + 1;
                        end else begin
                            mm <= mm + 1;
                        end
                    end else begin
                        ss <= ss + 1;
                    end
                end
            end
        end
    end

endmodule