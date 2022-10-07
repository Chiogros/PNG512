org 0x7c00		; move to MBR start address
bits 16

; .rodata
img:
	.width:			db 	19h			; width  = 10
	.height:		db 	19h			; height = 5
	; Colors are encoded with 4 bits.
	; Hence, each byte has the color of two pixels:
	; | px1  | px2  |
	; | 0000 | 0000 |
	; see available colors -> https://en.wikipedia.org/wiki/BIOS_color_attributes
	.pixels:		db 	0xAA, 0xBB, 0xAA, 0xBB, 0xAA, 0xBB, 0xAA, 0xBB 


; .text
_start: 			mov 	ah, 00h			; set video mode
				mov 	al, 13h			; 320x200 graphic 256/256K col. VGA
				int 	10h			; video services

				xor 	bl, bl			; set y = 0

print_img:			cmp 	bl, [img.height]		; if all lines have been written
				je 	end
				push 	bx			; save y
				
				xor 	cl, cl			; initialize x = 0, as arg1
				call 	print_row

				pop 	bx			; get back row number
				inc 	bl			; iterate to the next line
				jmp 	print_img		; loop over lines

print_row:			cmp 	cl, [img.width]; if not all pixels have been written
				jb 	print_row_pixel
				ret

print_row_pixel:		push 	bx			; save y
				push 	cx			; save x
				call 	get_color

				pop 	cx			; restore x
				pop 	bx			; restore y
				xor 	dx, dx
				mov 	dl, bl			; set y in dx
				push 	bx			; save y
				push 	cx			; save x
				call 	print_pixel		; print pixel(ax: color, cx: x, dx: y)

				pop 	cx			; restore x
				pop 	bx			; restore y
				inc 	cl			; increase pixel index

				jmp 	print_row

get_color:			mov 	al, bl			;   y
				mov 	ah, [img.width]		;       width
				mul 	ah			;   y * width
				add 	ax, cx			;  (y * width) + x = pixel number
				
				xor	bx, bx			; clean up for division
				xor	cx, cx			; clean up for division
				xor	dx, dx			; clean up for division

				mov 	bx, 2h			; set divisor to 2, as colors are encoded over 4 bits
				div 	bx			; ((y * width) + x) / 2 = pixel byte number

				mov 	dx, ax			; used to copy al into bx
				and 	dx, 0x00FF		; keep al only

				mov 	bx, img.pixels		; &pixels[0]
				add 	bx, dx			; &pixels[pixel byte]

				mov 	cx, ax			; used to check if we are getting an even or odd pixel color
				mov 	ax, [bx]		; read byte 
				mov 	al, ah			; get odd pixel color

				cmp 	ch, 0			; if (pixel number % 2 == 0)
				je 	get_color_even_pixel
				;sar 	al, 4

get_color_even_pixel:		mov 	al, 0xC 
				ret

print_pixel:			mov 	ah, 0ch			; write graphics pixel
				mov 	bh, 0			; page number
				;mov 	al, 0xF
				;mov 	cx, 128
				;mov 	dx, 128
				int 	10h			; video services
				ret

end:				times 	510-($-$$) db 0		; padding
				dw 	0xAA55			; Boot signature
