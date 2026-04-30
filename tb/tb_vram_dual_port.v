`timescale 1ns / 1ps

module tb_vram_dual_port;

    // Parametros de prueba
    localparam DATA_WIDTH = 12;
    localparam ADDR_WIDTH = 4;

    // Señales del puerto de escritura
    reg clk_wr;
    reg we_wr;
    reg [ADDR_WIDTH-1:0] addr_wr;
    reg [DATA_WIDTH-1:0] data_in;

    // Señales del puerto de lectura
    reg clk_rd;
    reg [ADDR_WIDTH-1:0] addr_rd;
    wire [DATA_WIDTH-1:0] data_out;

    // Instancia del modulo
    vram_dual_port #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .clk_wr(clk_wr),
        .we_wr(we_wr),
        .addr_wr(addr_wr),
        .data_in(data_in),
        .clk_rd(clk_rd),
        .addr_rd(addr_rd),
        .data_out(data_out)
    );

    // Reloj del puerto de escritura
    always #5 clk_wr = ~clk_wr;

    // Reloj del puerto de lectura
    always #7 clk_rd = ~clk_rd;

    initial begin
        // Valores iniciales
        clk_wr  = 0;
        clk_rd  = 0;
        we_wr   = 0;
        addr_wr = 0;
        data_in = 0;
        addr_rd = 0;

        $display("Tiempo\twe_wr\taddr_wr\tdata_in\t\taddr_rd\tdata_out");
        $monitor("%0t\t%b\t%0d\t%0h\t\t%0d\t%0h",
                 $time, we_wr, addr_wr, data_in, addr_rd, data_out);

        // ==========================================
        // 1. Escribir 12'hA3F en la direccion 3
        // ==========================================
        #10;
        we_wr   = 1;
        addr_wr = 4'd3;
        data_in = 12'hA3F;

        #10;
        we_wr   = 0;

        // Leer direccion 3
        #20;
        addr_rd = 4'd3;

        // ==========================================
        // 2. Escribir 12'h27C en la direccion 5
        // ==========================================
        #20;
        we_wr   = 1;
        addr_wr = 4'd5;
        data_in = 12'h27C;

        #10;
        we_wr   = 0;

        // Leer direccion 5
        #20;
        addr_rd = 4'd5;

        // ==========================================
        // 3. Escribir 12'hF00 en la direccion 1
        // ==========================================
        #20;
        we_wr   = 1;
        addr_wr = 4'd1;
        data_in = 12'hF00;

        #10;
        we_wr   = 0;

        // Leer direccion 1
        #20;
        addr_rd = 4'd1;

        // ==========================================
        // 4. Volver a leer direccion 3
        // Debe seguir guardando 12'hA3F
        // ==========================================
        #20;
        addr_rd = 4'd3;

        #30;
        $finish;
    end

endmodule