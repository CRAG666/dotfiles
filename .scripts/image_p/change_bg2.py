import argparse

import cv2
import numpy as np


def hex_to_rgb(hex_color):
    # Convertir el color hexadecimal a RGB
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4))


def cambiar_color_fondo(imagen_path, nuevo_color, color_fondo, tolerancia=50):
    # Cargar la imagen utilizando OpenCV
    imagen = cv2.imread(imagen_path)

    # Convertir los colores de nuevo y color_fondo a formato de NumPy
    nuevo_color_np = np.array(nuevo_color[::-1])  # Cambiamos el orden a BGR para OpenCV
    color_fondo_np = np.array(color_fondo[::-1])  # Cambiamos el orden a BGR para OpenCV

    # Definir los límites del rango de colores a reemplazar (con tolerancia)
    limite_inferior = np.array([c - tolerancia for c in color_fondo_np])
    limite_superior = np.array([c + tolerancia for c in color_fondo_np])

    # Crear una máscara de píxeles dentro del rango de colores a reemplazar
    mascara_fondo = cv2.inRange(imagen, limite_inferior, limite_superior)

    # Encontrar los contornos de las figuras en la imagen
    contornos, _ = cv2.findContours(
        mascara_fondo, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE
    )

    # Crear una máscara de contornos en blanco
    mascara_contornos = np.zeros(imagen.shape[:2], dtype=np.uint8)

    # Dibujar los contornos en la máscara de contornos
    cv2.drawContours(mascara_contornos, contornos, -1, 255, thickness=cv2.FILLED)

    # Reemplazar el color de fondo con el nuevo color en la imagen original usando la máscara de contornos
    imagen[np.where(mascara_contornos == 255)] = nuevo_color_np

    # Guardar la imagen modificada
    cv2.imwrite("imagen_modificada.png", imagen)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Cambia el color de fondo de una imagen."
    )
    parser.add_argument("imagen_path", type=str, help="Ruta de la imagen a modificar.")
    parser.add_argument(
        "nuevo_color",
        type=str,
        help="Nuevo color de fondo en formato hexadecimal (e.g., #FFFFFF para blanco).",
    )
    parser.add_argument(
        "color_fondo",
        type=str,
        help="Color de fondo actual que se reemplazará en formato hexadecimal.",
    )
    parser.add_argument(
        "--tolerancia",
        type=int,
        default=50,
        help="Tolerancia para la detección de colores similares (valor entre 0 y 255).",
    )
    args = parser.parse_args()

    imagen_path = args.imagen_path
    nuevo_color = hex_to_rgb(args.nuevo_color)
    color_fondo = hex_to_rgb(args.color_fondo)
    tolerancia = max(0, min(args.tolerancia, 255))

    cambiar_color_fondo(imagen_path, nuevo_color, color_fondo, tolerancia)
