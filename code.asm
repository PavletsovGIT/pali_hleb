includelib kernel32.lib   ; ���������� ���������� kernel32.lib
 
extrn GetStdHandle: proc
extrn ReadFile: proc
extrn WriteFile: proc
 
.data
buffer byte 200 dup (?)    ; ����� ��� ���������� ������
len = $ - buffer
 
.code

read proc
  sub rsp, 56   ; 32 (shadow storage) + 8 (5-� �������� ReadFile) + 8 (byttesRead) + 8 (������������)
  mov r8, rcx   ;������ �������� ReadFile - ������ ������
  mov rcx, rax ; ������ �������� ReadFile - ���������� �����
  mov rdx, rdi ; ������ �������� ReadFile - ����� ������
  lea r9, bytesRead   ; ��������� �������� ReadFile - ���������� ��������� ������
  mov qword ptr [rsp + 32], 0      ; ����� �������� ReadFile - 0
  call ReadFile       ; ����� ������� RaedFile
  test rax, rax       ; ��������� �� ������
  mov eax, bytesRead  ; ���� ������ ���, � RAX ���������� ��������� ������
  jnz exit          ; ���� � RAX ��������� ��������
  mov rax, -1       ; �������� �������� ��� ������
exit:
  add rsp, 56
  ret
bytesRead equ [rsp+40] ; ������� � ����� ��� �������� ���������� ��������� ������
read endp

readFromConsole proc
  sub rsp, 32
  push rcx            ; ��������� ���������� ��������
  mov  rcx, -10         ; �������� ��� GetStdHandle - STD_INPUT
  call GetStdHandle     ; �������� ������� GetStdHandle
  pop rcx
  call read
  add rsp, 32
  ret
readFromConsole endp

toUpper proc
  push rcx  ; �������� rcx, ������� �������� ��� � �����
 
while_start: 
  test rcx, rcx
  jz while_end
  dec rcx
  cmp byte ptr [rsi + rcx], 122
  ja while_start
  cmp byte ptr [rsi + rcx], 97
  jb while_start
  and byte ptr [rsi + rcx], 011011111b  ; �������������� � �������� ��������
  jmp while_start
while_end:
  pop rcx
  ret
toUpper endp

write proc
  sub  rsp, 56
  mov rdx, rsi          ; ������ �������� - ������
  mov r8, rcx           ; ������ �������� - ����� ������
  mov  rcx, rax         ; ������ �������� WriteFile - � ������� RCX �������� ���������� ����� - ����������� ������
  lea  r9, bytesWritten       ; ��������� �������� WriteFile - ����� ��� ��������� ���������� ������
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
  mov rcx, -11         ; �������� ��� GetStdHandle - STD_OUTPUT
  call GetStdHandle     ; �������� ������� GetStdHandle
  pop rcx         ; ��������������� RCX - ���������� ��������
  call write
  add rsp, 32
  ret
writeToConsole endp
 
start proc
  lea rdi, buffer       ; ����� ��� ���������� ������
  mov rcx, len          ; ������ ������
  call readFromConsole  ; ��������� ������ � �������
   
  lea rsi, buffer   ; �������������� ������
  mov rcx, rax      ; ����� ������ - �� readFromConsole
  call toUpper      ; ��������� ������ � ������� �������
 
  call writeToConsole ; ������� ��������������� ������ �� �������
 
  ret
start endp
end