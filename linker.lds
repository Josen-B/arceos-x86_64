OUTPUT_ARCH(x86_64)

KERNEL_PHYS_BASE = 0x00100000;   /* 1MB, 常见的 x86_64 内核加载地址 */
ENTRY(_start)

SECTIONS
{
    . = KERNEL_PHYS_BASE;
    _skernel = .;

    /* -------- MULTIBOOT -------- */
    .multiboot ALIGN(8) : {
        *(.multiboot)
    }

    /* -------- TEXT -------- */
    .text ALIGN(4K) : {
        _stext = .;
        *(.text.boot)
        *(.text .text.*)
        . = ALIGN(4K);
        _etext = .;
    }

    /* -------- RODATA -------- */
    .rodata ALIGN(4K) : {
        _srodata = .;
        *(.rodata .rodata.*)
        *(.srodata .srodata.*)
        *(.data.rel.ro.local*)        /* x86_64 C++ ABI 需要 */
        . = ALIGN(4K);
        _erodata = .;
    }

    /* -------- DATA -------- */
    .data ALIGN(4K) : {
        _sdata = .;
        *(.data .data.*)
        *(.sdata .sdata.*)
        *(.got .got.*)
        *(.plt .plt.*)
        . = ALIGN(4K);
        _edata = .;
    }

    /* -------- BSS -------- */
    .bss ALIGN(4K) : {
        boot_stack = .;
        . += 256K;
        boot_stack_top = .;

        _sbss = .;

        boot_page_table = .;
        . += 4K;
        boot_page_table_end = .;

        *(.bss .bss.*)
        *(.sbss .sbss.*)
        *(COMMON)
        . = ALIGN(4K);
        _ebss = .;
    }

    _ekernel = .;

    /* -------- Remove useless sections -------- */
    /DISCARD/ : {
        *(.comment)
        *(.note*)
        *(.eh_frame*)
        *(.gnu*)
    }
}
