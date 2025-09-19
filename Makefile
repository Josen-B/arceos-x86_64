# ==========================
ARCH      ?= x86_64
TARGET    := x86_64-unknown-none
SMP       ?= 1
APP       ?= axorigin
APP_NAME  := $(shell basename $(APP))

LD_SCRIPT := $(CURDIR)/linker.lds
OUT_DIR   := $(CURDIR)/target/$(TARGET)/release

OUT_ELF   := $(OUT_DIR)/$(APP_NAME)
OUT_BIN   := $(OUT_DIR)/$(APP_NAME).bin

QEMU      := qemu-system-$(ARCH)
OBJDUMP   ?= rust-objdump -d --print-imm-hex --x86-asm-syntax=intel
OBJCOPY   ?= rust-objcopy --binary-architecture=$(ARCH)

RUSTFLAGS := -C link-arg=-T$(LD_SCRIPT) -C link-arg=-no-pie
export RUSTFLAGS

all: run

# Build + objcopy + verify
$(OUT_BIN): 
	@printf "Building $(APP_NAME) ...\n"
	cargo build --manifest-path $(APP)/Cargo.toml --release \
	    --target $(TARGET) --target-dir $(CURDIR)/target
	@echo "-> objcopy ..."
	$(OBJCOPY) $(OUT_ELF) --strip-all -O binary $(OUT_BIN)
	@echo "-> verify output file ..."
	@test -s $(OUT_BIN) || (echo "ERROR: $(OUT_BIN) is empty or missing"; exit 1)
	@echo "-> file info:"
	@file $(OUT_BIN) || true
	@echo "-> hexdump head:"
	@xxd -l 64 $(OUT_BIN) || true

run: $(OUT_BIN)
	$(QEMU) -m 128M -smp $(SMP) -machine q35 \
	    -drive format=raw,file=$(OUT_BIN),if=ide \
	    -nographic -D qemu.log -d in_asm

clean:
	rm -rf $(CURDIR)/target qemu.log
	cargo clean

.PHONY: all run clean
