# Proyecto 1 - Controlador VGA con Reloj Digital

## Curso
Taller de Diseño Digital - EL3313

## Estado actual
Fase A - Planeación técnica

## Objetivo
Diseñar e implementar un reloj digital en FPGA con salida VGA, ajuste por botones y switches, y una arquitectura modular basada en VRAM, controlador VGA, generador de imagen y control de hora.

## Estructura del proyecto
- rtl/: módulos HDL
- tb/: testbenches
- sim/: archivos de simulación
- scripts/: automatización
- constraints/: constraints FPGA
- docs/: documentación, especificaciones y diagramas

## Módulos previstos
- top_clock_vga
- clock_control
- input_conditioning
- time_base
- vga_timing
- vga_controller
- vram_dual_port
- image_generator
- font_rom
