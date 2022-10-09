# PNG512
A `i386` bootsector rickroll.
> A custom image can be displayed in place of the rickroll.


## Space
You can use images with less than (approximatively) `812` pixels
`(512 - 106) * 2 = 812`:
- `512` bytes, size of bootsector
- `106` bytes, size of code
- `2` pixels / byte

Depending on the opcodes pixels create, there could be less space available.

Image can't be larger than `255` pixels.


## How to use
1. Craft your PNG with a paint like software, using the [BIOS color palette](https://github.com/Chiogros/PNG512#color-palette)
2. Generate the bytecode of your image with `png2hex.py`
```Bash
$ python png2hex.py rick.png
```
3. Paste the bytecode in `rick.asm`, after setting `width` and `height`
```ASM
img:
    .width     db    27
    .height    db    29
    .pixels    db    0xff,0xab,...
```
4. Compile (you need the `make` package)
```Bash
$ make
nasm -f bin rick.asm
```
6. Run in a QEMU environment (you need `qemu` and `qemu-system-i386` packages)
```Bash
$ make run
qemu-system-i386 -display spice-app -fda rick
```


### Color palette
When drawing your PNG, you need to use these colors:
| Color         | Hex       |
| ------------- | --------- |
| Dark          | `#000000` |
| Blue          | `#0000AA` |
| Green         | `#00AA00` |
| Cyan          | `#00AAAA` |
| Red           | `#AA0000` |
| Magenta       | `#AA00AA` |
| Brown         | `#AA5500` |
| Light gray    | `#AAAAAA` |
| Dark gray     | `#555555` |
| Light blue    | `#5555FF` |
| Light green   | `#55FF55` |
| Light cyan    | `#55FFFF` |
| Light red     | `#FF5555` |
| Light magenta | `#FF55FF` |
| Yellow        | `#FFFF55` |
| White         | `#FFFFFF` |

Reference: [BIOS color attributes](https://en.wikipedia.org/wiki/BIOS_color_attributes)


## Images
![Rickroll pixel art](https://github.com/Chiogros/PNG512/raw/main/images/rick.png)
![Rickroll on x86-i386 QEMU](https://github.com/Chiogros/PNG512/raw/main/images/rick.png)


