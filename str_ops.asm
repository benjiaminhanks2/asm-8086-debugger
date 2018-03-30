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
    mov byte [cmp_result], 0 ; nisu jednaki, upisujemo nula u labelu
    popa
    ret

  .strcmp_equal:
    mov byte [cmp_result], 1
    popa
    ret





;podrazumeva da se adresa prvog karaktera u stringu nalazi u SI
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



segment .data
cmp_result: db 0
str_len: db 0
