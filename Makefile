all: 
	nasm -f bin rick.asm

run:
	qemu-system-i386 -display spice-app -fda rick

run-debug:
	qemu-system-i386 -s -S -fda rick

clean:
	rm rick
