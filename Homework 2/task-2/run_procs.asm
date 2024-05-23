%include "../include/io.mac"

    ;;
    ;;   TODO: Declare 'avg' struct to match its C counterpart
    ;;
; I declared the structure
struc avg
    .quo: resw 1
    .remain: resw 1
endstruc

struc proc
    .pid: resw 1
    .prio: resb 1
    .time: resw 1
endstruc

SIZE EQU 5
TIME EQU 3
PRIO EQU 2
PID EQU 0

    ;; Hint: you can use these global arrays
section .data
    prio_result dd 0, 0, 0, 0, 0
    time_result dd 0, 0, 0, 0, 0

section .text
    extern printf
    global run_procs

run_procs:
    ;; DO NOT MODIFY

    push ebp
    mov ebp, esp
    pusha

    xor ecx, ecx

clean_results:
    mov dword [time_result + 4 * ecx], dword 0
    mov dword [prio_result + 4 * ecx],  0

    inc ecx
    cmp ecx, 5
    jne clean_results

    mov ecx, [ebp + 8]      ; processes
    mov ebx, [ebp + 12]     ; length
    mov eax, [ebp + 16]     ; proc_avg
    ;; DO NOT MODIFY
   
    ;; Your code starts here
    ;; Declare variables
    ; freeing eax for multiplication
    push eax
    mov eax, SIZE

    ; keeping in ebx the whole size occupied
    ; by the processes, basically 
    ; procceses_number * sizeof(proccess)
    mul ebx
    mov ebx, eax

    ; restoring eax after usage
    pop eax

    ; iterating through processes
    xor edi, edi ; i = 0

    ; freeing eax
    push eax

loop:
    ; checking if I reached the end of the iterations
    cmp edi, ebx ; i < length
    je time_average ; calculating the average

    ; I keep iterating
    ; cleaning the registers
    xor edx, edx
    xor eax, eax

    ; loading the priority
    mov al, byte [ecx + edi + PRIO] ; prio(i)
    dec eax

    ; using ecx for total time
    push ecx ; freeing ecx
    mov dx, word [ecx + edi + TIME] ; time(i)
    mov ecx, [time_result + 4 * eax] 
    
    ; basically updating the time array
    add ecx, edx ; adding the time to total
    mov dword [time_result + 4 * eax], ecx

    pop ecx ; restoring ecx

    ; updating the priorities array
    mov edx, dword [prio_result + 4 * eax]  
    inc edx
    mov dword [prio_result + 4 * eax], edx 

    ; keeping iterating
    add edi, SIZE ; i++
    jmp loop

; calculating the average for each priority
; and updating the arrays
time_average:
    xor edi, edi ; cleaning edi
    pop eax ; resetting eax (proc_avg)
    mov edi, eax ; edi points to output array

    ; cleaning the registers
    xor ecx, ecx
    xor eax, eax
    xor ebx, ebx

; computing for each priority    
for:
    cmp ecx, 5
    je final
    mov ebx, dword [prio_result + ecx * 4] ; loading the priority

    mov eax, dword [time_result + ecx * 4] ; load total time for priority
    xor edx, edx ; clear edx for div

    ; if I have zero I have to skip it
    ; (floating point exception)
    cmp ebx, 0
    jz end_iteration

    div ebx ; divide by number of processes with priority

    ; updating the output array
    mov word [edi + ecx * 4], ax
    mov word [edi + ecx * 4 + 2], dx

end_iteration:
    inc ecx ; increment loop counter
    jmp for ; back to computing the time average

; no need to do anything
final:
    ;; Your code ends here
    
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY