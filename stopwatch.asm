org 100h
bits 16

jmp start

min db 0
sec db 0
csec db 0
run db 0
tcount db 0
;msg1 db ':$'
;msg2 db '.$'
msg_start db 'Press Space to start/resume the stopwatch and Esc to exit :) $', 0
old_1C_off dw 0
old_1C_seg dw 0

timer:
    pushf
    pusha
    cmp byte [run], 0
    je done
    inc byte [tcount]
    cmp byte [tcount], 5       ;delay 
    jne done
    mov byte [tcount], 0
    inc byte [csec]
    cmp byte [csec], 100
    jne update_display
    mov byte [csec], 0
    inc byte [sec]
    cmp byte [sec], 60
    jne update_display
    mov byte [sec], 0
    inc byte [min]

update_display:
    mov ah, 2
    mov bh, 0
    mov dx, 0C23h
    int 10h
    mov al, [min]
    call print_digit
    mov dx, msg1
    mov ah, 9
    int 21h
    mov al, [sec]
    call print_digit
    mov dx, msg2
    mov ah, 9
    int 21h
    mov al, [csec]
    call print_digit

done:
    popa
    popf
    iret

print_digit:
    aam
    add ax, 3030h
    push ax
    mov dl, ah
    mov ah, 2
    int 21h
    pop ax
    mov dl, al
    mov ah, 2
    int 21h
    ret

start:
    mov ax, 0003h
    int 10h

    
    mov dx, msg_start
    mov ah, 9
    int 21h

    xor ax, ax
    mov es, ax
    mov ax, [es:1Ch*4]
    mov [old_1C_off], ax
    mov ax, [es:1Ch*4+2]
    mov [old_1C_seg], ax
    cli
    mov word [es:1Ch*4], timer
    mov [es:1Ch*4+2], cs
    sti

main:
    mov ah, 1
    int 16h
    jz main
    mov ah, 0
    int 16h
    cmp ah, 1
    je exit
    cmp ah, 39h
    jne main
    xor byte [run], 1
    jmp main

exit:
    cli
    mov ax, 0
    mov es, ax
    mov ax, [old_1C_off]
    mov [es:1Ch*4], ax
    mov ax, [old_1C_seg]
    mov [es:1Ch*4+2], ax
    sti
    mov ax, 4C00h
    int 21h