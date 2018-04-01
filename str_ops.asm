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

  mov ax, 0 ;AX sluzi kao akumulator
  mov bx, 0 ;sluzi kao brojac pozicije u stringu
  mov cx, 0 ;sluzi kao brojac za .loop_str_to_int petlju
  mov dx, 0 ;DX sluzi za operacije nad karakterom u stringu

  call _strlen ;trazimo duzinu stinga koji konvertujemo
  mov cl, byte [str_len] ;smestamo u CX duzinu stringa


  .loop_str_to_int:
  inc bx ;indikator na kom smo karakteru
  xor dx, dx ;cistimo dx
  mov dl, byte [si] ;smestamo prvi karakter u dx
  sub dx, 48 ;oduzimamo ASCII nulu -> '1' - '0' = 1

  ;mnozenje sa osnovom 10
  pusha
  mov word [tmp_var], bx ; u temp_var smestamo trenutni karakter
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

segment .data
cmp_result: db 0
str_len: db 0
tmp_var: dw 0
