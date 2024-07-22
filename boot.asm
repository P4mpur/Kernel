; Address to start from 0x7c00
ORG 0x7c00

;  saying we are using 16 bit code
BITS 16

start:
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



