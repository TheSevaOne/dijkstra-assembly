 section .text
	global _start 
	
getMatrixOffset:
    pop eax    
    pop ebx ; first offset
    pop edx ; second offset
    push eax
   
    ; (width(childArr) * f)
    mov eax, [lenChildArr]
    mul ebx  
    mov ebx, eax
    
    ; (sizeof(db) * x)
    mov eax, [sizeOfInt]
    mul edx 
    
    ; (width(intMatrix) * f) + (sizeof(db) * x)
    add eax, ebx
    
    mov edx, intMatrix ; ECX will point to the current element 
    add edx, eax ; move pointer to the element
    ret


; A utility function to find the vertex with minimum distance value, from 
; the set of vertices not yet included in shortest path tree 
minDistance:
    mov ebx, [intMax] ; track the min distance
    xor ecx, ecx

    push 0

    distLoop:
        ; get offset
        mov eax, [sizeOfInt] 
        mul ecx

        ; if (sptSet[i] == false)
        mov edx, eax
        add edx, sptSetArr ; Pointer to current element in sptSet
        xor eax, eax
        add eax, [edx]
        cmp eax, 0
        jne endLoop

        ; get offset
        mov eax, [sizeOfInt] 
        mul ecx

        ; if (distArr[i] <= min distance)
        mov edx, eax
        add edx, distArr ; Pointer to current element in distArr

        xor eax, eax
        mov al, [edx]
        cmp eax, ebx

        jg endLoop

        pop edx
        mov ebx, eax 
        push ecx

        endLoop:
            inc ecx
            cmp ecx, [lenChildArr]
            jl distLoop
        
    ;mov eax, ebx
    xor eax, eax
    pop eax
    test2:
    ret


dijkstra:
    pop eax
    pop edx ; source vertex offset
    push eax

    ; get source vertex offset
    mov eax, [sizeOfInt]
    mul edx
    mov ebx, distArr 
    add ebx, edx
    
    mov byte [ebx], 0 ; distance of source vertex is always 0

    ; for (int count = 0; count < lenChildArr-1; count++) 
    mov ecx, [lenChildArr] ; number of times to loop
    dec ecx
    shortestPathLoop:
        push ecx
        call minDistance ; Get min distance of not yet processed vertices
        pop ecx
        push eax ; Store min distance

        ; sptSetArr[min distance] = true so it is not reprocessed
        add eax, sptSetArr 
        mov byte [eax], 1

        ; for (int v = 0; v < lenChildArr; v++) 
        xor ebx, ebx
        updateLoop:

            ; if (sptSetArr[v] == 0)
            mov eax, ebx
            add eax, sptSetArr 
            mov eax, [eax]
            cmp eax, 1
            je endUpdateLoop

            ; && if (intMatrix[intMinDistance][v] > 0)
            xor eax, eax
            pop eax ; min distance
            push eax

            push ebx
            
            push ebx
            push eax
            call getMatrixOffset

            pop ebx
            xor eax, eax
            mov ax, [edx]
            xor edx, edx
            mov edx, eax

            cmp edx, 0
            je endUpdateLoop

            ; && if (distArr[intMinDistance] != intMax)
            xor eax, eax
            pop eax ; min distance
            push eax
            add eax, distArr
            cmp eax, [intMax]
            je endUpdateLoop
            
            ; && if (distArr[intMinDistance] + intMatrix[intMinDistance][v] < distArr[v])
            xor eax, eax
            pop eax ; min distance
            push eax
            push ebx
            
            push ebx
            push eax
            call getMatrixOffset

            pop ebx

            xor eax, eax
            mov ax, [edx]
            xor edx, edx
            mov edx, eax
            xor eax, eax

            pop eax ; min distance
            push eax
            add eax, distArr
            add edx, [eax] ; distArr[intMinDistance] + intMatrix[min distance][v]
            mov eax, ebx
            add eax, distArr
            cmp edx, eax
            jge endUpdateLoop

            ; distArr[v] = distArr[intMinDistance] + intMatrix[intMinDistance][v]
            xor eax, eax
            mov eax, ebx
            add eax, distArr 
            mov [eax], edx

            endUpdateLoop:
               inc ebx
               cmp ebx, [lenChildArr]
               jl updateLoop

        pop eax
        dec ecx
        cmp ecx, 0
        jg shortestPathLoop
    
    ret


printResult:
    mov ecx, 0
    printLoop:

        mov edx, ecx
        push ecx

        add edx, distArr
        
        xor ebx, ebx ; clear EBX
        add ebx, [edx] ; Grab the value from EAX
        add ebx, '0' ; terminate the string
        mov [msg], ebx

        mov ecx, msg

        mov	edx, 2    ; message length
        mov ebx, 1     ; file descriptor (stdout)
        mov eax, 4     ; system call number (sys_write)
        int 0x80       ; call kernel

        pop ecx
        inc ecx
        cmp ecx, [lenChildArr]
        jl printLoop
    ret


_start:                     ; entry point
    push ebp
    mov ebp, esp

	push 0
    call dijkstra
    call printResult

    mov eax, 1     ;system call number (sys_exit)
    int 0x80       ;call kernel


section	.data
; this db array represents a matrix:
; intArray = 
; [
;   {1, 2, 3, 4},
;   {5, 6, 7, 8},
;   {9, 10, 11, 12}
;   {13, 14, 15, 16}
; ]
;
; Assume intMatrix is at mem addr 0 and db width is 1
; The formula for accessing sub-offsets is:
;
; mem offset of intMatrix[f][x] =
; memAddr(intMatrix) + (width(childArr) * f)  + (sizeof(db) * x)
; 
; intMatrix[0][3] = 0 + (4 * 0) + (1 * 3) = mem address offset 3
;
; therefore (&intMatrix + 3) contains the starting addresss of the number 4
; 
; 
;intMatrix db 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 15, 16

intMatrix db 0, 4, 0, 0, 0, 0, 0, 8, 0, 4, 0, 8, 0, 0, 0, 0, 11, 0, 0, 8, 0, 7, 0, 4, 0, 0, 2, 0, 0, 7, 0, 9, 14, 0, 0, 0, 0, 0, 0, 9, 0, 10, 0, 0, 0, 0, 0, 4, 14, 10, 0, 2, 0, 0, 0, 0, 0, 0, 0, 2, 0, 1, 6, 8, 11, 0, 0, 0, 0, 1, 0, 7, 0, 0, 2, 0, 0, 0, 6, 7, 0 ; int array

lenChildArr dd 9     ;length of the child array

distArr db 255, 255, 255, 255, 255, 255, 255, 255, 255  ; will contain the min distance for each point
sptSetArr db 0, 0, 0, 0, 0, 0, 0, 0, 0

; CONSTANTS
intMax dd 255
sizeOfInt dd 1
intMinDistance dd 255
msg dd 0