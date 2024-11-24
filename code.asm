includelib kernel32.lib   ; подключаем библиотеку kernel32.lib
 
extrn GetStdHandle: proc
extrn ReadFile: proc
extrn WriteFile: proc

.data
buffer byte 200 dup (?)        ; буфер для считывания данных
len = $ - buffer               ; длина буфера
result_buf byte 400 dup (?)    ; буфер для палиндрома (длина удвоенная)
lens dq 0                      ; длина считанной строки

.code

read proc
    sub rsp, 56   ; 32 (shadow storage) + 8 (5-й параметр ReadFile) + 8 (bytesRead) + 8 (выравнивание)
    mov r8, rcx   ; Третий параметр ReadFile - размер буфера
    mov rcx, rax  ; Первый параметр ReadFile - дескриптор файла
    mov rdx, rdi  ; Второй параметр ReadFile - адрес буфера
    lea r9, bytesRead   ; Четвертый параметр ReadFile - количество считанных байтов
    mov qword ptr [rsp + 32], 0      ; Пятый параметр ReadFile - 0
    call ReadFile       ; вызов функции ReadFile
    test rax, rax       ; проверяем на ошибку
    mov eax, bytesRead  ; если ошибки нет, в RAX количество считанных байтов
    jnz exit            ; если в RAX ненулевое значение
    mov rax, -1         ; помещаем условный код ошибки
exit:
    add rsp, 56
    ret
bytesRead equ [rsp+40] ; область в стеке для хранения количества считанных байтов
read endp

readFromConsole proc
    sub rsp, 32
    push rcx            ; сохраняем количество символов
    mov  rcx, -10       ; Аргумент для GetStdHandle - STD_INPUT
    call GetStdHandle   ; вызываем функцию GetStdHandle
    pop rcx
    call read
    add rsp, 32
    ret
readFromConsole endp

genPalindrome proc
    ; Устанавливаем направление обработки цепочек (DF = 0, копирование вперед)
    CLD                         ; Устанавливаем направление: вперед

    ; Копируем строку в начало результирующего буфера
    lea rsi, buffer             ; Адрес исходной строки
    lea rdi, result_buf         ; Адрес результирующего буфера
    mov rcx, qword ptr [lens]   ; Количество символов в строке
    rep movsb                   ; Копируем строку в результат

    ; Устанавливаем направление обработки цепочек в обратную сторону (DF = 1)
    STD                         ; Устанавливаем направление: назад

    ; Копируем строку с конца во вторую половину результирующего буфера
    lea rsi, buffer             ; Адрес исходной строки
    add rsi, qword ptr [lens]   ; Указатель на конец строки (переход к последнему символу)
    dec rsi                     ; Переход к последнему символу
    lea rdi, result_buf         ; Адрес результирующего буфера
    add rdi, qword ptr [lens]   ; Переход к концу первой части в результирующем буфере
    mov rcx, qword ptr [lens]   ; Количество символов в строке
    rep movsb                   ; Копируем строку в обратном порядке

    ; Завершаем результирующую строку
    cld                         ; Возвращаем направление: вперед
    lea rdi, result_buf         ; Указатель на результирующий буфер
    add rdi, qword ptr [lens]   ; Переход к концу первой части строки
    add rdi, qword ptr [lens]   ; Переход к концу второй части строки
    mov byte ptr [rdi], 0       ; Завершаем строку символом NULL

    ret
genPalindrome endp

write proc
    sub  rsp, 56
    mov rdx, rsi          ; Второй параметр - строка
    mov r8, rcx           ; Третий параметр - длина строки
    mov  rcx, rax         ; Первый параметр WriteFile - в регистр RCX помещаем дескриптор файла - консольного вывода
    lea  r9, bytesWritten ; Четвертый параметр WriteFile - адрес для получения записанных байтов
    mov qword ptr [rsp + 32], 0  ; Пятый параметр WriteFile
    call WriteFile
     
    test rax, rax ; проверяем на наличие ошибки
    mov eax, bytesWritten ; если все нормально, помещаем в RAX количество записанных байтов
    jnz exit 
    mov rax, -1 ; Возвращаем через RAX код ошибки
exit:
    add  rsp, 56
    ret
bytesWritten equ [rsp+40]
write endp

writeToConsole proc
    sub rsp, 32
    push rcx            ; сохраняем количество символов
    mov rcx, -11        ; Аргумент для GetStdHandle - STD_OUTPUT
    call GetStdHandle   ; вызываем функцию GetStdHandle
    pop rcx             ; восстанавливаем RCX - количество символов
    call write
    add rsp, 32
    ret
writeToConsole endp
 
start proc
    lea rdi, buffer       ; буфер для считывания данных
    mov rcx, len          ; размер буфера
    call readFromConsole  ; считываем данные с консоли

    mov qword ptr [lens], rax ; Сохраняем длину строки

    call genPalindrome    ; Формируем палиндром

    lea rsi, result_buf   ; Выводим палиндром
    mov rcx, rax          ; Длина результирующей строки
    call writeToConsole

    ret
start endp
end
