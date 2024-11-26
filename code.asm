.386
.MODEL FLAT, STDCALL
OPTION CASEMAP: NONE

includelib kernel32.lib

EXTERN  GetStdHandle@4: PROC
EXTERN  WriteConsoleA@20: PROC
EXTERN  ReadConsoleA@20: PROC
EXTERN  ExitProcess@4: PROC
EXTERN  lstrlenA@4: PROC

.DATA
STRN DB "Enter string: ", 13, 10, 0  ; Строка для вывода приглашения
PALINDROM DB "Palindrome: ", 13, 10, 0 ; Текст перед выводом палиндрома
BUF  DB 200 DUP (?)                  ; Буфер для ввода строки (200 байтов)
RESULT_BUF DB 400 DUP (?)            ; Буфер для результата (палиндром)
LENS DD ?                            ; Количество выведенных символов
DIN  DD ?                            ; Дескриптор ввода
DOUT DD ?                            ; Дескриптор вывода

.CODE
MAIN PROC
    ; Получаем дескриптор ввода
    PUSH -10
    CALL GetStdHandle@4
    MOV DIN, EAX

    ; Получаем дескриптор вывода
    PUSH -11
    CALL GetStdHandle@4
    MOV DOUT, EAX

    ; Вывод строки приглашения "Enter string:"
    PUSH 0
    PUSH OFFSET LENS
    PUSH OFFSET STRN
    CALL lstrlenA@4     ; Вычисляем длину строки STRN
    PUSH EAX            ; Длина строки
    PUSH OFFSET STRN    ; Адрес строки
    PUSH DOUT           ; Дескриптор вывода
    CALL WriteConsoleA@20

    ; Читаем строку, введённую пользователем
    PUSH 0
    PUSH OFFSET LENS
    PUSH 200            ; Максимальная длина строки
    PUSH OFFSET BUF     ; Буфер для ввода
    PUSH DIN            ; Дескриптор ввода
    CALL ReadConsoleA@20

    ; Убираем символы возврата каретки (\r) и новой строки (\n)
    MOV EDI, OFFSET BUF      ; Указатель на строку
    MOV ECX, LENS            ; Количество считанных байтов
    DEC ECX                  ; Уменьшаем ECX на 1 (\n)
    MOV BYTE PTR [EDI + ECX], 0 ; Заменяем \n на конец строки
    DEC ECX                  ; Уменьшаем ECX на 1 (\r)
    MOV LENS, ECX            ; Обновляем LENS

    ; Формируем палиндром
    CALL FormPalindrome

    ; Вывод текста "Palindrome: "
    PUSH 0
    PUSH OFFSET LENS
    PUSH OFFSET PALINDROM
    CALL lstrlenA@4
    PUSH EAX
    PUSH OFFSET PALINDROM
    PUSH DOUT
    CALL WriteConsoleA@20

    ; Вывод сформированного палиндрома
    PUSH 0
    PUSH OFFSET LENS
    PUSH OFFSET RESULT_BUF
    CALL lstrlenA@4
    PUSH EAX
    PUSH OFFSET RESULT_BUF
    PUSH DOUT
    CALL WriteConsoleA@20

    ; Выход из программы
    PUSH 0              ; Код выхода
    CALL ExitProcess@4
MAIN ENDP

FormPalindrome PROC
    CLD
    ; Указатели на входной и выходной буфер
    LEA ESI, BUF        ; Начало исходной строки
    LEA EDI, RESULT_BUF ; Начало буфера результата

    ; Копируем исходную строку в результат
    MOV ECX, LENS
    REP MOVSB

    ; Указатели на начало и конец строки
    LEA ESI, BUF            ; Указатель на начало строки (BUF)
    LEA EDI, RESULT_BUF     ; Указатель на начало буфера результата (RESULT_BUF)
    MOV ECX, LENS           ; Количество символов в строке

    ; Устанавливаем указатель ESI на конец строки
    ADD ESI, ECX
    DEC ESI                 ; Переходим к последнему символу

    ADD EDI, ECX
    ; DEC EDI ; Раскоментировать, если вместо qweewq, нужно qwewq

REVERSE_LOOP:
    MOV AL, BYTE PTR [ESI]  ; Загружаем символ из конца строки
    MOV BYTE PTR [EDI], AL  ; Записываем его в результат
    DEC ESI                 ; Смещаемся к предыдущему символу в BUF
    INC EDI                 ; Смещаемся к следующей позиции в RESULT_BUF
    LOOP REVERSE_LOOP       ; Уменьшаем ECX, пока не достигнем 0
    
    MOV BYTE PTR [EDI], 0   ; Завершающий символ строки
    RET
FormPalindrome ENDP

END MAIN