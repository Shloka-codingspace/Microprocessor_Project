.model small
.stack 100h
.data
    msg1 db 'Enter Text: $'
    msg2 db 0Ah, 0Dh, 'Encrypted Text: $'
    msg3 db 0Ah, 0Dh, 'Decrypted Text: $'
    input db 50 dup('$')
    encrypted db 50 dup('$')
    decrypted db 50 dup('$')
    shift db 3

.code
main:
    mov ax, @data
    mov ds, ax

    ; Prompt for input
    mov ah, 09h
    lea dx, msg1
    int 21h

    ; Read input string
    lea di, input
read_loop:
    mov ah, 01h
    int 21h
    cmp al, 13         ; Enter key
    je done_read
    mov [di], al
    inc di
    jmp read_loop

done_read:
    mov byte ptr [di], '$'

    ; Encrypt input
    lea si, input
    lea di, encrypted
encrypt_loop:
    mov al, [si]
    cmp al, '$'
    je show_encrypted
    add al, shift
    mov [di], al
    inc si
    inc di
    jmp encrypt_loop

show_encrypted:
    mov byte ptr [di], '$'
    mov ah, 09h
    lea dx, msg2
    int 21h
    lea dx, encrypted
    int 21h

    ; Decrypt back
    lea si, encrypted
    lea di, decrypted
decrypt_loop:
    mov al, [si]
    cmp al, '$'
    je show_decrypted
    sub al, shift
    mov [di], al
    inc si
    inc di
    jmp decrypt_loop

show_decrypted:
    mov byte ptr [di], '$'
    mov ah, 09h
    lea dx, msg3
    int 21h
    lea dx, decrypted
    int 21h

    ; Exit
    mov ah, 4ch
    int 21h
end main
