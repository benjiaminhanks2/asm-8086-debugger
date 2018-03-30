
_parse_file_data:
  ;otvaranje fajla
  mov ah, 3dh ;operacija OPEN
  mov al, 0 ; 0 = read, 1 = write, 2 = read + write
  mov dx, file_name ; ime fajla ide u DX
  int 21h ;ako je uspesno, AX je file handle

  ;citanje iz fajla
  mov bx, ax ;file handle mora da bude u BX
  mov ah, 3fh ;operacija READ

  mov cx, 10 ;max velicina fajla je 256 bajtova
  mov dx, parsed_string
  int 21h  ;velicina parsed_string se nalazi u AX

  push ax ;na steku se nalazi velicina parsed_string

  ;close file
  mov ah, 3eh ; operacija CLOSE
  int 21h ;BX je vec postavljen kao file handler




segment .data
  file_name: db "poz.txt"
  parsed_string: db 10, 0h ; - ucitani podaci oblika "XX\n\rYY\n\r" i terminator stringa na kraju
  posx: db 0
  posy: db 0
