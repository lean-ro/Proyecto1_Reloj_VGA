# Especificación de memoria de video

## 1. Propósito
La memoria de video del proyecto está compuesta por dos módulos principales:
1. `vram_dual_port`: almacena el frame visible final.
2. `background_rom`: almacena la imagen base de fondo.

Ambas memorias usan color RGB de 12 bits, compatible con la salida VGA de la Nexys A7.

---

## 2. Formato de color
El sistema utiliza color de `12 bits por pixel`.

La distribución es:
`RRRR GGGG BBBB`

Es decir:
- 4 bits para rojo
- 4 bits para verde
- 4 bits para azul

Ejemplos:
- `12'hFFF` → blanco
- `12'h000` → negro
- `12'h315` → color de la imagen de fondo
- `12'h130` → otro color de la imagen

La salida VGA se divide así:
- `vga_r = rgb_out[11:8]`
- `vga_g = rgb_out[7:4]`
- `vga_b = rgb_out[3:0]`

---

## 3. `vram_dual_port`

### 3.1 Función
El módulo `vram_dual_port` implementa la memoria principal de video.

Permite:
- escritura desde `image_generator`
- lectura simultánea desde `vga_controller`

Por eso se implementa como una memoria de doble puerto.

---

### 3.2 Puerto de escritura
Trabaja en el dominio `clk_sys` y es usado por `image_generator`.

Señales:
- `clk_wr`
- `we_wr`
- `addr_wr`
- `data_in`

Comportamiento:
- si `we_wr = 1`, escribe `data_in` en `addr_wr` en el flanco positivo de `clk_wr`

---

### 3.3 Puerto de lectura
Trabaja en el dominio `clk_pix` y es usado por `vga_controller`.

Señales:
- `clk_rd`
- `addr_rd`
- `data_out`

Comportamiento:
- en cada flanco positivo de `clk_rd`, `data_out` toma el valor almacenado en `addr_rd`
- la lectura es síncrona

---

### 3.4 Resolución visible y direccionamiento
El área visible VGA es de `640x480`.

Esto equivale a `307200 pixeles`.

La dirección lineal se calcula como:
`addr = pixel_y * 640 + pixel_x`

Ejemplos:
- `(0,0)` → dirección `0`
- `(1,0)` → dirección `1`
- `(0,1)` → dirección `640`

---

### 3.5 Profundidad de memoria
Aunque `ADDR_WIDTH = 19` permite direccionar hasta `2^19 = 524288`, la profundidad real se limita a:
- `DEPTH = 307200`

Esto evita consumir más Block RAM de la necesaria.

La memoria queda definida como:
- `DATA_WIDTH = 12`
- `ADDR_WIDTH = 19`
- `DEPTH = 307200`

Además:
- si `addr_wr >= DEPTH`, no se escribe
- si `addr_rd >= DEPTH`, se devuelve `0`

Esta corrección permite ajustar el diseño a la BRAM disponible en la Nexys A7-100T.

---

## 4. `background_rom`

### 4.1 Función
El módulo `background_rom` almacena la imagen base usada por `background_generator`.

Es una memoria de solo lectura cargada desde:
- `background_240x240.mem`

---

### 4.2 Resolución de la imagen base
La imagen de fondo se definió como:
- imagen base de `240x240`
- mostrada en pantalla como `480x480`
- centrada horizontalmente
- con márgenes oscuros de `80 px` a izquierda y derecha

Esto permite adaptar la imagen al formato VGA `640x480` sin deformarla.

---

### 4.3 Profundidad y direccionamiento
La imagen base tiene:
`240x240 = 57600 pixeles`

Por lo tanto:
- `DEPTH = 57600`

La dirección lineal se calcula como:
`addr = bg_y * 240 + bg_x`

donde:
- `bg_x` es la coordenada horizontal dentro de la imagen
- `bg_y` es la coordenada vertical dentro de la imagen

---

### 4.4 Carga del contenido
La ROM se inicializa con:
`$readmemh("background_240x240.mem", memory);`

El archivo `.mem` se genera mediante:
- `scripts/img_to_mem.py`

El script:
- recorta la imagen al centro
- la redimensiona a `240x240`
- convierte cada pixel a RGB444
- genera el archivo `.mem`
- genera un preview de verificación

---

## 5. `background_generator`

### 5.1 Función
El módulo `background_generator` usa `background_rom` para producir el color de fondo en cada coordenada VGA.

Entradas:
- `pixel_x`
- `pixel_y`

Salida:
- `bg_color`

---

### 5.2 Regiones de pantalla
La pantalla de `640x480` se divide así:
- margen izquierdo: `x = 0 ... 79`
- imagen: `x = 80 ... 559`
- margen derecho: `x = 560 ... 639`

Los márgenes laterales se llenan con negro:
- `12'h000`

---

### 5.3 Escalado
La imagen base de `240x240` se muestra como `480x480`.

Por eso se aplica escalado x2:
- `bg_x = (pixel_x - 80) >> 1`
- `bg_y = pixel_y >> 1`

Luego se calcula la dirección de la ROM:
`bg_addr = bg_y * 240 + bg_x`

---

## 6. Flujo completo de memoria de video
El flujo general del sistema es:
1. `image_generator` genera el color final de cada pixel
2. `vram_writer_fsm` recorre la pantalla visible
3. `vram_dual_port` almacena el frame resultante
4. `vga_controller` genera `rd_addr`
5. `vram_dual_port` entrega `pixel_data`
6. `vga_controller` produce `rgb_out`, `hsync_out` y `vsync_out`

Dentro de este flujo:
- `background_rom` y `background_generator` producen el fondo
- `digit_renderer` identifica los pixeles del reloj
- `vram_writer_fsm` selecciona entre fondo y reloj
- `vram_dual_port` almacena el resultado final