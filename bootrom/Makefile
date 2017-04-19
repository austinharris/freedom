bootrom_img ?= u500vu190devkit.img

GCC=riscv64-unknown-linux-gnu-gcc
OBJCOPY=riscv64-unknown-linux-gnu-objcopy

all: $(bootrom_img)

%.img: %.bin
	dd if=$< of=$@ bs=128 count=1

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

%.elf: %.S linker.ld
	$(GCC) -Tlinker.ld $< -nostdlib -static -Wl,--no-gc-sections -o $@
