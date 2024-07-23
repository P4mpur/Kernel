FILES = ./build/kernel.asm.o

all: ./bin/boot.bin ./bin/kernel.bin
	rm -rf ./bin/os.bin
	dd if=./bin/boot.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin

./bin/kernel.bin: $(FILES)
	@echo "Linking kernel object files..."
	i686-elf-ld -g -relocatable $(FILES) -o ./build/kernelfull.o
	@echo "Creating kernel binary..."
	i686-elf-gcc -T ./src/linker.ld -o ./bin/kernel.bin -ffreestanding -O0 -nostdlib ./build/kernelfull.o

./bin/boot.bin: ./src/boot/boot.asm
	@echo "Assembling boot sector..."
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot.bin

./build/kernel.asm.o: ./src/kernel.asm
	@echo "Assembling kernel..."
	nasm -f elf -g ./src/kernel.asm -o ./build/kernel.asm.o 

clean: 
	rm -rf ./bin/boot.bin
	@echo "Cleaned build files."
