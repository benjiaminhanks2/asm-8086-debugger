;U ovom fajlu se nalaze sve metode za rad sa stringovima

;adresa prvog stringa se nalazi u SI
;adresa drugog stringa se nalazi u DI
;rezultat se nalazi u labeli cmp_result i moze biti 0 ako nisu isti, i 1 ako su poredjeni stringovi isti
_strcmp:
  pusha

  mov al, byte [si] ;karakter prvog stringa smestamo u AL
  mov ah, byte [di] ;karakter drugog stringa smestamo u AH

  call _strlen
  mov cl, byte [str_len]
  .strcmp_loop:
    cmp cl, 0
    je .strcmp_equal


    mov al, byte [si] ;karakter prvog stringa smestamo u AL
    mov ah, byte [di] ;karakter drugog stringa smestamo u AH

    cmp al, ah
    jne .strcmp_not_equal

    inc di
    inc si
    dec cx
    jmp .strcmp_loop


  .strcmp_not_equal:
    mov byte [cmp_result], 0 ;nisu jednaki, upisujemo nula u labelu
    popa
    ret

  .strcmp_equal:
    mov byte [cmp_result], 1
    popa
    ret





;podrazumeva da se adresa prvog karaktera u stringu nalazi u SI
; rezultat smesta str_len
_strlen:
  pusha ; cuva se sadrzaj registara
  mov cx, 0 ; postavlja CX na 0. CX sluzi za pracenje duzine stringa

  .strlen_loop:
    mov al, byte [si] ;smesta karakter u AL
    cmp al, 0h ;poredi da li je kraj stringa
    je .strlen_end ;ukoliko je kraj stringa onda se skace na kraj procedure
    inc cx ; ukoliko nije kraj cx se inkrementira i petlja se ponovo izvrsava
    inc si ; pomeramo se na sledecu adresu u SI
    jne .strlen_loop

  .strlen_end:
    mov byte[str_len], cl
    popa
    ret

;u SI se nalazi string koji konvertujemo u int
;rezultat konvertovanja se nalazi u AX
_str_to_int:
  pusha

  xor ax, ax ;AX sluzi kao akumulator
  xor bx, bx ;sluzi kao brojac pozicije u stringu
  xor cx, cx ;sluzi kao brojac za .loop_str_to_int petlju
  xor dx, dx ;DX sluzi za operacije nad karakterom u stringu

  call _strlen ;trazimo duzinu stinga koji konvertujemo
  mov cl, byte [str_len] ;smestamo u CX duzinu stringa


  .loop_str_to_int:
  inc bx ;indikator na kom smo karakteru
  xor dx, dx ;cistimo dx
  mov dl, byte [si] ;smestamo prvi karakter u dx
  sub dx, 48 ;oduzimamo ASCII nulu -> '1' - '0' = 1

  ;mnozenje sa osnovom 10
  pusha
  mov word [tmp_var], bx ; u temp_var smestamo poziciju  karaktera u stringu
  mov bl, byte[str_len] ; u bx smestamo duzinu stringa
  sub bx, word[tmp_var] ; duzina stringa - trenutni karakter

  mov ax, dx ; ax = mnozenik
  .loop_multiply:
  cmp bx, 0
  je .end_of_multiply

  mov cx, 10 ; cx = mnozilac
  mul cx ; ax = ax * cx
  dec bx
  jmp .loop_multiply

  .end_of_multiply:
  mov word [tmp_var], ax
  popa

  ;kraj mnozenja

  mov dx, word [tmp_var] ; smestamo rezultat mnozenja u dx

  add ax, dx ; sabiramo na akumulator
  inc si; prelazimo na sledeci char u stringu
  loop .loop_str_to_int

  ;pronasli smo broj, nalazi u se u ax
  mov word [tmp_var], ax
  popa
  mov ax, word [tmp_var]
  ret


; u SI se nalazi string koji konvertujemo u hex
; rezultat konvertovanja se nalazi u AX
_str_to_hex:
  pusha

  xor ax, ax ;AX sluzi kao akumulator
  xor bx, bx ;sluzi kao brojac pozicije u stringu
  xor cx, cx ;sluzi kao brojac za .loop_str_to_int petlju
  xor dx, dx ;DX sluzi za operacije nad karakterom u stringu

  call _strlen ;trazimo duzinu stinga koji konvertujemo
  mov cl, byte [str_len] ;smestamo u CX duzinu stringa


  loop_str_to_hex:
  inc bx ;indikator na kom smo karakteru
  xor dx, dx ;cistimo dx
  mov dl, byte [si] ;smestamo prvi karakter u dx

  cmp dl, 'A' ; poredimo sa 'a'
  jl char_is_a_num
  jmp char_is_a_letter

  char_is_a_num:
  sub dx, 48 ;oduzimamo ASCII nulu -> '1' - '0' = 1
  jmp convert_to_hex

  char_is_a_letter:
  sub dx, 48
  sub dx, 7 ; npr: 'F' je 70 ASCII -> 70 - 48 = 22 - 7 = 15

  convert_to_hex:
  ;mnozenje sa osnovom 16
  pusha
  mov word [tmp_var], bx ; u temp_var smestamo poziciju  karaktera u stringu
  mov bl, byte[str_len] ; u bx smestamo duzinu stringa
  sub bx, word[tmp_var] ; duzina stringa - trenutni karakter

  mov ax, dx ; ax = mnozenik
  .loop_multiply_hex:
  cmp bx, 0
  je .end_of_multiply_hex

  mov cx, 16 ; cx = mnozilac
  mul cx ; ax = ax * cx
  dec bx
  jmp .loop_multiply_hex

  .end_of_multiply_hex:
  mov word [tmp_var], ax
  popa

;kraj mnozenja

  mov dx, word [tmp_var] ; smestamo rezultat mnozenja u dx

  add ax, dx ; sabiramo na akumulator
  inc si; prelazimo na sledeci char u stringu
  loop loop_str_to_hex

  ;pronasli smo broj, nalazi u se u ax
  mov word [tmp_var], ax
  popa
  mov ax, word [tmp_var]
  ret

; string iz kojeg kopiramo nalazi se u SI
; string u koji kopiramo nalazi se u DI
_strcpy:
  pusha
  xor ax, ax
  xor cx, cx

  call _strlen ; da znamo koliko kopiramo
  mov cl, byte [str_len]

  loop_cpy:
  cmp cl, 0
  je done_copying
  mov al, byte [si]
  mov byte [di], al
  inc si
  inc di
  loop loop_cpy

  done_copying:
  popa
  ret
segment .data
cmp_result: db 0
str_len: db 0
tmp_var: dw 0
