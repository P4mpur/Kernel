; Address to start from 0x7c00
ORG  0

;  saying we are using 16 bit code
BITS 16

; created so it can jump 
_start: 
    jmp short start
    nop

    times 33 db 0 ; this is calculated in course
    ; basically fills 33 bits with 0 so it doesn't corrupt your code
    ; more details on https://wiki.osdev.org/FAT
start:
    jmp 0x7c0:step2




step2:

    ;  Whole this first part is only for ourselves so it can work on every computer
    ;  There's why we are setting it all like that
    ;  Clear interrupts
    cli
    ; Need to change segment registers ourselves, so it can work with other processors
    mov ax, 0x7c0
    ;  data segment ?
    mov ds, ax
    ;  i don't know what es is
    mov es,ax
    mov ax, 0x00
    mov ss,ax
    ; sp is stack pointer
    mov sp, 0x7c00

    ; Enables interrupts
    sti

    ; we're gonna read from the boot.bin where we dd'd message.txt into
    mov ah, 2 ; read Sector Command
    mov al, 1 ; one sector to read
    mov ch, 0 ; cilinder low eight bits
    mov cl, 2 ; read sector 2, starts from 1
    mov dh, 0 ; Head number
    mov bx, buffer 
    int 0x13 ; int/command to read from 'hard Disk'
    jc error

    mov si,buffer
    call print

    jmp $
error:
    mov si, error_message
    call print
    ; make sure it keeps jumping to itself
    jmp $

print:
    mov bx, 0

.loop:
    lodsb
    cmp al,0
    je .done
    call print_char
    jmp .loop

.done:
    ret
    

print_char:
; Output the charachter A into terminal using the ah, 0eh, look into table from the link
; Later it's moved here beacuse of lodsb 
    mov ah, 0eh
    ; mov al, 'A'
    ; mov bx, 0
    ; Calling the bios with int 0x10
    int 0x10
    ret

error_message: db 'Failed to load Sector',0

;  we need to fill at least 510 bytes of data so 511 and 512 can be read from the bios
times 510-($ - $$) db 0
; 55AA actually, it gets flipped
dw 0xAA55

; it's in the end so it doesn't messup anything 
;that we have written before that
buffer: 
