includelib kernel32.lib   ; подключаем библиотеку kernel32.lib
 
extrn GetStdHandle: proc
extrn ReadFile: proc
extrn WriteFile: proc
 
.data
buffer byte 200 dup (?)    ; буфер для считывания данных
len = $ - buffer
 
.code

read proc
  sub rsp, 56   ; 32 (shadow storage) + 8 (5-й параметр ReadFile) + 8 (byttesRead) + 8 (выравнивание)
  mov r8, rcx   ;Третий параметр ReadFile - размер буфера
  mov rcx, rax ; Первый параметр ReadFile - дескриптор файла
  mov rdx, rdi ; Второй параметр ReadFile - адрес буфера
  lea r9, bytesRead   ; Четвертый параметр ReadFile - количество считанных байтов
  mov qword ptr [rsp + 32], 0      ; Пятый параметр ReadFile - 0
  call ReadFile       ; вызов функции RaedFile
  test rax, rax       ; проверяем на ошибку
  mov eax, bytesRead  ; если ошибки нет, в RAX количество считанных байтов
  jnz exit          ; если в RAX ненулевое значение
  mov rax, -1       ; помещаем условный код ошибки
exit:
  add rsp, 56
  ret
bytesRead equ [rsp+40] ; область в стеке для хранения количества считанных байтов
read endp

readFromConsole proc
  sub rsp, 32
  push rcx            ; сохраняем количество символов
  mov  rcx, -10         ; Аргумент для GetStdHandle - STD_INPUT
  call GetStdHandle     ; вызываем функцию GetStdHandle
  pop rcx
  call read
  add rsp, 32
  ret
readFromConsole endp

toUpper proc
  push rcx  ; изменяем rcx, поэтому сохраним его в стеке
 
while_start: 
  test rcx, rcx
  jz while_end
  dec rcx
  cmp byte ptr [rsi + rcx], 122
  ja while_start
  cmp byte ptr [rsi + rcx], 97
  jb while_start
  and byte ptr [rsi + rcx], 011011111b  ; преобразование к верхнему регистру
  jmp while_start
while_end:
  pop rcx
  ret
toUpper endp

write proc
  sub  rsp, 56
  mov rdx, rsi          ; Второй параметр - строка
  mov r8, rcx           ; Третий параметр - длина строки
  mov  rcx, rax         ; Первый параметр WriteFile - в регистр RCX помещаем дескриптор файла - консольного вывода
  lea  r9, bytesWritten       ; Четвертый параметр WriteFile - адрес для получения записанных байтов
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
  mov rcx, -11         ; Аргумент для GetStdHandle - STD_OUTPUT
  call GetStdHandle     ; вызываем функцию GetStdHandle
  pop rcx         ; восстанавливаем RCX - количество символов
  call write
  add rsp, 32
  ret
writeToConsole endp
 
start proc
  lea rdi, buffer       ; буфер для считывания данных
  mov rcx, len          ; размер буфера
  call readFromConsole  ; считываем данные с консоли
   
  lea rsi, buffer   ; обрабатываемая строка
  mov rcx, rax      ; длина строки - из readFromConsole
  call toUpper      ; переводим строку в верхний регистр
 
  call writeToConsole ; выводим преобразованную строку на консоль
 
  ret
start endp
end