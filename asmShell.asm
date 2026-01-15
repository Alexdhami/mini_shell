; syscalls
EXECVE_SYSCALL equ 59
FORK_SYSCALL equ 57
WAIT_SYSCALL equ 61

; buffer size
BUFF_SIZE equ 128


%macro printf 2 ; 1 = *string, 2 = length
    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

%macro scanf 2 ; 1 = *buffer, 2 = bytes to read
    mov rax, 0
    mov rdi, 0
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

section .text
    global _start

_start:

    while_loop:
        printf msg_arrow, len_arrow
        scanf buf, BUFF_SIZE

        cmp rax, 0 
        je while_loop

        mov r12, rax            ; save bytes read
        dec r12                 ; count of the last element

        mov bl, [buf + r12]     ; load the last byte of the buffer
        cmp bl, 10              ; compare last byte with new line
        jne .fork               ; no new line then jump to fork label

        mov byte [buf + r12], 0 ; if new line then replace it with string terminator

        .fork:
            mov rax, FORK_SYSCALL
            syscall

            ; mov r13, rax ; save the pid

            cmp rax, 0 ; pid = 0 -> child process.
            jne .wait

        .execve_cmd:

            ; envp offset = argc * 8 + 16 
            mov rax, [rsp]                ; if argc = 2
            lea rdx, [rsp + rax * 8 + 16] ; [rsp + 2 * 8 + 16] = [rsp+ 32]

            ; set n_buf  = {buf, 0(NULL)}
            mov rax, buf
            mov [n_buf], rax         ; n_buf[0] = buf
            mov qword [n_buf + 8], 0 ; n_buf[1] = 0

            mov rax, EXECVE_SYSCALL
            mov rdi, buf             ; *filepath
            mov rsi, n_buf           ; *argv = {*filepath, NULL}
            syscall

            printf msg_cmd_not_found, len_cmd_not_found
            jmp while_loop

            
        .wait:
            mov rax, WAIT_SYSCALL
            mov rdi, 0   ; wait for any child process to run
            xor rsi, rsi
            xor rdx, rdx ; option = 0, wait for termination only
            xor r10, r10 ; unused
            xor r8, r8   ; unused
            syscall
            jmp while_loop

    exit:
        mov rax, 60
        xor rdi, rdi
        syscall

section .data
    msg_cmd_not_found db "Command not found :)", 10
    len_cmd_not_found equ $- msg_cmd_not_found

    msg_arrow db "-> "
    len_arrow equ $- msg_arrow

section .bss
    buf resb 128
    n_buf resq 2
