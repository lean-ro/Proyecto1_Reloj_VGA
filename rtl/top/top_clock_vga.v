module top_clock_vga (
    input  wire       clk100,        // reloj principal de la Nexys A7
    input  wire       rst_raw,       // reset crudo

    input  wire       btn_up_raw,    // boton subir
    input  wire       btn_down_raw,  // boton bajar

    input  wire       sw_edit_raw,   // switch modo edicion
    input  wire       sw_hh_raw,     // switch editar horas
    input  wire       sw_mm_raw,     // switch editar minutos
    input  wire       sw_ss_raw,     // switch editar segundos

    output wire       vga_hsync,     // VGA HSYNC
    output wire       vga_vsync,     // VGA VSYNC
    output wire [3:0] vga_r,         // VGA rojo
    output wire [3:0] vga_g,         // VGA verde
    output wire [3:0] vga_b          // VGA azul
);

    // ==========================================
    // Señales de reloj
    // ==========================================
    wire clk_sys;
    wire clk_pix;

    // ==========================================
    // Señales de reset sincronizado
    // ==========================================
    wire rst_sys;
    wire rst_pix;

    // ==========================================
    // Señales limpias de botones
    // ==========================================
    wire btn_up_sync;
    wire btn_up_clean;
    wire btn_up_pulse;

    wire btn_down_sync;
    wire btn_down_clean;
    wire btn_down_pulse;

    // ==========================================
    // Señales limpias de switches
    // ==========================================
    wire sw_edit;
    wire sw_hh;
    wire sw_mm;
    wire sw_ss;

    // ==========================================
    // Señales del reloj digital
    // ==========================================
    wire       tick_1Hz_en;
    wire [5:0] hh;
    wire [5:0] mm;
    wire [5:0] ss;

    // ==========================================
    // Señales del image_generator
    // ==========================================
    reg        img_start;
    wire       img_busy;
    wire       img_frame_done;
    wire       wr_en;
    wire [18:0] wr_addr;
    wire [11:0] wr_data;

    // ==========================================
    // Señales de la VRAM
    // ==========================================
    wire [18:0] rd_addr;
    wire [11:0] pixel_data_from_vram;

    // ==========================================
    // Señales del controlador VGA
    // ==========================================
    wire [11:0] rgb_out;

    // ==========================================
    // Logica para detectar cambio de hora
    // ==========================================
    reg [5:0] prev_hh;
    reg [5:0] prev_mm;
    reg [5:0] prev_ss;
    reg       redraw_pending;

    // ==========================================
    // Clock manager
    // ==========================================
    clock_manager u_clock_manager (
        .clk_in(clk100),
        .rst(rst_raw),
        .clk_sys(clk_sys),
        .clk_pix(clk_pix)
    );

    // ==========================================
    // Reset sincronizado para dominio clk_sys
    // ==========================================
    reset_sync u_reset_sync_sys (
        .clk(clk_sys),
        .rst_raw(rst_raw),
        .rst_sync(rst_sys)
    );

    // ==========================================
    // Reset sincronizado para dominio clk_pix
    // ==========================================
    reset_sync u_reset_sync_pix (
        .clk(clk_pix),
        .rst_raw(rst_raw),
        .rst_sync(rst_pix)
    );

    // ==========================================
    // Boton subir: sync + debounce + edge detect
    // ==========================================
    sync_2ff u_btn_up_sync (
        .clk(clk_sys),
        .rst(rst_sys),
        .async_in(btn_up_raw),
        .sync_out(btn_up_sync)
    );

    debouncer u_btn_up_debounce (
        .clk(clk_sys),
        .rst(rst_sys),
        .noisy_in(btn_up_sync),
        .clean_out(btn_up_clean)
    );

    edge_detector u_btn_up_edge (
        .clk(clk_sys),
        .rst(rst_sys),
        .signal_in(btn_up_clean),
        .pulse_out(btn_up_pulse)
    );

    // ==========================================
    // Boton bajar: sync + debounce + edge detect
    // ==========================================
    sync_2ff u_btn_down_sync (
        .clk(clk_sys),
        .rst(rst_sys),
        .async_in(btn_down_raw),
        .sync_out(btn_down_sync)
    );

    debouncer u_btn_down_debounce (
        .clk(clk_sys),
        .rst(rst_sys),
        .noisy_in(btn_down_sync),
        .clean_out(btn_down_clean)
    );

    edge_detector u_btn_down_edge (
        .clk(clk_sys),
        .rst(rst_sys),
        .signal_in(btn_down_clean),
        .pulse_out(btn_down_pulse)
    );

    // ==========================================
    // Switches: solo sincronizacion
    // ==========================================
    sync_2ff u_sw_edit_sync (
        .clk(clk_sys),
        .rst(rst_sys),
        .async_in(sw_edit_raw),
        .sync_out(sw_edit)
    );

    sync_2ff u_sw_hh_sync (
        .clk(clk_sys),
        .rst(rst_sys),
        .async_in(sw_hh_raw),
        .sync_out(sw_hh)
    );

    sync_2ff u_sw_mm_sync (
        .clk(clk_sys),
        .rst(rst_sys),
        .async_in(sw_mm_raw),
        .sync_out(sw_mm)
    );

    sync_2ff u_sw_ss_sync (
        .clk(clk_sys),
        .rst(rst_sys),
        .async_in(sw_ss_raw),
        .sync_out(sw_ss)
    );

    // ==========================================
    // Base de tiempo de 1 Hz
    // ==========================================
    time_base u_time_base (
        .clk(clk_sys),
        .rst(rst_sys),
        .tick_1Hz_en(tick_1Hz_en)
    );

    // ==========================================
    // Control de hora
    // ==========================================
    clock_control u_clock_control (
        .clk(clk_sys),
        .rst(rst_sys),
        .tick_1Hz_en(tick_1Hz_en),
        .sw_edit(sw_edit),
        .sw_hh(sw_hh),
        .sw_mm(sw_mm),
        .sw_ss(sw_ss),
        .btn_up(btn_up_pulse),
        .btn_down(btn_down_pulse),
        .hh(hh),
        .mm(mm),
        .ss(ss)
    );

    // ==========================================
    // Logica para iniciar redibujado
    // - al arrancar
    // - cuando cambia hh:mm:ss
    // ==========================================
    always @(posedge clk_sys) begin
        if (rst_sys) begin
            prev_hh        <= 6'd0;
            prev_mm        <= 6'd0;
            prev_ss        <= 6'd0;
            redraw_pending <= 1'b1;  // redibujar una vez al inicio
            img_start      <= 1'b0;
        end else begin
            img_start <= 1'b0;

            // Detectar cambio de hora
            if (hh != prev_hh || mm != prev_mm || ss != prev_ss) begin
                prev_hh        <= hh;
                prev_mm        <= mm;
                prev_ss        <= ss;
                redraw_pending <= 1'b1;
            end

            // Lanzar start solo cuando el generador no este ocupado
            if (redraw_pending && !img_busy) begin
                img_start      <= 1'b1;
                redraw_pending <= 1'b0;
            end
        end
    end

    // ==========================================
    // Generador de imagen
    // ==========================================
    image_generator u_image_generator (
        .clk(clk_sys),
        .rst(rst_sys),
        .hh(hh),
        .mm(mm),
        .ss(ss),
        .start(img_start),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .busy(img_busy),
        .frame_done(img_frame_done)
    );

    // ==========================================
    // VRAM dual-port
    // ==========================================
    vram_dual_port u_vram_dual_port (
        .clk_wr(clk_sys),
        .we_wr(wr_en),
        .addr_wr(wr_addr),
        .data_in(wr_data),

        .clk_rd(clk_pix),
        .addr_rd(rd_addr),
        .data_out(pixel_data_from_vram)
    );

    // ==========================================
    // Controlador VGA
    // ==========================================
    vga_controller u_vga_controller (
        .clk(clk_pix),
        .rst(rst_pix),
        .pixel_data(pixel_data_from_vram),
        .rd_addr(rd_addr),
        .hsync_out(vga_hsync),
        .vsync_out(vga_vsync),
        .rgb_out(rgb_out)
    );

    // ==========================================
    // Mapeo RGB 12 bits -> VGA 4 bits por canal
    // ==========================================
    assign vga_r = rgb_out[11:8];
    assign vga_g = rgb_out[7:4];
    assign vga_b = rgb_out[3:0];

endmodule