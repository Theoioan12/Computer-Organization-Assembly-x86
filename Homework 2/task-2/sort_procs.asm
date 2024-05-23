%include "../include/io.mac"
SIZE EQU 5
TIME EQU 3
PRIO EQU 2
PID EQU 0

struc proc
    .pid: resw 1
    .prio: resb 1
    .time: resw 1
endstruc

section .text
    global sort_procs

sort_procs:
    ;; DO NOT MODIFY
    enter 0,0
    pusha

    mov edx, [ebp + 8]      ; processes
    mov eax, [ebp + 12]     ; length
    ;; DO NOT MODIFY

    ;; Your code starts here
    ; keeping (length - 1) for the iterations
    mov ecx, eax
    dec ecx
    xor ebx, ebx

    ; the main sorting loop
    sort:
        mov edi, edx ; moving the processes
        mov ebx, 0
        push eax ; pusing eax to have one more
                ;  register available

        ; iterating from 0 to (length - 1)
        inner_loop:

            ; if I reach (length - 1) I go to the next iteration
            ; i < (length - 1)
            cmp ebx, ecx
            jge next

            ; keeping the next neighbour
            ; basically the (i + 1) process, where i is the current one
            mov esi, edi ; i
            add esi, SIZE ; i + 1

            ; comparing the priority of the current process to the next one
            ; if prio(i) > prio (i + 1)
            mov al, [edi + PRIO] ; prio(i)
            cmp al, [esi + PRIO] ; prio (i + 1)

            ; doing the swap if needed
            jg swap
            jne skip_swap

            ; otherwise comparing the time
            ; time(i) > time(i + 1)
            mov ax, [edi + TIME] ; time(i)
            cmp ax, [esi + TIME] ; time (i + 1)

            ; again doing the swap if needed
            jg swap
            jne skip_swap

            ; otherwise comparing the pid
            ; pid(i) > pid(i + 1)
            mov ax, [edi + PID] ; pid (i)
            cmp ax, [esi + PID] ; pid (i + 1)

            ; again swapping if needed
            jg swap

            ; if the swap is not needed
            skip_swap:

                ; i++
                add edi, SIZE
                add ebx, 1

                ; I go into another iteration
                jmp inner_loop

            ; swapping
            swap:
                ; freeing eax to keep the first process priority
                push eax
                mov al, byte [edi + PRIO] ; prio(i)

                ; freeing edx to keep the second process's priority
                push edx
                mov dl, byte [esi + PRIO] ; prio(i + 1)

                ; doing the swap for priorities
                ; swap(prio(i), prio(i + 1))
                mov byte [edi + PRIO], dl
                mov byte [esi + PRIO], al

                ; exactly as above but now for the time
                mov ax, [edi + TIME] ; time(i)
                mov dx, [esi + TIME] ; time(i + 1)

                ; swap(time(i), time(i + 1))
                mov [edi + TIME], dx
                mov [esi + TIME], ax

                ; again, as above but for the pid
                mov ax, [edi + PID] ; pid(i)
                mov dx, [esi + PID] ; pid(i + 1)

                ; swap(pid(i), pid(i + 1))
                mov [edi + PID], dx
                mov [esi + PID], ax

                ; restoring edx and eax
                pop edx ; adresses
                pop eax ; length

                ; going to the next process
                ; i++
                add edi, SIZE
                add ebx, 1
                jmp inner_loop

        ; keeping iterating in the outer loop
        next:
            ; while (length > 0)
            pop eax
            dec eax
            jnz sort

    ;; Your code ends here
    
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY