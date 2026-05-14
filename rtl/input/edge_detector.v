module edge_detector (
    input  wire clk,        // reloj del sistema
    input  wire rst,        // reset
    input  wire signal_in,  // señal de entrada ya limpia
    output reg  pulse_out   // pulso de un ciclo al detectar flanco ascendente
);

    reg signal_prev;        // guarda el valor anterior de la señal

    always @(posedge clk) begin
        if (rst) begin
            signal_prev <= 0;
            pulse_out   <= 0;
        end else begin
            // Genera un pulso cuando la señal pasa de 0 a 1
            pulse_out <= signal_in & ~signal_prev;

            // Guarda el valor actual para compararlo en el siguiente ciclo
            signal_prev <= signal_in;
        end
    end

endmodule