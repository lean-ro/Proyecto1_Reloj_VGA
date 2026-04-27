## Arquitectura General del Proyecto

El sistema está diseñado bajo una arquitectura modular donde cada bloque tiene una función clara y se comunica con los demás de forma organizada. A continuación, se describen brevemente los componentes principales:

### 1. Bloques Principales
*   **Reloj y Reset:** Se encarga de recibir la señal de la tarjeta y generar las diferentes velocidades (relojes) necesarias para que el video y la lógica del tiempo funcionen sincronizados.
*   **Preparación de entradas:** Este bloque limpia las señales de los **botones y switches**. Elimina el ruido físico (rebotes) para que, al presionar un botón, el sistema entienda una instrucción única y clara.
*   **clock_controll:** Lleva la cuenta de los segundos, minutos y horas, y permite el ajuste del tiempo mediante las entradas ya procesadas.
*   **image_generator:** Toma los datos numéricos del control de hora y decide qué colores y formas se deben "dibujar" para representar el reloj en la pantalla.
*   **vram_dual_port:** Funciona como un puente donde el generador de imagen guarda la información visual y el controlador de video la recoge. Al ser de "doble puerto", ambos procesos pueden ocurrir al mismo tiempo sin chocarse.
*   **vga_controller:** Es el encargado de la salida. Genera los tiempos exactos que necesita el monitor para mostrar la imagen de forma estable y fluida.

### 2. Conectividad y Flujo del Sistema
El funcionamiento sigue una ruta lógica:
1.  **Entradas:** Mediante botones y switches de la FPGA.
2.  **Procesamiento:** Las señales se limpian, el tiempo se calcula y la imagen se genera.
3.  **Memoria:** Toda la información visual se deposita en la VRAM.
4.  **Salida:** El controlador VGA toma lo que hay en la memoria y lo envía directamente al Monitor.

### 3. Criterio de Modularidad
La arquitectura se basa en la separación de responsabilidades:
*   **Independencia:** El bloque que cuenta el tiempo no necesita saber cómo funciona un monitor, y el bloque que genera el video no necesita saber cómo se calcula una hora. Solo comparten información a través de conexiones específicas.
*   **Facilidad de mantenimiento:** Si se desea cambiar la apariencia del reloj, solo se modifica el `image_generator`. Si se desea cambiar la resolución, solo se ajusta el `vga_controller`. Esto hace que el diseño sea robusto y fácil de probar paso a paso.