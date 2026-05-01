from PIL import Image
import os

# ==========================================
# Configuracion
# ==========================================
INPUT_IMAGE = "assets_image/background.jpeg"
OUTPUT_MEM = "mem_image/background_240x240.mem"
OUTPUT_PREVIEW = "mem_image/background_240x240_preview.png"

TARGET_SIZE = 240  # imagen base 240x240


def center_crop_to_square(image):
    """Recorta la imagen al cuadrado mas grande posible desde el centro."""
    width, height = image.size

    if width == height:
        return image

    side = min(width, height)

    left = (width - side) // 2
    top = (height - side) // 2
    right = left + side
    bottom = top + side

    return image.crop((left, top, right, bottom))


def rgb888_to_rgb444(r, g, b):
    """
    Convierte de 8 bits por canal a 4 bits por canal.
    Retorna un entero de 12 bits:
    RRRR GGGG BBBB
    """
    r4 = r >> 4
    g4 = g >> 4
    b4 = b >> 4

    value_12bit = (r4 << 8) | (g4 << 4) | b4
    return value_12bit


def main():
    # Verificar que exista la imagen
    if not os.path.exists(INPUT_IMAGE):
        print(f"Error: no se encontro la imagen '{INPUT_IMAGE}'")
        return

    # Abrir la imagen
    image = Image.open(INPUT_IMAGE).convert("RGB")

    # ==========================================
    # Mantener la imagen fiel:
    # recorte centrado a cuadrado
    # luego redimensionar a 240x240
    # ==========================================
    image = center_crop_to_square(image)
    image = image.resize((TARGET_SIZE, TARGET_SIZE), Image.LANCZOS)

    # Guardar preview para verificar como quedo
    image.save(OUTPUT_PREVIEW)

    # ==========================================
    # Crear archivo .mem
    # Cada linea = 1 pixel en formato RGB444
    # Orden: fila por fila
    # direccion = y * 240 + x
    # ==========================================
    with open(OUTPUT_MEM, "w") as mem_file:
        for y in range(TARGET_SIZE):
            for x in range(TARGET_SIZE):
                r, g, b = image.getpixel((x, y))
                pixel_12bit = rgb888_to_rgb444(r, g, b)

                # Escribir 3 digitos hexadecimales
                mem_file.write(f"{pixel_12bit:03X}\n")

    print("Conversion completada con exito.")
    print(f"Preview guardado en: {OUTPUT_PREVIEW}")
    print(f"Archivo MEM guardado en: {OUTPUT_MEM}")
    print(f"Total de pixeles escritos: {TARGET_SIZE * TARGET_SIZE}")


if __name__ == "__main__":
    main()