; pomocne funkcije potrebne debuggger-u
VID_MEM equ 0B800h
DARK_BLUE equ 00010000b
COL_MULTIPLIER equ 2
ROW_MULTIPLIER equ 160

;crta informacije na ekranu
_draw_frame:
  pusha
  call _calculate_starting_pos ; racunamo pocetnu lokaciju ispisa, rezultat se nalazi u starting_pos
  call _draw_time ; ispisuje vreme na ekran
  call _draw_stack_labels
  popa
  ret


; ispisuje sistemsko vreme na ekran
_draw_time:
  pusha
  call _time_to_string ; pretvaramo vreme u string, rezultat se nalazi u timestamp

  mov ax, VID_MEM
  mov es, ax ; postavljamo ES da pokazuje na video memoriju
  mov bx, word [starting_pos] ; postavljamo BX da sadrzi pocetnu poziciju ispisa
  mov si, timestamp ; u DI ide ime stringa koji zelimo da ispisemo na ekranu

  call _draw_string ; funkcija koja prikazuje sadrzaj stringa na ekran

  popa
  ret

;ispisuje labele registara na ekran ("AX:", "BX", "CX", "DX", etc.)
_draw_register_labels:
  pusha
  mov ax, VID_MEM
  mov es, ax
  mov bx, word [starting_pos]

  ;ispis stringa "Registers"
  mov si, registers_lbl
  add bx, 160 ; da bismo ispisali u redu ispod timestamp-a
  call _draw_string ; ispisujemo "REGISTERS"

  ;ispis stringa "ax:"
  mov si, ax_lbl
  add bx, 160
  call _draw_string ; ispisujemo "ax:"

  ;ispis stringa "bx:"
  mov si, bx_lbl
  add bx, 160
  call _draw_string ; ispisujemo "bx:"

  ;ispis stringa "cx:"
  mov si, cx_lbl
  add bx, 160
  call _draw_string

  ;ispis stringa "dx:"
  mov si, dx_lbl
  add bx, 160
  call _draw_string

  ;ispis stringa "si:"
  mov si, si_lbl
  add bx, 160
  call _draw_string

  ;ispis stringa "di:"
  mov si, di_lbl
  add bx, 160
  call _draw_string

  popa
  ret

_draw_stack_labels:
  pusha
  mov ax, VID_MEM
  mov es, ax
  mov bx, word [starting_pos]

  ;ispis stringa "Stack: "
  mov si, stack_lbl
  add bx, 160 ; za ispis ispod timestamp-a
  call _draw_string

  ;ispis "1:"
  mov si, first_lbl
  add bx, 160
  call _draw_string

  ;ispis "2:"
  mov si, second_lbl
  add bx, 160
  call _draw_string

  ;ispis "3:"
  mov si, third_lbl
  add bx, 160
  call _draw_string

  ;ispis "4:"
  mov si, fourth_lbl
  add bx, 160
  call _draw_string

  ;ispis "5:"
  mov si, fifth_lbl
  add bx, 160
  call _draw_string

  ;ispis "6:"
  mov si, sixth_lbl
  add bx, 160
  call _draw_string


  popa
  ret
; u SI se nalazi adresa ulaznog stringa
; u BX se nalazi pozicija ispisa na ekranu
_draw_string:
  pusha

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
;funkcija koja pretvara broj koji ima najvise dve cifre u ASCII
itoa:
  xor ax, ax ; resetujemo AX
  mov al, dl ; smestamo u AL posto cemo njega da koristimo

  mov bl, 10d
  div bl ; AL = AX/10, AH = AX mod 10 - primer: za broj 58, u AL dobijamo 5 a u AH 8

  ;AX sadrzi cifre
  add ax, 3030h ; pretvara u ascii (ovim putem i na AH i na AL se dodaje po 30h, odakle pocinju cifre iz ASCII)

  mov bx, ax ; cuvamo za kasnije

  ret


segment .data
starting_pos: dw 0 ; pocetna pozicija ispisa sadrzaja debuggera
timestamp: times 8 db 0 ; string koji sadrzi HH:MM:SS
placeholder1: db 0 ; ova labela drzi timestamp string
hour: db 0
minute: db 0
second: db 0

; labele vezane za ispis registara opste namene na ekranu

; labele vezane za ispis imena registara na ekran
registers_lbl: db "Registers", 0
ax_lbl: db "ax:", 0
bx_lbl: db "bx:", 0
cx_lbl: db "cx:", 0
dx_lbl: db "dx:", 0
si_lbl: db "si:", 0
di_lbl: db "di:", 0


; labele za cuvanje vrednosti registara
ax_val: db "    ", 0 ; string sa 4 pozicije ( u te 4 pozicije se smesta vrednost registra)
bx_val: db "    ", 0
cx_val: db "    ", 0
dx_val: db "    ", 0
si_val: db "    ", 0
di_val: db "    ", 0

;---------------------------------


;labele vezane za ispis steka na ekranu
stack_lbl: db "Stack:", 0
first_lbl: db "1:", 0
second_lbl: db "2:", 0
third_lbl: db "3:", 0
fourth_lbl: db "4:", 0
fifth_lbl: db "5:", 0
sixth_lbl: db "6:", 0

; labele za cuvanje vrednosti steka
first_val: db "    ", 0
second_val: db "    ", 0
third_val: db "    ", 0
fourth_val: db "    ", 0
fifth_val: db "    ", 0
sixth_val: db "    ", 0


;--------------------------------

;labele za ispis memorijske lokacije na ekranu
seg_lbl: db "seg", 0
off_lbl: db "off", 0
value_lbl: db "val", 0

seg_val: db "    ", 0
off_val: db "    ", 0
value_val: db "    ", 0
