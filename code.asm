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
STRN DB "Enter string: ", 13, 10, 0  ; ������ ��� ������ �����������
PALINDROM DB "Palindrome: ", 13, 10, 0 ; ����� ����� ������� ����������
BUF  DB 200 DUP (?)                  ; ����� ��� ����� ������ (200 ������)
RESULT_BUF DB 400 DUP (?)            ; ����� ��� ���������� (���������)
LENS DD ?                            ; ���������� ���������� ��������
DIN  DD ?                            ; ���������� �����
DOUT DD ?                            ; ���������� ������

.CODE
MAIN PROC
    ; �������� ���������� �����
    PUSH -10
    CALL GetStdHandle@4
    MOV DIN, EAX

    ; �������� ���������� ������
    PUSH -11
    CALL GetStdHandle@4
    MOV DOUT, EAX

    ; ����� ������ ����������� "Enter string:"
    PUSH 0
    PUSH OFFSET LENS
    PUSH OFFSET STRN
    CALL lstrlenA@4     ; ��������� ����� ������ STRN
    PUSH EAX            ; ����� ������
    PUSH OFFSET STRN    ; ����� ������
    PUSH DOUT           ; ���������� ������
    CALL WriteConsoleA@20

    ; ������ ������, �������� �������������
    PUSH 0
    PUSH OFFSET LENS
    PUSH 200            ; ������������ ����� ������
    PUSH OFFSET BUF     ; ����� ��� �����
    PUSH DIN            ; ���������� �����
    CALL ReadConsoleA@20

    ; ������� ������� �������� ������� (\r) � ����� ������ (\n)
    MOV EDI, OFFSET BUF      ; ��������� �� ������
    MOV ECX, LENS            ; ���������� ��������� ������
    DEC ECX                  ; ��������� ECX �� 1 (\n)
    MOV BYTE PTR [EDI + ECX], 0 ; �������� \n �� ����� ������
    DEC ECX                  ; ��������� ECX �� 1 (\r)
    MOV LENS, ECX            ; ��������� LENS

    ; ��������� ���������
    CALL FormPalindrome

    ; ����� ������ "Palindrome: "
    PUSH 0
    PUSH OFFSET LENS
    PUSH OFFSET PALINDROM
    CALL lstrlenA@4
    PUSH EAX
    PUSH OFFSET PALINDROM
    PUSH DOUT
    CALL WriteConsoleA@20

    ; ����� ��������������� ����������
    PUSH 0
    PUSH OFFSET LENS
    PUSH OFFSET RESULT_BUF
    CALL lstrlenA@4
    PUSH EAX
    PUSH OFFSET RESULT_BUF
    PUSH DOUT
    CALL WriteConsoleA@20

    ; ����� �� ���������
    PUSH 0              ; ��� ������
    CALL ExitProcess@4
MAIN ENDP

FormPalindrome PROC
    CLD
    ; ��������� �� ������� � �������� �����
    LEA ESI, BUF        ; ������ �������� ������
    LEA EDI, RESULT_BUF ; ������ ������ ����������

    ; �������� �������� ������ � ���������
    MOV ECX, LENS
    REP MOVSB

    ; ��������� �� ������ � ����� ������
    LEA ESI, BUF            ; ��������� �� ������ ������ (BUF)
    LEA EDI, RESULT_BUF     ; ��������� �� ������ ������ ���������� (RESULT_BUF)
    MOV ECX, LENS           ; ���������� �������� � ������

    ; ������������� ��������� ESI �� ����� ������
    ADD ESI, ECX
    DEC ESI                 ; ��������� � ���������� �������

    ADD EDI, ECX
    ; DEC EDI ; ����������������, ���� ������ qweewq, ����� qwewq

REVERSE_LOOP:
    MOV AL, BYTE PTR [ESI]  ; ��������� ������ �� ����� ������
    MOV BYTE PTR [EDI], AL  ; ���������� ��� � ���������
    DEC ESI                 ; ��������� � ����������� ������� � BUF
    INC EDI                 ; ��������� � ��������� ������� � RESULT_BUF
    LOOP REVERSE_LOOP       ; ��������� ECX, ���� �� ��������� 0
    
    MOV BYTE PTR [EDI], 0   ; ����������� ������ ������
    RET
FormPalindrome ENDP

END MAIN