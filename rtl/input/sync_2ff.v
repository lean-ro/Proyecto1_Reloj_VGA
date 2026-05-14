module sync_2ff (
    input  wire clk,       // reloj del sistema
    input  wire rst,       // reset
    input  wire async_in,  // señal asíncrona de entrada
    output wire sync_out   // señal sincronizada
);

    reg ff1;
    reg ff2;

    always @(posedge clk) begin
        if (rst) begin
            ff1 <= 0;
            ff2 <= 0;
        end else begin
            ff1 <= async_in;
            ff2 <= ff1;
        end
    end

    assign sync_out = ff2;

endmodule