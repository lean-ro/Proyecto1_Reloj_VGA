module vram_dual_port #(
    parameter DATA_WIDTH = 12,   // 4 bits para R, 4 bits para G, 4 bits para B
    parameter ADDR_WIDTH = 19    // suficiente para 640x480 = 307200 direcciones
)(
    input  wire                     clk_wr,    // reloj del puerto de escritura
    input  wire                     we_wr,     // habilita escritura
    input  wire [ADDR_WIDTH-1:0]    addr_wr,   // direccion de escritura
    input  wire [DATA_WIDTH-1:0]    data_in,   // dato a escribir

    input  wire                     clk_rd,    // reloj del puerto de lectura
    input  wire [ADDR_WIDTH-1:0]    addr_rd,   // direccion de lectura
    output reg  [DATA_WIDTH-1:0]    data_out   // dato leido
);

    localparam DEPTH = 1 << ADDR_WIDTH;

    // Memoria interna
    // Vivado intentara implementarla usando Block RAM
    (* ram_style = "block" *) reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];

    // ==========================================
    // Puerto de escritura
    // ==========================================
    always @(posedge clk_wr) begin
        if (we_wr) begin
            memory[addr_wr] <= data_in;
        end
    end

    // ==========================================
    // Puerto de lectura
    // ==========================================
    always @(posedge clk_rd) begin
        data_out <= memory[addr_rd];
    end

endmodule