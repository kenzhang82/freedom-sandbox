base_dir = $(abspath ..)
include $(base_dir)/Makefrag-srcs

CC      := $(RISCV_GCC)
OBJCOPY := $(RISCV_OBJCOPY)
OBJDUMP := $(RISCV_OBJDUMP)
CFLAGS  := -march=rv32imac -mabi=ilp32 -O2 -std=gnu11 -Wall -I. -nostartfiles -fno-common -g
LINKER  := xip.lds
LFLAGS  := -static -nostdlib

$(DTB): $(DTS)
	dtc -I dts -O dtb -o $@ $<

.PHONY: dtb
dtb: $(DTB)

elf := $(build_dir)/xip.elf
$(elf): xip.S $(DTB)
	$(CC) $(CFLAGS) -DXIP_TARGET_ADDR=0x20400000 -DDEVICE_TREE='"$(DTB)"' $(LFLAGS) -o $@ $<

.PHONY: elf
elf: $(elf)

bin := $(build_dir)/xip.bin
$(bin): $(elf)
	$(OBJCOPY) -O binary $< $@

.PHONY: bin
bin: $(bin)

hex := $(build_dir)/xip.hex
$(hex): $(bin)
	od -t x4 -An -w4 -v $< > $@

.PHONY: hex
hex: $(hex)

$(BOOTROM_VLOG): $(hex)
	python $(VLSI_ROM_GEN) $(BOOTROM_CONF) $< > $@

.PHONY: romvlog
romvlog: $(BOOTROM_VLOG)

.PHONY: clean
clean::
	rm -rf $(hex) $(elf)
