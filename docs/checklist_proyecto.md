# Checklist

## 1. Memoria de Video (VRAM)
- Implementar de forma externa al controlador VGA.
- Configurarla como **Dual-Port** (lectura para VGA, escritura para actualización).
- Con capacidad para almacenar fondo (*background*) e información de texto.
- Utilizar **BRAM**.

## 2. Módulo Controlador VGA
- Generadores de sincronización (contadores horizontales y verticales).
- Lógica de control de señales (**HSYNC**, **VSYNC**, **Video Enable**).
- Acceso correcto a la VRAM para obtención de píxeles.

## 3. Módulo Generador de Imagen
- Lógica de escritura en la VRAM.
- Generación del fondo de pantalla.
- Renderizado de texto para la hora (tipografía y creatividad).

## 4. Módulo de Control de Hora
- Registro y contador de la hora actual.
- Ajuste de horas y minutos mediante switches y botones.
- Manejo de entradas con **debouncing** y sincronización.

## 5. Integración y Estándares de Diseño
- Módulo **Top** que integra todos los componentes.
- Diseño modular y jerárquico (separación combinacional/secuencial y control/datapath).
- Documentación en código con estilo **TerosHDL**.
- Repositorio Git usando **GitFlow** y Conventional Commits.
- Scripts para automatización de pruebas.