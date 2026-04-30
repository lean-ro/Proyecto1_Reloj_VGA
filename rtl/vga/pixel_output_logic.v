module pixel_output_logic (
    input  wire        hsync_in,    // sincronismo horizontal de entrada
    input  wire        vsync_in,    // sincronismo vertical de entrada
    input  wire        video_on,    // indica si el pixel esta en zona visible
    input  wire [11:0] pixel_data,  // color del pixel leido desde la VRAM

    output reg         hsync_out,   // sincronismo horizontal de salida
    output reg         vsync_out,   // sincronismo vertical de salida
    output reg  [11:0] rgb_out      // color final hacia VGA
);

    always @(*) begin
        // Los sincronismos se pasan directamente
        hsync_out = hsync_in;
        vsync_out = vsync_in;

        // Solo mostramos color en la zona visible
        if (video_on)
            rgb_out = pixel_data;
        else
            rgb_out = 12'h000;   // negro
    end

endmodule