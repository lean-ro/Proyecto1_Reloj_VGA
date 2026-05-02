#!/usr/bin/env bash

set -euo pipefail

# ==========================================
# Proyecto1_Reloj_VGA - Run All Simulations
# ==========================================

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SIM_DIR="$ROOT_DIR/build/sim"
MEM_FILE_SRC="$ROOT_DIR/mem_image/background_240x240.mem"
MEM_FILE_DST="$SIM_DIR/background_240x240.mem"

mkdir -p "$SIM_DIR"

# ==========================================
# Verificaciones básicas
# ==========================================
if ! command -v iverilog >/dev/null 2>&1; then
    echo "ERROR: iverilog no está instalado."
    echo "Instálalo con: sudo apt install iverilog -y"
    exit 1
fi

if ! command -v vvp >/dev/null 2>&1; then
    echo "ERROR: vvp no está instalado."
    echo "Instálalo con: sudo apt install iverilog -y"
    exit 1
fi

if [[ ! -f "$MEM_FILE_SRC" ]]; then
    echo "ERROR: no se encontró el archivo de memoria:"
    echo "  $MEM_FILE_SRC"
    exit 1
fi

# Copiar el .mem al directorio de simulación
cp "$MEM_FILE_SRC" "$MEM_FILE_DST"

echo "=========================================="
echo " Proyecto1_Reloj_VGA - Run All Simulations "
echo "=========================================="
echo "ROOT_DIR : $ROOT_DIR"
echo "SIM_DIR  : $SIM_DIR"
echo ""

# ==========================================
# Archivos RTL por grupo
# ==========================================
RTL_COMMON=(
    "$ROOT_DIR/rtl/common/reset_sync.v"
    "$ROOT_DIR/rtl/common/clock_manager.v"
)

RTL_INPUT=(
    "$ROOT_DIR/rtl/input/sync_2ff.v"
    "$ROOT_DIR/rtl/input/debouncer.v"
    "$ROOT_DIR/rtl/input/edge_detector.v"
)

RTL_TIME=(
    "$ROOT_DIR/rtl/time/time_base.v"
    "$ROOT_DIR/rtl/time/clock_control.v"
)

RTL_MEM=(
    "$ROOT_DIR/rtl/mem/vram_dual_port.v"
)

RTL_VGA=(
    "$ROOT_DIR/rtl/vga/vga_timing.v"
    "$ROOT_DIR/rtl/vga/vram_read_addr_gen.v"
    "$ROOT_DIR/rtl/vga/pixel_output_logic.v"
    "$ROOT_DIR/rtl/vga/vga_controller.v"
)

RTL_VIDEO=(
    "$ROOT_DIR/rtl/video/font_rom.v"
    "$ROOT_DIR/rtl/video/digit_renderer.v"
    "$ROOT_DIR/rtl/video/background_rom.v"
    "$ROOT_DIR/rtl/video/background_generator.v"
    "$ROOT_DIR/rtl/video/vram_writer_fsm.v"
    "$ROOT_DIR/rtl/video/image_generator.v"
)

RTL_TOP=(
    "$ROOT_DIR/rtl/top/top_clock_vga.v"
)

# ==========================================
# Función para correr un testbench
# ==========================================
run_testbench() {
    local name="$1"
    shift
    local files=("$@")

    local tb_file="$ROOT_DIR/tb/${name}.v"
    local out_file="$SIM_DIR/${name}.out"
    local log_file="$SIM_DIR/${name}.log"

    if [[ ! -f "$tb_file" ]]; then
        echo "WARNING: no existe $tb_file -> se omite"
        return 0
    fi

    echo "------------------------------------------"
    echo "Running $name"
    echo "------------------------------------------"

    (
        cd "$SIM_DIR"
        iverilog -g2012 -o "$out_file" "${files[@]}" "$tb_file" > "$log_file" 2>&1
        vvp "$out_file" >> "$log_file" 2>&1
    )

    echo "OK -> $name"
    echo "Log: $log_file"
    echo ""
}

# ==========================================
# Lista de simulaciones
# ==========================================
run_all() {
    # Input conditioning
    run_testbench "tb_sync_2ff" \
        "${RTL_INPUT[@]}"

    run_testbench "tb_debouncer" \
        "${RTL_INPUT[@]}"

    run_testbench "tb_edge_detector" \
        "${RTL_INPUT[@]}"

    run_testbench "tb_reset_sync" \
        "${RTL_COMMON[@]}"

    # Clock control
    run_testbench "tb_time_base" \
        "${RTL_TIME[@]}"

    run_testbench "tb_clock_control" \
        "${RTL_TIME[@]}"

    run_testbench "tb_clock_manager" \
        "${RTL_COMMON[@]}"

    # VRAM
    run_testbench "tb_vram_dual_port" \
        "${RTL_MEM[@]}"

    # VGA
    run_testbench "tb_vga_timing" \
        "${RTL_VGA[@]}"

    run_testbench "tb_vram_read_addr_gen" \
        "${RTL_VGA[@]}"

    run_testbench "tb_pixel_output_logic" \
        "${RTL_VGA[@]}"

    run_testbench "tb_vga_controller" \
        "${RTL_VGA[@]}" \
        "${RTL_MEM[@]}"

    # Image generator
    run_testbench "tb_font_rom" \
        "${RTL_VIDEO[@]}"

    run_testbench "tb_digit_renderer" \
        "${RTL_VIDEO[@]}"

    run_testbench "tb_background_rom" \
        "${RTL_VIDEO[@]}"

    run_testbench "tb_background_generator" \
        "${RTL_VIDEO[@]}"

    run_testbench "tb_vram_writer_fsm" \
        "${RTL_VIDEO[@]}"

    run_testbench "tb_image_generator" \
        "${RTL_VIDEO[@]}"

    # Top-level
    run_testbench "tb_top_clock_vga" \
        "${RTL_COMMON[@]}" \
        "${RTL_INPUT[@]}" \
        "${RTL_TIME[@]}" \
        "${RTL_MEM[@]}" \
        "${RTL_VGA[@]}" \
        "${RTL_VIDEO[@]}" \
        "${RTL_TOP[@]}"
}

# ==========================================
# Ejecutar uno solo o todos
# Uso:
#   ./scripts/run_all_sims.sh
#   ./scripts/run_all_sims.sh tb_top_clock_vga
# ==========================================
if [[ $# -eq 0 ]]; then
    run_all
else
    TB_NAME="$1"

    case "$TB_NAME" in
        tb_sync_2ff)
            run_testbench "$TB_NAME" "${RTL_INPUT[@]}"
            ;;
        tb_debouncer)
            run_testbench "$TB_NAME" "${RTL_INPUT[@]}"
            ;;
        tb_edge_detector)
            run_testbench "$TB_NAME" "${RTL_INPUT[@]}"
            ;;
        tb_reset_sync)
            run_testbench "$TB_NAME" "${RTL_COMMON[@]}"
            ;;
        tb_time_base)
            run_testbench "$TB_NAME" "${RTL_TIME[@]}"
            ;;
        tb_clock_control)
            run_testbench "$TB_NAME" "${RTL_TIME[@]}"
            ;;
        tb_clock_manager)
            run_testbench "$TB_NAME" "${RTL_COMMON[@]}"
            ;;
        tb_vram_dual_port)
            run_testbench "$TB_NAME" "${RTL_MEM[@]}"
            ;;
        tb_vga_timing)
            run_testbench "$TB_NAME" "${RTL_VGA[@]}"
            ;;
        tb_vram_read_addr_gen)
            run_testbench "$TB_NAME" "${RTL_VGA[@]}"
            ;;
        tb_pixel_output_logic)
            run_testbench "$TB_NAME" "${RTL_VGA[@]}"
            ;;
        tb_vga_controller)
            run_testbench "$TB_NAME" "${RTL_VGA[@]}" "${RTL_MEM[@]}"
            ;;
        tb_font_rom|tb_digit_renderer|tb_background_rom|tb_background_generator|tb_vram_writer_fsm|tb_image_generator)
            run_testbench "$TB_NAME" "${RTL_VIDEO[@]}"
            ;;
        tb_top_clock_vga)
            run_testbench "$TB_NAME" \
                "${RTL_COMMON[@]}" \
                "${RTL_INPUT[@]}" \
                "${RTL_TIME[@]}" \
                "${RTL_MEM[@]}" \
                "${RTL_VGA[@]}" \
                "${RTL_VIDEO[@]}" \
                "${RTL_TOP[@]}"
            ;;
        *)
            echo "ERROR: testbench no reconocido: $TB_NAME"
            echo "Ejemplos:"
            echo "  ./scripts/run_all_sims.sh"
            echo "  ./scripts/run_all_sims.sh tb_top_clock_vga"
            exit 1
            ;;
    esac
fi

echo "=========================================="
echo "Simulaciones finalizadas."
echo "Resultados en: $SIM_DIR"
echo "=========================================="