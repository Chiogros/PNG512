org 0x7c00		; move to MBR start address

mov ah, 00h		; set video mode
mov al, 13h		; 320x200 graphic 256/256K col. VGA
int 10h			; video services

xor cl, cl		; set pixel number = 0

; Calculate pixel quantity
mov al, width
mov ah, height
mul al
push ax

print_rows:	cmp cl, height	; if all lines have been written
		je end
		push cx		; save y
		
		mov bl, cl	; y as arg0
		xor cl, cl	; initialize x = 0, as arg1
		call print_row_pixels

		pop cx		; get back row number
		add cl, 1	; iterate to the next line
		jmp print_rows	; loop over lines

print_row_pixels:	cmp cl, width	; if not all pixels have been written
			jne print_row_pixels_continue
			ret

print_row_pixels_continue:	push bx		; save y
				push cx		; save x
				call get_color

				pop cx		; restore x
				pop bx		; restore y
				push cx		; save x

				call print_pixel	; print pixel(ax: color, cx: x, dx: y)

				pop cx		; restore x
				add cl, 1
				jmp print_row_pixels

get_color:	mov al, bl
		mov ah, width
		mul ah		; y * width

		add ax, cx	; + x
		mov bx, img	; mv img[] addr in bx
		add bx, ax	; point to wanted char

		mov ax, [bx]	; read wanted char
		ret

print_pixel:	mov ah, 0ch	; write graphics pixel
		mov bh, 0	; page number
		;mov al, 4
		;mov cx, 128
		;mov dx, 128
		int 10h		; video services
		ret

end:

img 	db aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah, aah
width 	db 0x0F		; width  = 28
height 	db 02h		; height = 28

times 510-($-$$) db 0	; padding & magic number
dw 0xAA55		; Boot signature
