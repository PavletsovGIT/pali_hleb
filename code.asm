includelib kernel32.lib   ; ���������� ���������� kernel32.lib
 
extrn GetStdHandle: proc
extrn ReadFile: proc
extrn WriteFile: proc

.data
buffer byte 200 dup (?)        ; ����� ��� ���������� ������
len = $ - buffer               ; ����� ������
result_buf byte 400 dup (?)    ; ����� ��� ���������� (����� ���������)
lens dq 0                      ; ����� ��������� ������

.code

read proc
    sub rsp, 56   ; 32 (shadow storage) + 8 (5-� �������� ReadFile) + 8 (bytesRead) + 8 (������������)
    mov r8, rcx   ; ������ �������� ReadFile - ������ ������
    mov rcx, rax  ; ������ �������� ReadFile - ���������� �����
    mov rdx, rdi  ; ������ �������� ReadFile - ����� ������
    lea r9, bytesRead   ; ��������� �������� ReadFile - ���������� ��������� ������
    mov qword ptr [rsp + 32], 0      ; ����� �������� ReadFile - 0
    call ReadFile       ; ����� ������� ReadFile
    test rax, rax       ; ��������� �� ������
    mov eax, bytesRead  ; ���� ������ ���, � RAX ���������� ��������� ������
    jnz exit            ; ���� � RAX ��������� ��������
    mov rax, -1         ; �������� �������� ��� ������
exit:
    add rsp, 56
    ret
bytesRead equ [rsp+40] ; ������� � ����� ��� �������� ���������� ��������� ������
read endp

readFromConsole proc
    sub rsp, 32
    push rcx            ; ��������� ���������� ��������
    mov  rcx, -10       ; �������� ��� GetStdHandle - STD_INPUT
    call GetStdHandle   ; �������� ������� GetStdHandle
    pop rcx
    call read
    add rsp, 32
    ret
readFromConsole endp

genPalindrome proc
    ; ������������� ����������� ��������� ������� (DF = 0, ����������� ������)
    CLD                         ; ������������� �����������: ������

    ; �������� ������ � ������ ��������������� ������
    lea rsi, buffer             ; ����� �������� ������
    lea rdi, result_buf         ; ����� ��������������� ������
    mov rcx, qword ptr [lens]   ; ���������� �������� � ������
    rep movsb                   ; �������� ������ � ���������

    ; ������������� ����������� ��������� ������� � �������� ������� (DF = 1)
    STD                         ; ������������� �����������: �����

    ; �������� ������ � ����� �� ������ �������� ��������������� ������
    lea rsi, buffer             ; ����� �������� ������
    add rsi, qword ptr [lens]   ; ��������� �� ����� ������ (������� � ���������� �������)
    dec rsi                     ; ������� � ���������� �������
    lea rdi, result_buf         ; ����� ��������������� ������
    add rdi, qword ptr [lens]   ; ������� � ����� ������ ����� � �������������� ������
    mov rcx, qword ptr [lens]   ; ���������� �������� � ������
    rep movsb                   ; �������� ������ � �������� �������

    ; ��������� �������������� ������
    cld                         ; ���������� �����������: ������
    lea rdi, result_buf         ; ��������� �� �������������� �����
    add rdi, qword ptr [lens]   ; ������� � ����� ������ ����� ������
    add rdi, qword ptr [lens]   ; ������� � ����� ������ ����� ������
    mov byte ptr [rdi], 0       ; ��������� ������ �������� NULL

    ret
genPalindrome endp

write proc
    sub  rsp, 56
    mov rdx, rsi          ; ������ �������� - ������
    mov r8, rcx           ; ������ �������� - ����� ������
    mov  rcx, rax         ; ������ �������� WriteFile - � ������� RCX �������� ���������� ����� - ����������� ������
    lea  r9, bytesWritten ; ��������� �������� WriteFile - ����� ��� ��������� ���������� ������
    mov qword ptr [rsp + 32], 0  ; ����� �������� WriteFile
    call WriteFile
     
    test rax, rax ; ��������� �� ������� ������
    mov eax, bytesWritten ; ���� ��� ���������, �������� � RAX ���������� ���������� ������
    jnz exit 
    mov rax, -1 ; ���������� ����� RAX ��� ������
exit:
    add  rsp, 56
    ret
bytesWritten equ [rsp+40]
write endp

writeToConsole proc
    sub rsp, 32
    push rcx            ; ��������� ���������� ��������
    mov rcx, -11        ; �������� ��� GetStdHandle - STD_OUTPUT
    call GetStdHandle   ; �������� ������� GetStdHandle
    pop rcx             ; ��������������� RCX - ���������� ��������
    call write
    add rsp, 32
    ret
writeToConsole endp
 
start proc
    lea rdi, buffer       ; ����� ��� ���������� ������
    mov rcx, len          ; ������ ������
    call readFromConsole  ; ��������� ������ � �������

    mov qword ptr [lens], rax ; ��������� ����� ������

    call genPalindrome    ; ��������� ���������

    lea rsi, result_buf   ; ������� ���������
    mov rcx, rax          ; ����� �������������� ������
    call writeToConsole

    ret
start endp
end
