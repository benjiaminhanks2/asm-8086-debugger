
_parse_file_data:
  pusha

  ; otvara fajl
  mov ax, 3d00h ; 3dh u AH za OPEN komandu
  mov dx, input_file_name ; ime fajla iz kog citamo
  int 21h

  ;cita fajl
  mov bx, ax ; premestamo file handle u BX
  mov ah, 3fh ; 3fh je vrednost za READ
  mov cx, 256 ; broj bajtova koji citamo
  mov dx, buf ; mesto na koje upisujemo
  int 21h

  ;close the file
  mov ah, 3eh ; 3eh je vrednost za CLOSE
  int 21h
  popa

  ret



segment .data

input_file_name:  db 'poz.txt', 0
buf: 	resb 256
