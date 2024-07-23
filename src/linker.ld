ENTRY(_start)
OUTPUT_FORMAT(binary)
SECTIONS
{
    . = 1M;  
    /* 4096 gives alignment by the sections themselves */
    .text(4096) :
    {
        *(.text)
    }

    .rodata(4096) :
    {
        *(.rodata)
    }

    .data(4096) :
    {
        *(.data)
    }

    .bss(4096) :
    {
        *(COMMON)
        *(.bss)
    }

    .asm(4096) :
    {
        *(.asm)
    }
}

    /* this is going to be an address that we will load our kernel, it's kernel's origin */