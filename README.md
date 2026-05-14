# Proyecto 1 - Controlador VGA con Reloj Digital

## Autores

- **Andrey Corella Chaves**
- **Allizon Castro Mesén**
- **Leandro Rojas Arias**

## Curso

**Taller de Diseño Digital - EL3313**

## Profesor

**Luis León Vega**

---

## Estado actual

**Proyecto implementado, integrado y verificado en FPGA.**

Se desarrolló un reloj digital en FPGA con salida VGA, ajuste manual mediante botones y switches, generación de imagen con fondo personalizado y visualización de hora en formato digital. El diseño utiliza una arquitectura modular basada en memoria de video, generación de imagen y control VGA.

---

## Objetivo

Diseñar e implementar un sistema en FPGA capaz de:

- Generar una señal VGA con resolución de `640x480`.
- Mostrar un reloj digital en formato de 24 horas.
- Permitir el ajuste manual de horas, minutos y segundos.
- Construir la imagen final a partir de un fondo y un renderizador de dígitos.
- Almacenar el frame final en VRAM.
- Visualizar el contenido mediante un controlador VGA.

---

## Arquitectura general

El sistema se integra en el módulo superior `top_clock_vga`, el cual conecta los principales bloques funcionales del proyecto:

- Generación de relojes y sincronización de reset.
- Acondicionamiento de entradas físicas.
- Base de tiempo de 1 Hz.
- Control de hora.
- Generación de imagen.
- Memoria de video de doble puerto.
- Controlador VGA.

### Flujo general del diseño

1. `clock_manager` genera los relojes `clk_sys` y `clk_pix`.
2. `reset_sync` sincroniza el reset en los dominios de reloj correspondientes.
3. Los botones y switches se acondicionan antes de ingresar a `clock_control`.
4. `time_base` genera la señal `tick_1Hz_en`.
5. `clock_control` mantiene y actualiza las señales `hh`, `mm` y `ss`.
6. `image_generator` construye el frame completo.
7. `vram_dual_port` almacena el frame final.
8. `vga_controller` lee la VRAM y genera las señales VGA de salida.

---

## Estructura del proyecto

```text
.
├── assets_image/      # Imagen fuente utilizada como fondo
├── build/             # Archivos generados durante simulación o construcción
├── constraints/       # Archivo de constraints de la FPGA
├── docs/              # Documentación técnica, especificaciones y diagramas
├── mem_image/         # Archivos .mem y preview del fondo convertido
├── rtl/               # Módulos HDL del diseño
├── scripts/           # Scripts auxiliares
└── tb/                # Testbenches
```

---

## Módulos implementados

### `rtl/common`

- `clock_manager`
- `reset_sync`

### `rtl/input`

- `sync_2ff`
- `debouncer`
- `edge_detector`

### `rtl/time`

- `time_base`
- `clock_control`

### `rtl/video`

- `font_rom`
- `digit_renderer`
- `background_rom`
- `background_generator`
- `vram_writer_fsm`
- `image_generator`

### `rtl/mem`

- `vram_dual_port`

### `rtl/vga`

- `vga_timing`
- `vram_read_addr_gen`
- `pixel_output_logic`
- `vga_controller`

### `rtl/top`

- `top_clock_vga`

---

## Generación de imagen

La imagen mostrada en pantalla se compone de dos elementos principales:

- Un fondo generado a partir de una imagen base.
- Un reloj digital centrado, dibujado en color blanco.

### Fondo

El fondo se obtiene mediante la conversión de una imagen fuente al formato requerido por el diseño.

Características principales:

| Parámetro | Valor |
|---|---|
| Resolución base | `240x240` |
| Formato de color | `RGB444` |
| Resolución visible del fondo | `480x480` |
| Posición en pantalla | Centrado horizontalmente |
| Márgenes laterales | `80 px` a cada lado |

La conversión se realiza con el script:

```text
scripts/img_to_mem.py
```

Este script genera los siguientes archivos:

```text
mem_image/background_240x240.mem
mem_image/background_240x240_preview.png
```

### Reloj digital

El reloj digital presenta las siguientes características:

- Fuente de `8x8` píxeles.
- Escalado para obtener un tamaño visible adecuado.
- Posicionamiento centrado en pantalla.
- Color blanco: `12'hFFF`.
- Formato de 24 horas.

---

## Memoria de video

### `background_rom`

Este módulo almacena la imagen base utilizada como fondo.

| Parámetro | Valor |
|---|---|
| Resolución | `240x240` |
| Profundidad | `57600` posiciones |
| Formato de color | `RGB444` |

### `vram_dual_port`

Este módulo almacena el frame final que se muestra en pantalla.

| Parámetro | Valor |
|---|---|
| Resolución visible | `640x480` |
| Profundidad real | `307200` posiciones |
| Formato de color | `RGB444` |
| Puerto de escritura | Desde `image_generator` |
| Puerto de lectura | Desde `vga_controller` |

La profundidad de la VRAM se limitó a `307200` posiciones para evitar el sobredimensionamiento de BRAM y permitir una implementación adecuada en la **Nexys A7-100T**.

---

## Interfaz de usuario

El sistema utiliza las siguientes entradas físicas:

| Señal | Función |
|---|---|
| `btn_up_raw` | Incrementa el campo seleccionado |
| `btn_down_raw` | Decrementa el campo seleccionado |
| `sw_edit_raw` | Activa o desactiva el modo de edición |
| `sw_hh_raw` | Selecciona el campo de horas |
| `sw_mm_raw` | Selecciona el campo de minutos |
| `sw_ss_raw` | Selecciona el campo de segundos |

### Modos de operación

| Condición | Comportamiento |
|---|---|
| `sw_edit_raw = 0` | El reloj avanza normalmente |
| `sw_edit_raw = 1` | El reloj entra en modo de edición |
| `sw_hh_raw = 1` | Se editan las horas |
| `sw_mm_raw = 1` | Se editan los minutos |
| `sw_ss_raw = 1` | Se editan los segundos |
| `btn_up_raw` | Incrementa el campo seleccionado |
| `btn_down_raw` | Decrementa el campo seleccionado |

---

## Salida VGA

El módulo superior genera las siguientes señales VGA:

```verilog
vga_hsync
vga_vsync
vga_r[3:0]
vga_g[3:0]
vga_b[3:0]
```

El sistema trabaja con temporización VGA estándar para una resolución de `640x480`.

---

## Verificación

Durante el desarrollo se realizaron testbenches por módulo y pruebas de integración. Las verificaciones incluyeron:

- Acondicionamiento de entradas.
- Base de tiempo.
- Control de hora.
- Escritura y lectura de VRAM.
- Temporización VGA.
- Generación de imagen.
- Integración final del módulo `top_clock_vga`.

Además, se verificó el funcionamiento integral del diseño en la FPGA **Nexys A7-100T**.

---

## Scripts auxiliares

| Script | Descripción |
|---|---|
| `scripts/img_to_mem.py` | Convierte la imagen fuente al archivo `.mem` utilizado por la ROM de fondo |
| `scripts/run_all_sims.sh` | Automatiza la ejecución de simulaciones auxiliares del proyecto |

---

## Documentación técnica

La documentación principal del proyecto se encuentra en:

```text
docs/specs/control_hora.md
docs/specs/memoria_video.md
docs/specs/interfaces.md
docs/diagrams/block_diagram.md
```

---
## Consumo general de recursos 
| Módulo        | Slice LUTs | Slice Registers | F7 Muxes | F8 Muxes | Slice | LUT as Logic | Block RAM Tile | DSPs | Bonded IOB | BUFGCTRL |
|----------------|------------|------------------|-----------|-----------|-------|---------------|----------------|------|-------------|-----------|
| top_clock_vga | 7780       | 186              | 736       | 110       | 2186  | 7780          | 120            | 2    | 22          | 2         |
## Resumen del diseño

Este proyecto implementa un reloj digital con salida VGA en una FPGA **Nexys A7-100T**. El sistema integra control de tiempo, acondicionamiento de entradas, generación de imagen, almacenamiento en VRAM y visualización VGA. La arquitectura modular facilita la simulación, integración y depuración de cada bloque funcional.

## Nota sobre el uso de Inteligencia Artificial

Durante el desarrollo de este proyecto se utilizó IA como herramienta de apoyo académico y técnico. Su uso estuvo orientado a la consulta de conceptos, resolución de dudas, revisión de errores, análisis de problemas durante la implementación, apoyo en la generación y depuración de código, así como en la organización y mejora de la documentación del repositorio.

La herramienta también fue utilizada para orientar decisiones relacionadas con la arquitectura modular del diseño, la estructura del proyecto, el flujo de trabajo con Git, la redacción de archivos técnicos y la preparación de explicaciones sobre los distintos módulos implementados.

Todo el contenido generado o sugerido mediante IA fue revisado, adaptado y validado por los integrantes del grupo antes de incorporarse al proyecto.

Enlace al chat utilizado como apoyo:

[Chat de apoyo con IA](https://chatgpt.com/share/69f68f8b-9de4-83e8-95f5-0abaa59b9517)