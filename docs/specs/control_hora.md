# Especificación del módulo `clock_control`

## 1. Propósito
El módulo `clock_control` implementa la lógica principal del reloj digital en formato de 24 horas. Se encarga de:
- mantener los valores de `hh`, `mm` y `ss`
- avanzar el tiempo mediante `tick_1Hz_en`
- permitir edición manual de horas, minutos y segundos
- congelar el conteo automático durante la edición

El módulo trabaja en el dominio de reloj `clk_sys`.

---

## 2. Formato del reloj
El reloj utiliza formato de 24 horas:
- horas: `00` a `23`
- minutos: `00` a `59`
- segundos: `00` a `59`

Después de `23:59:59`, el siguiente incremento produce `00:00:00`.

---

## 3. Entradas del módulo
El módulo recibe las siguientes señales:
- `clk`: reloj del sistema
- `rst`: reset síncrono
- `tick_1Hz_en`: pulso de un ciclo para avanzar un segundo
- `sw_edit`: habilita el modo de edición
- `sw_hh`: selecciona edición de horas
- `sw_mm`: selecciona edición de minutos
- `sw_ss`: selecciona edición de segundos
- `btn_up`: incrementa el campo seleccionado
- `btn_down`: decrementa el campo seleccionado

Los botones llegan como pulsos limpios de un ciclo, después de pasar por:
- `sync_2ff`
- `debouncer`
- `edge_detector`

Los switches llegan sincronizados mediante `sync_2ff`.

---

## 4. Salidas del módulo
Las salidas son:
- `hh [5:0]`
- `mm [5:0]`
- `ss [5:0]`

Estas señales representan la hora actual y son utilizadas por `image_generator` para mostrar el reloj en pantalla.

---

## 5. Modo normal de operación
Cuando `sw_edit = 0`, el módulo funciona en modo normal.

En este modo:
- ignora `btn_up` y `btn_down`
- actualiza el tiempo solo cuando `tick_1Hz_en = 1`

La lógica de conteo es:
1. incrementa `ss`
2. si `ss = 59`, reinicia segundos e incrementa `mm`
3. si `mm = 59`, reinicia minutos e incrementa `hh`
4. si `hh = 23`, reinicia horas a `00`

---

## 6. Modo de edición
Cuando `sw_edit = 1`, el módulo entra en modo de edición.

En este modo:
- el conteo automático se congela
- el tiempo solo cambia con `btn_up` y `btn_down`

### 6.1 Selección válida
La edición solo ocurre si exactamente uno de estos switches está activo:
- `sw_hh`
- `sw_mm`
- `sw_ss`

Combinaciones válidas:
- `100` → editar horas
- `010` → editar minutos
- `001` → editar segundos

### 6.2 Selección inválida
Si ningún switch está activo o más de uno está activo, no se modifica ningún campo.

---

## 7. Edición manual de cada campo

### 7.1 Horas
Si `sw_hh = 1` y la selección es válida:
- `btn_up` incrementa `hh`
- `btn_down` decrementa `hh`

El valor es circular entre `00` y `23`.

### 7.2 Minutos
Si `sw_mm = 1` y la selección es válida:
- `btn_up` incrementa `mm`
- `btn_down` decrementa `mm`

El valor es circular entre `00` y `59`.

### 7.3 Segundos
Si `sw_ss = 1` y la selección es válida:
- `btn_up` incrementa `ss`
- `btn_down` decrementa `ss`

El valor es circular entre `00` y `59`.

---

## 8. Relación con otros módulos
`clock_control` se integra con los siguientes bloques:

### 8.1 `time_base`
Genera `tick_1Hz_en` para avanzar el reloj en modo normal.

### 8.2 `sync_2ff`, `debouncer`, `edge_detector`
Acondicionan botones y switches antes de ingresar al módulo.

### 8.3 `image_generator`
Usa `hh`, `mm` y `ss` para dibujar el reloj.

### 8.4 `top_clock_vga`
Instancia `clock_control` y lo conecta con los módulos de entrada y video.