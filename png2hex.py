#!/bin/python

import sys
from PIL import Image

# BIOS colors
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


def get_px_colors(img) -> []:
    (width, height) = img.size

    px_colors = []

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

            px_colors.append(colors.get(px))

    return px_colors


def colors2asm(px_colors) -> []:
    words_and_bytes = []
    words_and_bytes.append([])  # Store words
    words_and_bytes.append([])  # Store last byte (if any)

    # If odd number of pixels, add a pixel, which will not be displayed
    # but the last pixel will be stored on a byte with it.
    if len(px_colors) % 2:
        px_colors.append('0')

    # Make words list
    while len(px_colors) >= 4:
        word = ''
        # Get a 4 pixels word
        for i in range(4):
            word += px_colors.pop(0)
        # Reverse them all, for little-endian
        word = word [::-1]

        # Write the hex code
        word_hex = "0x" + word
        words_and_bytes[0].append(word_hex)

    # Make last byte
    if len(px_colors) == 2:
        words_and_bytes[1].append("0x"
                                  + px_colors.pop(1)    # Reverse order for little endian
                                  + px_colors.pop(0))

    return words_and_bytes


def png2hex(filename):
    with Image.open(filename) as img:
        print("Image is", img.width, "x", img.height, "pixels.")
        print("Please make sure image is not too large, check README.md.\n")

        px_colors = get_px_colors(img)
        words_and_bytes = colors2asm(px_colors)

        print("Bytecode of the image, to use in .asm file: ")
        # Print words
        print("\t.pixels\t\t\tdw\t", ', '.join(words_and_bytes[0]))
        # Print byte if any
        if len(words_and_bytes[1]):
            print("\t\t\t\tdb\t", words_and_bytes[1][0])


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"usage: {sys.argv[0]} path/to/image.png")
        sys.exit(1)

    png2hex(sys.argv[1])
