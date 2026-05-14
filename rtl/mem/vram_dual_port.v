module vram_dual_port #(
    parameter DATA_WIDTH = 12,    // 4 bits para R, 4 bits para G, 4 bits para B
    parameter ADDR_WIDTH = 19,    // 19 bits alcanzan para direccionar 307200 posiciones
    parameter DEPTH      = 307200 // profundidad real de la VRAM para 640x480
)(
    input  wire                     clk_wr,    // reloj del puerto de escritura
    input  wire                     we_wr,     // habilita escritura
    input  wire [ADDR_WIDTH-1:0]    addr_wr,   // direccion de escritura
    input  wire [DATA_WIDTH-1:0]    data_in,   // dato a escribir

    input  wire                     clk_rd,    // reloj del puerto de lectura
    input  wire [ADDR_WIDTH-1:0]    addr_rd,   // direccion de lectura
    output reg  [DATA_WIDTH-1:0]    data_out   // dato leido
);

    // Memoria interna
    (* ram_style = "block" *) reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];

    // ==========================================
    // Puerto de escritura
    // ==========================================
    always @(posedge clk_wr) begin
        if (we_wr && addr_wr < DEPTH) begin
            memory[addr_wr] <= data_in;
        end
    end

    // ==========================================
    // Puerto de lectura
    // ==========================================
    always @(posedge clk_rd) begin
        if (addr_rd < DEPTH)
            data_out <= memory[addr_rd];
        else
            data_out <= {DATA_WIDTH{1'b0}};
    end

endmodule