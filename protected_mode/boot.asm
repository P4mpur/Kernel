; Address to start from 0x7c00
ORG  0x7c00

;  saying we are using 16 bit code
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; created so it can jump 
_start: 
    jmp short start
    nop
    
    times 33 db 0 ; this is calculated in course
    ; basically fills 33 bits with 0 so it doesn't corrupt your code
    ; more details on https://wiki.osdev.org/FAT
start:
    jmp 0:step2
                
                
step2:
    ;  Whole this first part is only for ourselves so it can work on every computer
    ;  There's why we are setting it all like that
    ;  Clear interrupts
    cli
    ; Need to change segment registers ourselves, so it can work with other processors
    mov ax, 0x00
    ;  data segment ?
    mov ds, ax
    ;  i don't know what es is
    mov es,ax
    mov ss,ax
    ; sp is stack pointer
    mov sp, 0x7c00

    ; Enables interrupts
    sti

.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax ; resseting the regiser since we set the bit
    jmp CODE_SEG:load32

; GDT
gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

; offset 0x8
; this is a template
gdt_code: ; cs should point to this
    dw 0xffff
    dw 0 ; base first 0-15 bits
    db 0 ; base 16-23 bits
    db 0x9a ; access byte
    db 11001111b ; hight 4 bits flas and the low 4 bit flags
    db 0

; offset 0x10
gdt_data: ; DS , SS, ES , FS ,GS
    dw 0xffff
    dw 0 ; base first 0-15 bits
    db 0 ; base 16-23 bits
    db 0x92 ; access byte
    db 11001111b ; hight 4 bits flas and the low 4 bit flags
    db 0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start -1 
    dd gdt_start

[BITS 32]    
load32:
    mov ax, DATA_SEG
    mov ds,ax
    mov es,ax
    mov fs,ax
    mov gs,ax
    mov ss,ax
    mov ebp, 0x00200000
    mov esp, ebp

    jmp $

;  we need to fill at least 510 bytes of data so 511 and 512 can be read from the bios
times 510-($ - $$) db 0
; 55AA actually, it gets flipped
dw 0xAA55

; it's in the end so it doesn't messup anything 
;that we have written before that
buffer: 
