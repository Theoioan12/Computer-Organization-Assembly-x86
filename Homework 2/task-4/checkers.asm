SIZE EQU 8
section .data

section .text
	global checkers

checkers:
    ;; DO NOT MODIFY
    push ebp
    mov ebp, esp
    pusha

    ; void checkers (int x, int y, char table[8][8])
    mov eax, [ebp + 8]	; x
    mov ebx, [ebp + 12]	; y
    mov ecx, [ebp + 16] ; table

    ;; DO NOT MODIFY
    ;; FREESTYLE STARTS HERE

    ; checking if the piece can go up and left
    dec eax ; decreasing x (left), x - 1
    inc ebx ; and increasing y (up), y + 1

    cmp eax, 0 ; if x - 1 is lower than 0, then it's outside the table
               ; if (x - 1 < 0)
    jl left_up

    cmp ebx, SIZE - 1 ; if y + 1 is higher than 7, again it's outside
                      ; if y + 1 > 7 (table_size - 1)
    jg left_up

    ; if both coordinates are alright then I put 1 up - left
    ; table [x - 1][y + 1] = 1
    add ecx, ebx
    mov byte [ecx + eax * SIZE], 1
    sub ecx, ebx

left_up:
    ; back to original coordinates
    inc eax ; x ++
    dec ebx ; y --

    ; checking if the piece can go up and right
    inc eax ; increasing both x (right)
            ; x + 1
    inc ebx ; and y (up)
            ; y + 1

    ; if they are greater than 7 
    ; they are outside the table
    cmp eax, SIZE - 1 ; if (x + 1 > table_size - 1)
    jg right_up

    cmp ebx, SIZE - 1 ; if (y + 1 > table_size - 1)
    jg right_up

    ; if both coordinates are allright then I put 1 up - right
    ; table[x + 1][y + 1] = 1
    add ecx, ebx
    mov byte [ecx + eax * SIZE], 1
    sub ecx, ebx
    
right_up:
    ; back to original coordinates
    dec eax ; x --
    dec ebx ; y --

    ; checking if the piece can move down and left
    dec eax ; x - 1
    dec ebx ; y - 1

    ; if both positions are lower than 0 
    ; they are outside the table
    cmp eax, 0 ; if (x - 1 < 0)
    jl left_down

    cmp ebx, 0 ; if (y - 1 < 0)
    jl left_down

    ; if both coordinates are allright then I put 1 down-left
    ; table[x - 1][y - 1] = 1
    add ecx, ebx
    mov byte [ecx + eax * SIZE], 1
    sub ecx, ebx

left_down:
    ; restoring the coordinates
    inc eax ; x ++
    inc ebx ; y++

    ; checking if the piece can move right and down
    inc eax ; increasing x (right)
            ; x + 1
    dec ebx ; decreasing y (down)
            ; y - 1

    cmp eax, SIZE - 1 ; if (x + 1 > table_size + 1)
    jg right_down

    cmp ebx, 0 ; if (y - 1 < 0)
    jl right_down

    ; if both coordinates are allright then I put 1 down-right
    ; table[x + 1][y - 1] = 1
    add ecx, ebx
    mov byte [ecx + eax * SIZE], 1
    sub ecx, ebx

; no need to update the register anymore
right_down:

    ;; FREESTYLE ENDS HERE
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY