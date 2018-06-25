# RISCV environment variable must be set

CC=$(RISCV)/bin/riscv64-unknown-linux-gnu-gcc
OBJCOPY=$(RISCV)/bin/riscv64-unknown-linux-gnu-objcopy
CFLAGS=-std=gnu11 -Wall -I. -nostartfiles -fno-common -g
LFLAGS=-static -nostdlib

dtb := $(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).dtb
$(dtb): $(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).dts
	dtc -I dts -O dtb -o $@ $<

.PHONY: dtb
dtb: $(dtb)

elf := $(BUILD_DIR)/vu190.elf
$(elf): vu190.S $(dtb)
	$(CC) $(CFLAGS) -DXIP_TARGET_ADDR=0x80000000 -DDEVICE_TREE='"$(dtb)"' $(LFLAGS) -o $@ $<

.PHONY: elf
elf: $(elf)

bin := $(BUILD_DIR)/vu190.bin
$(bin): $(elf)
	$(OBJCOPY) -O binary $< $@

.PHONY: bin
bin: $(bin)

hex := $(BUILD_DIR)/vu190.hex
$(hex): $(bin)
	od -t x4 -An -w4 -v $< > $@

.PHONY: hex
hex: $(hex)

romgen := $(BUILD_DIR)/rom.v
$(romgen): $(hex)
	$(rocketchip_dir)/scripts/vlsi_rom_gen $(ROMCONF) $< > $@

.PHONY: romgen
romgen: $(romgen)

.PHONY: clean
clean::
	rm -rf $(hex) $(elf) 
