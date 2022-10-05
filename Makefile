all: 
	nasm -f bin rick.asm

run:
	qemu-system-i386 rick

clean:
	rm rick
