module clock_manager (
    input  wire clk_in,    // reloj de entrada: 100 MHz
    input  wire rst,       // reset

    output wire clk_sys,   // reloj del sistema: 100 MHz
    output wire clk_pix    // reloj de pixeles: 25 MHz
);

    reg [1:0] div_counter;

    // clk_sys es el mismo reloj de entrada
    assign clk_sys = clk_in;

    // clk_pix es el bit mas significativo del divisor
    assign clk_pix = div_counter[1];

    always @(posedge clk_in) begin
        if (rst) begin
            div_counter <= 2'b00;
        end else begin
            div_counter <= div_counter + 2'b01;
        end
    end

endmodule