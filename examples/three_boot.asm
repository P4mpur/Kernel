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

; responsible for handling interrupt zero 
; ( i am not sure but i think this should handle division by zero)
handle_zero:
    mov ah, 0eh
    mov al, 'A'
    mov bx, 0x00
    int 0x10
    iret

handle_one:
    mov ah, 0eh
    mov al, 'Z'
    mov bx, 0x00
    int 0x10
    iret
    

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

    ; using ss so it will use 0x00 as it is in interrupt tables
    ; we could have used 
    ; mov ds,0x00
    ; and then
    ; mov word[0x00],handle_zero, but below is just easier and cleaner

    mov word[ss:0x00],handle_zero
    mov word[ss:0x02], 0x7c0

    ; this is basically calling 0x00
    ; int 0
    ; we can call it like this too
    ; mov ax,0
    ; div ax, which divides whatever is on the right side with ax, 
    ;so it's ax\ax
    ;which is divided with zero, so int 0 is called

    ;for int 1'
    ; int 1 starts at 0x04 that's why it's there
    ; https://wiki.osdev.org/Exceptions more here
    mov word[ss:0x04], handle_one
    mov word[ss:0x06], 0x7c0

    int 1


    mov si, message 
    call print

    ; make sure it keeps jumping to itself
    jmp $

print:
    mov bx, 0
    ; Load the character the si register is pointing to and it will load it to a register
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

message: db 'Hello World!', 0



;  we need to fill at least 510 bytes of data so 511 and 512 can be read from the bios
times 510-($ - $$) db 0
; 55AA actually, it gets flipped
dw 0xAA55



