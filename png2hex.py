#!/bin/python

import sys
from PIL import Image

colors = {
    (  0,   0,   0): '0',
    (  0,   0, 170): '1',
    (  0, 170,   0): '2',
    (  0, 170, 170): '3',
    (170,   0,   0): '4',
    (170,   0, 170): '5',
    (170,  85,   0): '6',
    (170, 170, 170): '7',
    ( 85,  85,  85): '8',
    ( 85,  85, 255): '9',
    ( 85, 255,  85): 'a',
    ( 85, 255, 255): 'b',
    (255,  85,  85): 'c',
    (255,  85, 255): 'd',
    (255, 255,  85): 'e',
    (255, 255, 255): 'f'
}


def png2hex(filename):
    with Image.open(filename) as img:
        (width, height) = img.size
        print("Image is", width, "x", height, "pixels.")
        print("Please make sure image is not too large, check README.md.\n")

        bytes = []
        first_px_pair = 0

        # Loop over image pixels
        for y in range(height):
            for x in range(width):
                # Get pixel color
                px = img.getpixel((x, y))

                # Ignore alpha value
                (r, g, b, _) = px
                px = (r, g, b)

                # Check color is part of BIOS colors list
                if px not in colors:
                    print(f"{px} at ({x}, {y}) is not allowed!")
                    print(f"Color must be in: {colors.keys()}")
                    return

                # Pixels are encoded over 4 bits, so we can set 2 px / bytes.
                # We check if we have a 2nd pixel to build a byte.
                is_odd_px = (y * width + x) % 2
                if is_odd_px:
                    # Build byte with two pixels value
                    bytes.append("0x" +
                                 colors.get(px) +
                                 colors.get(first_px_pair))
                else:
                    # Store px for later byte build
                    first_px_pair = px

        # Print bytecode
        print("Bytecode of the image, to use in .asm file: ")
        print(','.join(bytes))


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} path/to/image.png")
        sys.exit(1)

    png2hex(sys.argv[1])
