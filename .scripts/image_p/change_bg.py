import argparse

import pixellib
from pixellib.tune_bg import alter_bg


def hex_to_rgb(hex_color) -> tuple:
    return tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4))


def change_bg_color(image: str, bg_color: str):
    change_bg = alter_bg()
    change_bg.load_pascalvoc_model("deeplabv3_xception_tf_dim_ordering_tf_kernels.h5")
    change_bg.color_bg(
        image, colors=hex_to_rgb(bg_color), output_image_name="colored_bg.jpg"
    )


if __name__ == "__main__":
    # Parsear los argumentos de la línea de comandos
    parser = argparse.ArgumentParser(
        description="Cambiar el fondo de una imagen a un color específico en formato hexadecimal"
    )
    parser.add_argument("image", help="Ruta de la imagen de entrada")
    parser.add_argument(
        "--bg-color",
        default="FFFFFF",
        help="Color de fondo en formato hexadecimal (por defecto, blanco)",
    )

    args = parser.parse_args()
    change_bg_color(args.image, args.bg_color)
