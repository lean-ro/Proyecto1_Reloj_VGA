module background_rom #(
    parameter DATA_WIDTH = 12,
    parameter ADDR_WIDTH = 16,
    parameter DEPTH      = 57600,
    parameter MEM_FILE   = "background_240x240.mem"
)(
    input  wire [ADDR_WIDTH-1:0] addr,     // direccion del pixel
    output reg  [DATA_WIDTH-1:0] bg_data   // color del fondo
);

    reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
    integer i;

    initial begin
        // Inicializar todo en negro
        for (i = 0; i < DEPTH; i = i + 1) begin
            memory[i] = 12'h000;
        end

        // Cargar la imagen convertida
        $readmemh(MEM_FILE, memory);
    end

    always @(*) begin
        if (addr < DEPTH)
            bg_data = memory[addr];
        else
            bg_data = 12'h000;
    end

endmodule