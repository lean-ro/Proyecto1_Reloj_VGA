`timescale 1ns / 1ps

module tb_background_rom;

    localparam DATA_WIDTH = 12;
    localparam ADDR_WIDTH = 16;
    localparam DEPTH      = 57600;
    localparam MEM_FILE   = "background_240x240.mem";

    reg  [ADDR_WIDTH-1:0] addr;
    wire [DATA_WIDTH-1:0] bg_data;

    reg [DATA_WIDTH-1:0] expected_memory [0:DEPTH-1];
    integer errors;

    // Instancia del modulo
    background_rom #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEPTH(DEPTH),
        .MEM_FILE(MEM_FILE)
    ) uut (
        .addr(addr),
        .bg_data(bg_data)
    );

    task check_addr;
        input [ADDR_WIDTH-1:0] test_addr;
        begin
            addr = test_addr;
            #1;

            if (bg_data !== expected_memory[test_addr]) begin
                $display("ERROR: addr=%0d esperado=%03h obtenido=%03h",
                         test_addr, expected_memory[test_addr], bg_data);
                errors = errors + 1;
            end else begin
                $display("OK: addr=%0d valor=%03h",
                         test_addr, bg_data);
            end
        end
    endtask

    initial begin
        addr   = 0;
        errors = 0;

        // Cargar memoria de referencia
        $readmemh(MEM_FILE, expected_memory);

        // Probar algunas direcciones
        check_addr(16'd0);
        check_addr(16'd1);
        check_addr(16'd2);
        check_addr(16'd239);
        check_addr(16'd240);
        check_addr(16'd241);
        check_addr(16'd1000);
        check_addr(16'd57599);

        // Probar una direccion fuera de rango
        addr = 16'd60000;
        #1;
        if (bg_data !== 12'h000) begin
            $display("ERROR: addr fuera de rango esperado=000 obtenido=%03h", bg_data);
            errors = errors + 1;
        end else begin
            $display("OK: addr fuera de rango devuelve 000");
        end

        // Resultado final
        if (errors == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED - errores = %0d", errors);

        $finish;
    end

endmodule