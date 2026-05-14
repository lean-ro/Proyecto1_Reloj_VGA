module time_base #(
    parameter MAX_COUNT = 100_000_000
)(
    input  wire clk,          // reloj del sistema
    input  wire rst,          // reset
    output reg  tick_1Hz_en   // pulso de un ciclo cada 1 segundo
);

    integer counter;

    always @(posedge clk) begin
        if (rst) begin
            counter     <= 0;
            tick_1Hz_en <= 0;
        end else begin
            if (counter == MAX_COUNT - 1) begin
                counter     <= 0;
                tick_1Hz_en <= 1;
            end else begin
                counter     <= counter + 1;
                tick_1Hz_en <= 0;
            end
        end
    end

endmodule