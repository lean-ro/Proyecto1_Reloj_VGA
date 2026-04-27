module debouncer #(
    parameter MAX_COUNT = 100000
)(
    input  wire clk,        // reloj del sistema
    input  wire rst,        // reset
    input  wire noisy_in,   // señal con posible rebote
    output reg  clean_out   // señal limpia y estable
);

    // Calcula automáticamente cuántos bits necesita el contador
    localparam COUNTER_WIDTH = $clog2(MAX_COUNT + 1);

    reg [COUNTER_WIDTH-1:0] counter;
    reg last_input;

    always @(posedge clk) begin
        if (rst) begin
            counter    <= 0;
            last_input <= 0;
            clean_out  <= 0;
        end else begin

            // Si la entrada cambió, reiniciamos el contador
            if (noisy_in != last_input) begin
                last_input <= noisy_in;
                counter    <= 0;
            end

            // Si la entrada sigue igual, contamos cuánto tiempo lleva estable
            else if (counter < MAX_COUNT) begin
                counter <= counter + 1;
            end

            // Cuando la entrada ha estado estable el tiempo suficiente,
            // actualizamos la salida limpia
            else begin
                clean_out <= last_input;
            end
        end
    end

endmodule