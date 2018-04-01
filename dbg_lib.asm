; pomocne funkcije potrebne debuggger-u
VID_MEM equ 0B800h
DARK_BLUE equ 00010000b
COL_MULTIPLIER equ 2
ROW_MULTIPLIER equ 160

;crta informacije na ekranu
_draw_frame:
  pusha
  call _calculate_starting_pos ; racunamo pocetnu lokaciju ispisa, rezultat se nalazi u starting_pos
  call _draw_time
  popa
  ret
_draw_time:
  pusha
  call _time_to_string ; pretvaramo vreme u string, rezultat se nalazi u timestamp

  mov ax, VID_MEM
  mov es, ax ; postavljamo ES da pokazuje na video memoriju
  mov bx, word [starting_pos] ; postavljamo BX da sadrzi pocetnu poziciju ispisa
  mov si, timestamp ; u DI ide ime stringa koji zelimo da ispisemo na ekranu


  ;pisemo vreme
  call _strlen ; trazimo duzinu stringa
  xor cx, cx
  mov cl, byte [str_len] ; u AX se nalazi duzina stringa

  print_time:
  mov al, byte [si] ; u AL smestamo ASCII znak iz stringa
  mov byte[es:bx], al ; zatim taj ASCII znak ispisujemo na ekran
  inc bx
  mov byte[es:bx], 2 ; boja
  inc bx
  inc si ; prelazimo na sledecu adresu u timestamp stringu
  loop print_time

  popa
  ret
; izracunava pocetnu poziciju ispisa
; rezultat smesta u starting_pos
_calculate_starting_pos:
  ; resetujemo registre
  pusha
  xor ax, ax
  xor bx, bx
  xor cx, cx
  xor dx, dx

  ; odredjivanje pocetne pozicije
  ; u pos_X i pos_Y labeli se nalaze offset-ovi od kojih treba da crtamo frame
  mov bl, byte [pos_x] ; smestamo kolonu u pos_y

  ; mnozimo sa odgovarajucim umnoscima
  mov ax, bx ; u AX se nalazi broj kolona
  mov cx, COL_MULTIPLIER ; mnozilac za kolonu
  mul cx

  mov bx, ax ; vracamo rezultat u bx

  mov dl, byte [pos_y] ; smestamo red u pos_x

  mov ax, dx ; u AX se nalazi broj redova
  xor dx, dx
  mov cx, ROW_MULTIPLIER ; mnozilac za red
  mul cx

  mov dx, ax ; vracamo rezultat u ax



  ;pozicija reda i kolone mora da se sabere kako bismo znali gde da ispisemo
  add bx, dx ; u AX se sada nalazi pocetna pozicija ispisa
  mov word[starting_pos], bx
  popa
  ret

; pretvara trenutno vreme u string
; rezultat smesta u timestamp
_time_to_string:
  pusha

  ;trazimo informaciju o trenutnom vremenu
  mov ah, 2ch ; int21h/ah=2ch u kombinaciji vracaju trenutno sistemsko vreme: CH = sat CL = minut DH = sekund DL = stoti deo sekunde
  int 21h

  ;privremeno cuvamo
  mov byte [hour], ch
  mov byte [minute], cl
  mov byte [second], dh

  mov si, timestamp ; u ovu labelu cemo upisivati timestamp

  mov dl, ch ; pretvaramo sat u ASCII

  call itoa ; vraca rezultat u ax
  ;upisujemo sat u prva dva bajta timestamp stringa
  mov word[si], ax
  add si, 2 ; pomeramo se za 2 bajta
  mov byte[si], ':' ; separator
  inc si ; pomeramo se za jednu adresu

  mov dl, cl ; pretvaramo minut u ascii
  call itoa


  mov word[si], ax ; upisujemo minute
  add si, 2
  mov byte[si], ':'
  inc si

  mov dl, dh ; pretvaramo sekunde u ASCII
  call itoa


  mov word[si], ax
  add si, 2




  popa
  ret

; u dl se nalazi broj koji ispisujemo (0-99)
itoa:
  xor ax, ax ; resetujemo AX
  mov al, dl ; smestamo u AL posto cemo njega da koristimo

  mov bl, 10d
  div bl ; AL = AX/10, AH = AX mod 10 - primer: za broj 58, u AL dobijamo 5 a u AH 8

  ;AX sadrzi cifre
  add ax, 3030h ; pretvara u ascii (ovim putem i na AH i na AL se dodaje po 30h, odakle pocinju cifre iz ASCII)

  mov bx, ax ; cuvamo za kasnije

  ret

; OBSOLETE
_draw_frame_obsolete_code:
    pusha

    call _calculate_starting_pos ; metoda za izracunavanje pocetne pozicije

    mov ax, VID_MEM
    mov bx, word [starting_pos]
    mov es, ax ; pocetak video memorije
    ; mov byte[es:bx], byte 1
    ; inc bx
    ; mov byte[es:bx], 02h
    mov cx, 20; sirina ispisa (10 karaktera bojimo u tamno plavo)
    mov ax, 5; visina

    .drawing_loop:
      cmp ax, 0 ; ako nema vise redova za ispisivanje dosli smo do kraja
      je .end_of_drawing
      mov cx, 20 ; sirina ispisa (broj puta koliko ce se .draw petlja izvrsiti po redu)
      add bx, 160 ; prelazimo u novi red
      sub bx, 40
      .draw:
      mov byte[es:bx], byte 2
      inc bx
      mov byte[es:bx], 02h
      inc bx
      loop .draw
      dec ax
      jmp .drawing_loop
    .end_of_drawing:
    popa
    ret



segment .data
starting_pos: dw 0 ; pocetna pozicija ispisa sadrzaja debuggera
timestamp: times 8 db 0 ; string koji sadrzi HH:MM:SS
placeholder1: db 0 ; ova labela drzi timestamp string
hour: db 0
minute: db 0
second: db 0
