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
1. Craft your PNG with a paint like software, using the [BIOS color palette](https://github.com/Chiogros/RickSecRoll/blob/main/README.md#color-palette)
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
- Dark `rgb(  0,   0,   0)`
- Blue `rgb(  0,   0, 170)`
- Green `rgb(  0, 170,   0)`
- Cyan `rgb(  0, 170, 170)`
- Red `rgb(170,   0,   0)`
- Magenta `rgb(170,   0, 170)`
- Brown `rgb(170,  85,   0)`
- Light gray `rgb(170, 170, 170)`
- Dark gray `rgb( 85,  85,  85)`
- Light blue `rgb( 85,  85, 255)`
- Light green `rgb( 85, 255,  85)`
- Light cyan `rgb( 85, 255, 255)`
- Light red `rgb(255,  85,  85)`
- Light magenta `rgb(255,  85, 255)`
- Yellow `rgb(255, 255,  85)`
- White `rgb(255, 255, 255)`

Reference: [BIOS color attributes](https://en.wikipedia.org/wiki/BIOS_color_attributes)


## Images
![Rickroll pixel art](https://github.com/Chiogros/RickSecRoll/raw/main/images/rick.png)
![Rickroll on x86-i386 QEMU](https://github.com/Chiogros/RickSecRoll/raw/main/images/rick.png)


