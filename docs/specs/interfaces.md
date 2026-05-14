# Especificación de interfaces del proyecto

## 1. Propósito
Este documento resume las interfaces principales del sistema `top_clock_vga`, incluyendo:
- puertos de entrada y salida
- señales internas relevantes
- relación entre módulos
- dominios de reloj
- flujo general de interconexión

La descripción corresponde a la implementación final validada mediante simulación e integración.

---

## 2. Módulo superior
El sistema se integra en el módulo:
- `top_clock_vga`

Este módulo conecta los bloques principales del proyecto:
- generación de relojes
- sincronización de reset
- acondicionamiento de entradas
- control de hora
- generación de imagen
- memoria de video
- salida VGA

---

## 3. Puertos del `top_clock_vga`

### 3.1 Entradas
El módulo superior recibe:
- `clk100`: reloj principal de la Nexys A7 a `100 MHz`
- `rst_raw`: reset crudo del sistema
- `btn_up_raw`: botón para incrementar el campo seleccionado
- `btn_down_raw`: botón para decrementar el campo seleccionado
- `sw_edit_raw`: habilita el modo de edición
- `sw_hh_raw`: selecciona edición de horas
- `sw_mm_raw`: selecciona edición de minutos
- `sw_ss_raw`: selecciona edición de segundos

### 3.2 Salidas
El módulo superior entrega las señales VGA:
- `vga_hsync`: sincronismo horizontal
- `vga_vsync`: sincronismo vertical
- `vga_r[3:0]`: canal rojo
- `vga_g[3:0]`: canal verde
- `vga_b[3:0]`: canal azul

---

## 4. Dominios de reloj
El diseño utiliza dos dominios principales.

### 4.1 `clk_sys`
Reloj del sistema generado por `clock_manager`.

- frecuencia: `100 MHz`

Se usa en:
- acondicionamiento de entradas
- `time_base`
- `clock_control`
- `image_generator`
- puerto de escritura de `vram_dual_port`

### 4.2 `clk_pix`
Reloj de pixeles generado por `clock_manager`.

- frecuencia: `25 MHz`

Se usa en:
- `vga_controller`
- puerto de lectura de `vram_dual_port`

---

## 5. Resets
El reset crudo `rst_raw` se sincroniza por separado en cada dominio.

### 5.1 `rst_sys`
Generado por `reset_sync` en el dominio `clk_sys`.

Se usa en:
- módulos de entrada
- `time_base`
- `clock_control`
- `image_generator`

### 5.2 `rst_pix`
Generado por `reset_sync` en el dominio `clk_pix`.

Se usa en:
- `vga_controller`

---

## 6. Interfaces de entradas de usuario

### 6.1 Botones
Cada botón sigue la cadena:
`raw -> sync_2ff -> debouncer -> edge_detector`

Señales principales:
- `btn_up_raw -> btn_up_sync -> btn_up_clean -> btn_up_pulse`
- `btn_down_raw -> btn_down_sync -> btn_down_clean -> btn_down_pulse`

Las señales `btn_up_pulse` y `btn_down_pulse` se conectan a `clock_control`.

### 6.2 Switches
Cada switch se sincroniza mediante `sync_2ff`.

Señales finales:
- `sw_edit`
- `sw_hh`
- `sw_mm`
- `sw_ss`

Estas señales se conectan a `clock_control`.

---

## 7. Interface de control de hora

### 7.1 `time_base`
Genera el pulso de avance del reloj.

Entradas:
- `clk`
- `rst`

Salida:
- `tick_1Hz_en`

### 7.2 `clock_control`
Controla el tiempo actual del reloj digital.

Entradas:
- `clk`
- `rst`
- `tick_1Hz_en`
- `sw_edit`
- `sw_hh`
- `sw_mm`
- `sw_ss`
- `btn_up`
- `btn_down`

Salidas:
- `hh [5:0]`
- `mm [5:0]`
- `ss [5:0]`

Estas salidas alimentan a `image_generator`.

---

## 8. Interface del generador de imagen

### 8.1 `image_generator`
Construye el frame completo que se escribe en la VRAM.

Entradas:
- `clk`
- `rst`
- `hh [5:0]`
- `mm [5:0]`
- `ss [5:0]`
- `start`

Salidas:
- `wr_en`
- `wr_addr [18:0]`
- `wr_data [11:0]`
- `busy`
- `frame_done`

Integra internamente:
- `background_generator`
- `digit_renderer`
- `vram_writer_fsm`

---

## 9. Interface de memoria de video

### 9.1 `vram_dual_port`
Memoria principal de video con escritura y lectura simultánea.

#### Puerto de escritura
Conectado a `image_generator`.

Entradas:
- `clk_wr`
- `we_wr`
- `addr_wr [18:0]`
- `data_in [11:0]`

#### Puerto de lectura
Conectado a `vga_controller`.

Entradas:
- `clk_rd`
- `addr_rd [18:0]`

Salida:
- `data_out [11:0]`

La profundidad real de la VRAM es `307200`, correspondiente a una resolución visible de `640x480`.

---

## 10. Interface del bloque VGA

### 10.1 `vga_controller`
Controla la lectura de video y genera la salida VGA.

Entradas:
- `clk`
- `rst`
- `pixel_data [11:0]`

Salidas:
- `rd_addr [18:0]`
- `hsync_out`
- `vsync_out`
- `rgb_out [11:0]`

Integra internamente:
- `vga_timing`
- `vram_read_addr_gen`
- `pixel_output_logic`

### 10.2 `vga_timing`
Genera la temporización VGA y las coordenadas del píxel actual.

Salidas:
- `hsync`
- `vsync`
- `video_on`
- `pixel_x [9:0]`
- `pixel_y [9:0]`

### 10.3 `vram_read_addr_gen`
Convierte las coordenadas visibles en una dirección lineal de lectura.

Entradas:
- `pixel_x`
- `pixel_y`
- `video_on`

Salida:
- `rd_addr`

### 10.4 `pixel_output_logic`
Define la salida final de video.

Entradas:
- `hsync_in`
- `vsync_in`
- `video_on`
- `pixel_data`

Salidas:
- `hsync_out`
- `vsync_out`
- `rgb_out`

Comportamiento:
- si `video_on = 1`, muestra `pixel_data`
- si `video_on = 0`, fuerza negro

---

## 11. Interface del fondo y del reloj

### 11.1 `background_rom`
Almacena la imagen base del fondo.

Entrada:
- `addr [15:0]`

Salida:
- `bg_data [11:0]`

Carga su contenido desde:
- `background_240x240.mem`

### 11.2 `background_generator`
Genera el color de fondo para cada coordenada VGA.

Entradas:
- `pixel_x [9:0]`
- `pixel_y [9:0]`

Salida:
- `bg_color [11:0]`

Este módulo:
- centra la imagen horizontalmente
- escala la imagen de `240x240` a `480x480`
- genera márgenes laterales oscuros

### 11.3 `font_rom`
Define la forma de los caracteres del reloj.

Entradas:
- `char_code [3:0]`
- `row [2:0]`
- `col [2:0]`

Salida:
- `pixel_on`

Incluye:
- dígitos `0` a `9`
- símbolo `:`

### 11.4 `digit_renderer`
Determina si un píxel pertenece al texto del reloj.

Entradas:
- `hh [5:0]`
- `mm [5:0]`
- `ss [5:0]`
- `pixel_x [9:0]`
- `pixel_y [9:0]`

Salida:
- `pixel_on`

En la implementación final:
- el reloj se dibuja en blanco
- no se usa borde negro
- el texto está centrado
- se usa una fuente `8x8` escalada

---

## 12. Interface del escritor de VRAM

### 12.1 `vram_writer_fsm`
Recorre la pantalla visible y decide qué color escribir en cada posición de la VRAM.

Entradas:
- `clk`
- `rst`
- `start`
- `bg_color [11:0]`
- `clock_fill_on`
- `clock_border_on`

Salidas:
- `pixel_x [9:0]`
- `pixel_y [9:0]`
- `wr_en`
- `wr_addr [18:0]`
- `wr_data [11:0]`
- `busy`
- `frame_done`

Prioridad de color:
1. relleno del reloj
2. borde del reloj
3. fondo

En la versión final, `clock_border_on` quedó desactivado.

---

## 13. Señales internas relevantes del top

### Relojes
- `clk_sys`
- `clk_pix`

### Resets
- `rst_sys`
- `rst_pix`

### Entradas limpias
- `btn_up_pulse`
- `btn_down_pulse`
- `sw_edit`
- `sw_hh`
- `sw_mm`
- `sw_ss`

### Tiempo
- `tick_1Hz_en`
- `hh`
- `mm`
- `ss`

### Control de redibujado
- `img_start`
- `img_busy`
- `img_frame_done`
- `prev_hh`
- `prev_mm`
- `prev_ss`
- `redraw_pending`

### Escritura de imagen
- `wr_en`
- `wr_addr`
- `wr_data`

### Lectura de video
- `rd_addr`
- `pixel_data_from_vram`

### Video final
- `rgb_out`

---

## 14. Flujo de interconexión general
El flujo general del sistema es:
1. `clk100` entra a `clock_manager` y genera `clk_sys` y `clk_pix`
2. `rst_raw` se sincroniza como `rst_sys` y `rst_pix`
3. botones y switches crudos se acondicionan antes de llegar a `clock_control`
4. `time_base` genera `tick_1Hz_en`
5. `clock_control` genera `hh`, `mm` y `ss`
6. `image_generator` construye el frame y escribe en `vram_dual_port`
7. `vga_controller` lee la VRAM y genera las señales VGA finales