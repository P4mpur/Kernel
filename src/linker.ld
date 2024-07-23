ENTRY(_start)
OUTPUT_FORMAT(binary)
SECTIONS
{
    . = 1M;  
    .text :
    {
        *(.text)
    }

    .rodata :
    {
        *(.rodata)
    }

    .data :
    {
        *(.data)
    }

    .bss :
    {
        *(COMMON)
        *(.bss)
    }
}

    /* this is going to be an address that we will load our kernel, it's kernel's origin */