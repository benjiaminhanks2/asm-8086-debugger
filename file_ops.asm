
_parse_file_data:
  pusha

  ; otvara fajl
  mov ax, 3d00h ; 3dh u AH za OPEN komandu
  mov dx, input_file_name ; ime fajla iz kog citamo
  int 21h

  ;cita fajl
  mov bx, ax ; premestamo file handle u BX
  mov ah, 3fh ; 3fh je vrednost za READ
  mov cx, 20 ; broj bajtova koji citamo
  mov dx, buf ; mesto na koje upisujemo
  int 21h

  ;zatvara fajl
  mov ah, 3eh ; 3eh je vrednost za CLOSE
  int 21h

  ; radimo parsiranje iz bafera u labele posX i posY - posX cuva red a posY kolonu ispisivanja na ekran
  ; primer validno zadanog parametra: XX\r\n\r\nYY - gde su XX i YY dvocifreni brojevi
  ; ovaj buffer mozemo iskoristi da olaksamo parsiranje u int tako sto dodajemo terminalnu nulu posle XX i posle YY
  ; jer _str_to_int cita samo do terminalne nule

  mov si, buf ; smestamo adresu stringa koji modifikujemo
  mov byte [si+2], 0 ; pisemo 0 iza XX => "XX0"
  mov byte [si+8], 0 ; pisemo 0 za YY => tako da sad buf izgleda: "XX0\n\r\nYY0

  call _str_to_int ; pocetna adresa stringa koji parsiramo mora biti u SI a rezultat _str_to_int je u AX
  mov byte [pos_x], al ; smestamo rezultat u labelu koja oznacava kolonu ispisa

  add si, 6 ; da bismo dosli do "XX0\n\r\n\*Y0" - "*" oznacava poziciju gde se zelimo da se pomerimo
  call _str_to_int
  mov byte [pos_y], al

  popa
  ret



segment .data

input_file_name:  db 'poz.txt', 0
buf: 	resb 20
pos_x: db 0
pos_y: db 0
