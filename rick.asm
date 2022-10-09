org 0x7c00		; move to MBR start address
bits 16			; we work with 16 bits


; .text
_start: 			mov 	ah, 00h			; set video mode
				mov 	al, 13h			; 320x200 graphic 256/256K col. VGA
				int 	10h			; video services

				xor 	bl, bl			; set y = 0


; .rodata
img:
	.width			db	27			; image width must be < 256
	.height			db	30			; image height must be < 256
	; Colors are encoded with 4 bits.
	; Hence, each byte has the color of two pixels:
	; | px1  | px2  |
	; | 0000 | 0000 |
	; | A    | A    |
	; So, you have to set: (width x height) / 2 bytes.
	; See available colors -> https://en.wikipedia.org/wiki/BIOS_color_attributes
	; PS: little endian, so if you want to display pixels 0x0123, you have to write 0x3210
	.pixels:
				dw	0x3210, 0x4567, 0x89ab, 0xcdff, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567, 0x89ab, 0xcdef, 0x0123, 0x4567
				db	0x89			; last byte, if it cannot be set in a word above


; .text
print_img:			cmp 	bl, [img.height]	; if all lines have been written
				je 	end
				push 	bx			; save y

				xor 	cl, cl			; initialize x = 0, as arg1
				call 	print_row

				pop 	bx			; get back row number
				inc 	bl			; iterate to the next line
				jmp 	print_img		; loop over lines

print_row:			cmp 	cl, [img.width]		; if not all pixels have been written
				jb 	print_row_pixel
				ret

print_row_pixel:		push 	bx			; save y
				push 	cx			; save x
				call 	get_color

				pop 	cx			; restore x
				pop 	bx			; restore y
				xor 	dx, dx			; reset dx
				mov 	dl, bl			; set y in dx
				push 	bx			; save y
				push 	cx			; save x
				call 	print_pixel		; print pixel(ax: color, cx: x, dx: y)

				pop 	cx			; restore x
				pop 	bx			; restore y
				inc 	cl			; increase pixel index

				jmp 	print_row		; loop over the next pixel

get_color:			mov 	al, bl			;   y
				mov 	ah, [img.width]		;       width
				mul 	ah			;   y * width
				add 	ax, cx			;  (y * width) + x = pixel number
				
				xor	bx, bx			; clean up for division
				xor	cx, cx			; clean up for division
				xor	dx, dx			; clean up for division

				mov 	bx, 2h			; set divisor to 2, as colors are encoded over 4 bits
				div 	bx			; ((y * width) + x) / 2 = pixel byte number

				mov 	bx, img.pixels		; &pixels
				add 	bx, ax			; &pixels[pixel byte]
				mov	bl, [bx]		; pixels[pixel byte]

				mov	al, 4			; bits to shift
				mul	dx			; ax = 0 || ax = 4

				mov	cl, al			; cl for dynamic shift number
				shr 	bl, cl			; shift pixel color if it's an odd pixel
				and	bl, 0Fh			; keep 4 last bits, in case there was no shifting
				mov	al, bl			; return pixel color
				ret

print_pixel:			mov 	ah, 0ch			; write graphics pixel
				mov 	bh, 0			; page number
				int 	10h			; video services
				ret

end: 				times 	510-($-$$) db 0		; padding
				dw 	0xAA55			; Boot signature
