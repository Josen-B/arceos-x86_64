OUTPUT_ARCH(i386:x86-64)

BASE_ADDRESS = 0x100000;

ENTRY(_start)

SECTIONS
{
    . = BASE_ADDRESS;
    _skernel = .;

    /* 代码段 */
    .text : ALIGN(4K) {
        _stext = .;
        *(.text.boot)         /* 启动代码 */
        *(.text .text.*)
        . = ALIGN(4K);
        _etext = .;
    }

    /* 只读数据 */
    .rodata : ALIGN(4K) {
        _srodata = .;
        *(.rodata .rodata.*)
        *(.srodata .srodata.*)
        . = ALIGN(4K);
        _erodata = .;
    }

    /* 已初始化数据 */
    .data : ALIGN(4K) {
        _sdata = .;
        *(.data .data.*)
        *(.sdata .sdata.*)
        *(.got .got.*)
        . = ALIGN(4K);
        _edata = .;
    }

    /* 未初始化数据 */
    .bss : ALIGN(4K) {
        _sbss = .;
        *(.bss .bss.*)
        *(.sbss .sbss.*)
        *(COMMON)
        . = ALIGN(4K);
        _ebss = .;
    }

    _ekernel = .;

    /* 丢弃无用段 */
    /DISCARD/ : {
        *(.comment) *(.gnu*) *(.note*) *(.eh_frame*)
    }
}
