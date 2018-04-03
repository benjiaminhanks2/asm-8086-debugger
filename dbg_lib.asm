; pomocne funkcije potrebne debuggger-u
VID_MEM equ 0B800h
DARK_BLUE equ 00010000b
COL_MULTIPLIER equ 2
ROW_MULTIPLIER equ 160

;ovu metodu zove int 60h - ona racuna vrednosti registara i smesta ih na u odgovarajuce labele
_int_60h_handler:
    call _time_to_string ; parsiramo vreme za timestamp

    cmp ah, 0 ; ako je 0 vrsimo prikaz vrednosti registara opste namene
    je go_handle_base_regs ; parsira base registre
    cmp ah, 1
    je go_handle_stack_regs  ; parsira vrednosti stack adresa
    ;call ; ovde idu stack vrednosti
    go_handle_base_regs:
      call _base_registers_handler
      jmp finish_parsing

    go_handle_stack_regs:
      call _stack_values_handler


    finish_parsing:
    ret


; obradjuje parsiranje i ispis na ekranu
_peek:
    pusha

    ;parsiranje

    mov si, seg_val
    call _str_to_hex ; rezultat smesta u AX

    mov es, ax ; smestamo u es taj segment

    mov si, off_val
    call _str_to_hex

    mov bx, ax ; smestamo u BX

    mov al, byte [es:bx] ; u AX smestamo bajt koji se nalazi na toj memorijskoj adresi

    ;ispisivanje
    call _draw_mem_frame

    popa
    ret

;smesta vrednosti registara opste namene u labele
_base_registers_handler:
  ;cuvamo AX i SI jer cemo da ga koristimo za upis u labelu
  push ax
  push si

  mov si, ax_val ;parsiramo vrednost za AX
  call _reg_hex ; _reg_hex dobija argumente preko SI i AX registra, u AX se nalazi hex vrednost koju parsiramo a u SI se nalazi adresa stringa na koji upisujemo

  mov ax, bx ; parsiramo vrednost za BX
  mov si, bx_val
  call _reg_hex

  mov ax, cx ; parsiramo vrednost za CX
  mov si, cx_val
  call _reg_hex

  mov ax, dx ; parsiramo vrednost za DX
  mov si, dx_val
  call _reg_hex

  pop si ; vracamo originalnu vrednost SI kako bismo je ispisali
  mov ax, si ; parsiramo vrednost za SI
  push si ; opet menjamo SI pa ga cuvamo na stack
  mov si, si_val
  call _reg_hex

  mov ax, di ; parsiramo vrednost za DI
  mov si, di_val
  call _reg_hex

  pop si ; skidamo SI jer smo njega stavili na stack
  pop ax ; skidamo ax sa stack-a da bismo odrzali staru vrednost


  ret


;smesta vrednosti sa stack-a u labele
_stack_values_handler:
  ; cuvamo registre jer ih koristimo
  mov word [temp_reg_val_holder1], ax
  mov word [temp_reg_val_holder2], si
  mov word [temp_reg_val_holder3], es
  mov word [temp_reg_val_holder4], bx

  ;postavljamo da pokazuje na SS:SP
  mov ax, ss
  mov es, ax
  mov bx, sp

  mov ax, word [es:bx] ; parsiramo prvu vrednost sa steka
  mov si, first_val
  call _reg_hex

  inc bx ; prelazimo na sledecu vrednost na stack-u
  inc bx

  ;pop dx test

  mov ax, word [es:bx] ; parsiramo drugu vrednost sa steka
  mov si, second_val
  call _reg_hex

  inc bx ; prelazimo na sledecu vrednost na stack-u
  inc bx

  ;pop dx


  mov ax, word [es:bx] ; parsiramo trecu vrednost sa steka
  mov si, third_val
  call _reg_hex

  inc bx ; prelazimo na sledecu vrednost na stack-u
  inc bx

  ;pop dx


  mov ax, word [es:bx] ; parsiramo cetvrtu vrednost sa steka
  mov si, fourth_val
  call _reg_hex

  inc bx ; prelazimo na sledecu vrednost na stack-u
  inc bx

  ;pop dx


  mov ax, word [es:bx] ; parsiramo petu vrednost sa steka
  mov si, fifth_val
  call _reg_hex

  inc bx ; prelazimo na sledecu vrednost na stack-u
  inc bx

  ;pop dx


  mov ax, word [es:bx] ; parsiramo sestu vrednost sa steka
  mov si, sixth_val
  call _reg_hex


  ;vracamo registre na staro
  mov ax, word [temp_reg_val_holder1]
  mov si, word [temp_reg_val_holder2]
  mov es, word [temp_reg_val_holder3]
  mov bx, word [temp_reg_val_holder4]

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

;ispisuje debug registara na ekran ("AX:", "BX", "CX", "DX", etc.)
_draw_register_frame:
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

  ;ispisuje vrednost AX-a
  mov si, ax_val
  add bx, 8 ; razmak izmedju "AX:" i vrednosti
  call _draw_string

  ;ispis stringa "bx:"
  mov si, bx_lbl
  add bx, 152
  call _draw_string ; ispisujemo "bx:"

  ;ispis vrednosti BX registra
  mov si, bx_val
  add bx, 8
  call _draw_string

  ;ispis stringa "cx:"
  mov si, cx_lbl
  add bx, 152
  call _draw_string

  ;ispis vrednosti CX registra
  mov si, cx_val
  add bx, 8
  call _draw_string

  ;ispis stringa "dx:"
  mov si, dx_lbl
  add bx, 152
  call _draw_string

  ;ispis vrednosti DX registra
  mov si, dx_val
  add bx, 8
  call _draw_string

  ;ispis stringa "si:"
  mov si, si_lbl
  add bx, 152
  call _draw_string

  ;ispis vrednosti SI registra
  mov si, si_val
  add bx, 8
  call _draw_string

  ;ispis stringa "di:"
  mov si, di_lbl
  add bx, 152
  call _draw_string

  ;ispis vrednosti DI registra
  mov si, di_val
  add bx, 8
  call _draw_string


  popa
  ret

;ispisuje debug stack-a
_draw_stack_frame:
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

  ;ispis vrednosti na SP
  mov si, first_val
  add bx, 8
  call _draw_string

  ;ispis "2:"
  mov si, second_lbl
  add bx, 152
  call _draw_string

  ;ispis vrednosti na SP+2
  mov si, second_val
  add bx, 8
  call _draw_string

  ;ispis "3:"
  mov si, third_lbl
  add bx, 152
  call _draw_string

  ;ispis vrednosti na SP+4
  mov si, third_val
  add bx, 8
  call _draw_string

  ;ispis "4:"
  mov si, fourth_lbl
  add bx, 152
  call _draw_string

  ;ispis vrednosti na SP+6
  mov si, fourth_val
  add bx, 8
  call _draw_string

  ;ispis "5:"
  mov si, fifth_lbl
  add bx, 152
  call _draw_string

  ;ispis na vrednosti SP+8
  mov si, fifth_val
  add bx, 8
  call _draw_string

  ;ispis "6:"
  mov si, sixth_lbl
  add bx, 152
  call _draw_string

  ;ispis na vrednosti SP+8
  mov si, sixth_val
  add bx, 8
  call _draw_string

  popa
  ret

; crta seg - off - val i njihove vrednosti
_draw_mem_frame:
  pusha

  mov ax, VID_MEM
  mov es, ax
  mov bx, word [starting_pos]

  add bx, 1280 ; da bi se ispisivalo ispod registara opste namene/stack-a

  mov si, seg_lbl
  call _draw_string

  mov si, seg_val
  add bx, 8
  call _draw_string

  mov si, off_lbl
  add bx, 152
  call _draw_string

  mov si, off_val
  add bx, 8
  call _draw_string

  mov si, value_lbl
  add bx, 152
  call _draw_string

  mov si, value_val
  add bx, 8
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

; smesta podatke iz registra u string labelu u hex prezentaciji
; AX = value to print
; SI - string u koji upisujemo
_reg_hex:
  pusha
  mov cx,4        ; stampa 4 hex cifre (= 16 bits)
  mov bx, 0       ; brojac za trenutnu poziciju u stringu
  .print_digit:
      rol ax,4   ; premesta trenutno najlevlju cifru u 4 najmanje znacajna bita
      mov dl,al
      and dl,0xF  ; izolujemo hex cifru koju hocemo da odstampamo
      add dl,'0'  ; konvertujemo u karakter
      cmp dl,'9'  ; ...
      jbe .ok     ; ...
      add dl,7    ; ... (za 'A'..'F')
      .ok:            ; ...
        mov byte[si+bx], dl ; u dl se nalazi ASCII char
        inc bx
        loop .print_digit

  popa
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
ax_val: db "    h", 0 ; string sa 4 pozicije ( u te 4 pozicije se smesta vrednost registra)
bx_val: db "    h", 0
cx_val: db "    h", 0
dx_val: db "    h", 0
si_val: db "    h", 0
di_val: db "    h", 0

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
first_val: db "    h", 0
second_val: db "    h", 0
third_val: db "    h", 0
fourth_val: db "    h", 0
fifth_val: db "    h", 0
sixth_val: db "    h", 0


;--------------------------------

;labele za ispis memorijske lokacije na ekranu
seg_lbl: db "seg", 0
off_lbl: db "off", 0
value_lbl: db "val", 0

seg_val: db "    h", 0
off_val: db "    h", 0
value_val: db "    h", 0

;vrednost koja se nalazi u AH kad se pozove int 60h
int_val: db 0


temp_reg_val_holder1: dw 0 ; sluzi za cuvanje vrednosti registara
temp_reg_val_holder2: dw 0
temp_reg_val_holder3: dw 0
temp_reg_val_holder4: dw 0
