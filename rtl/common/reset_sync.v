module reset_sync (
    input  wire clk,       // reloj del sistema
    input  wire rst_raw,   // reset crudo, activo en 1
    output wire rst_sync   // reset sincronizado, activo en 1
);

    reg ff1;   // primer flip-flop
    reg ff2;   // segundo flip-flop

    always @(posedge clk or posedge rst_raw) begin
        if (rst_raw) begin
            // Cuando el reset se activa, ambos FF se ponen en 1 de inmediato
            ff1 <= 1'b1;
            ff2 <= 1'b1;
        end else begin
            // Cuando el reset se libera, la salida se limpia de forma sincronizada
            ff1 <= 1'b0;
            ff2 <= ff1;
        end
    end

    assign rst_sync = ff2;

endmodule