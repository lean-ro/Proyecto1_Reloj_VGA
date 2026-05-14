`timescale 1ns / 1ps

module tb_image_generator;

    reg clk;
    reg rst;
    reg start;

    reg [5:0] hh;
    reg [5:0] mm;
    reg [5:0] ss;

    wire        wr_en;
    wire [18:0] wr_addr;
    wire [11:0] wr_data;
    wire        busy;
    wire        frame_done;

    integer errors;

    // Instancia del modulo
    image_generator uut (
        .clk(clk),
        .rst(rst),
        .hh(hh),
        .mm(mm),
        .ss(ss),
        .start(start),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .busy(busy),
        .frame_done(frame_done)
    );

    // Reloj
    always #5 clk = ~clk;

    task check_write;
        input [18:0] exp_addr;
        input [11:0] exp_data;
        input [255:0] message;
        begin
            wait (wr_addr == exp_addr && wr_en == 1'b1);
            #1;

            if (wr_data !== exp_data) begin
                $display("ERROR: %s -> esperado=%03h obtenido=%03h",
                         message, exp_data, wr_data);
                errors = errors + 1;
            end else begin
                $display("OK: %s -> addr=%0d data=%03h",
                         message, wr_addr, wr_data);
            end
        end
    endtask

    initial begin
        clk    = 0;
        rst    = 1;
        start  = 0;
        errors = 0;

        // Hora de ejemplo
        hh = 6'd12;
        mm = 6'd34;
        ss = 6'd56;

        // Reset
        #20;
        rst = 0;

        // Pulso de inicio
        #10;
        start = 1;
        #10;
        start = 0;

        // Primer pixel de la pantalla
        // Debe ser fondo (margen oscuro en x=0)
        check_write(19'd0, 12'h000, "pixel (0,0) margen oscuro");

        // Pixel (79,0) aun en margen oscuro
        check_write(19'd79, 12'h000, "pixel (79,0) margen oscuro");

        // Pixel (80,0) ya entra en la imagen
        // No podemos predecir facil el color a mano,
        // pero si sabemos que ya no deberia ser margen negro fijo
        wait (wr_addr == 19'd80 && wr_en == 1'b1);
        #1;
        $display("INFO: pixel (80,0) color de imagen = %03h", wr_data);

        // Esperar fin del frame
        wait (frame_done == 1'b1);
        #1;

        if (busy !== 1'b0) begin
            $display("ERROR: al terminar el frame, busy deberia ser 0");
            errors = errors + 1;
        end else begin
            $display("OK: frame_done activado y busy en 0");
        end

        if (errors == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED - errores = %0d", errors);

        $finish;
    end

endmodule