.model small
.stack 100h
.data
    prompt      db 0Dh, 0Ah, 'Shloka-SHELL> $'
    input       db 20 dup('$')
    helpMsg     db 0Dh, 0Ah, 'Available commands: HELP, DATE, CLS, EXIT$'
    dateMsg     db 0Dh, 0Ah, 'Today is: 20/07/2022$'
    badCmdMsg   db 0Dh, 0Ah, 'Bad command or filename$'
    clsMsg      db 0Dh, 0Ah, '[Screen cleared]$'
    exitMsg     db 0Dh, 0Ah, 'Exiting shell...$'

    cmd_help    db 'HELP$'
    cmd_date    db 'DATE$'
    cmd_cls     db 'CLS$'
    cmd_exit    db 'EXIT$'

.code
main:
    mov ax, @data
    mov ds, ax

shell_loop:
    ; Show prompt
    mov ah, 09h
    lea dx, prompt
    int 21h

    ; Read input into buffer
    lea di, input
    mov cx, 0
read_input:
    mov ah, 01h
    int 21h
    cmp al, 0Dh       ; Enter?
    je end_input
    mov [di], al
    inc di
    inc cx
    cmp cx, 20
    je end_input
    jmp read_input

end_input:
    mov byte ptr [di], '$'

    ; Convert to uppercase
    lea si, input
    call to_uppercase

    ; === Compare with HELP ===
    lea si, input
    lea di, cmd_help
    call compare_string
    jc check_date

    mov ah, 09h
    lea dx, helpMsg
    int 21h
    jmp shell_loop

check_date:
    lea si, input
    lea di, cmd_date
    call compare_string
    jc check_cls

    mov ah, 09h
    lea dx, dateMsg
    int 21h
    jmp shell_loop

check_cls:
    lea si, input
    lea di, cmd_cls
    call compare_string
    jc check_exit

    mov ah, 09h
    lea dx, clsMsg
    int 21h
    jmp shell_loop

check_exit:
    lea si, input
    lea di, cmd_exit
    call compare_string
    jc bad_command

    mov ah, 09h
    lea dx, exitMsg
    int 21h
    jmp exit_program

bad_command:
    mov ah, 09h
    lea dx, badCmdMsg
    int 21h
    jmp shell_loop

exit_program:
    mov ah, 4ch
    int 21h

; ===== Subroutines =====

compare_string:       ; compare strings at DS:SI and DS:DI
    push si
    push di
compare_loop:
    mov al, [si]
    mov bl, [di]
    cmp al, '$'
    je check_end
    cmp bl, '$'
    je not_equal
    cmp al, bl
    jne not_equal
    inc si
    inc di
    jmp compare_loop

check_end:
    cmp bl, '$'
    jne not_equal
    clc
    jmp end_compare

not_equal:
    stc
end_compare:
    pop di
    pop si
    ret

to_uppercase:         ; convert input to uppercase
    push si
convert_loop:
    mov al, [si]
    cmp al, '$'
    je convert_done
    cmp al, 'a'
    jb next_char
    cmp al, 'z'
    ja next_char
    sub al, 20h
    mov [si], al
next_char:
    inc si
    jmp convert_loop
convert_done:
    pop si
    ret

end main
