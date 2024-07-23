
; Address to start from 0x7c00
ORG  0x7c00

;  saying we are using 16 bit code
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start: 
    jmp short start
    nop
    
    times 33 db 0 ; this is calculated in course
start:
    jmp 0:step2
                
                
step2:
    cli
    mov ax, 0x00
    mov ds, ax
    mov es,ax
    mov ss,ax
    mov sp, 0x7c00
    ; Enables interrupts
    sti

.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax ; resseting the regiser since we set the bit
    jmp CODE_SEG:load32 ; we will use instead of load32 into and address to memory

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
; lodaing the kernel since we put 100 sectors
load32:
    ; 1 not 0 because 0 is the boot sector
    mov eax, 1
    mov ecx, 100
    mov edi,0x0100000
    call ata_lba_read
    jmp CODE_SEG:0x0100000

    ; hard disk driver ? 
ata_lba_read:
    mov ebx,eax,
    ; send the highest 8 bits of the lba to hard disk controller
    shr eax, 24
    or eax, 0xE0 ; select the master drive
    mov dx, 0x1F6
    ; move highest 8 bits of the lba that are in eax (al) to dx
    out dx, al
    ; Finished sengin the highest 8 bits of the lba

    ; Send the total sectors to read
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al

    ; Finihshed sending the total sectors to read

    ; send more bits of the LBA
    mov eax,ebx
    mov dx, 0x1F3
    out dx,al

    ; finished sending more bits of the lbac

    ; send more bits of the lba
    mov dx, 0x1F4
    mov eax,ebx ; restore the backup lba
    shr eax,8
    out dx, al

    ; finished more bits of the lba

    ; send upper 16 bits of the lba
    mov dx, 0x1F5
    mov eax, ebx
    shr eax, 16
    out dx, al

    ; finished sending upper 16 bits of the lba

    mov dx , 0x1f7
    mov al , 0x20
    out dx,al

    ; read all sectors into memory
.next_sector:
    push ecx

; checking if we need to read    
.try_again:

    mov dx, 0x1f7
    in al, dx
    test al, 8
    jz .try_again

 ; we need to read 256 words at a time    
    mov ecx, 256 ; one sector ? 
    mov dx, 0x1F0
    ; INSW input word from i/o port specified in dx into memory location specified in ES:(E)DI
    ; edi = 1M
    ; reading from dx = 0x1F0 and storing it into edi= 0x0100000
    rep insw
    pop ecx
    loop .next_sector

    ; end of reading sectors
    ret
     

;  we need to fill at least 510 bytes of data so 511 and 512 can be read from the bios
times 510-($ - $$) db 0
; 55AA actually, it gets flipped
dw 0xAA55
