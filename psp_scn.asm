;ovaj fajl sadrzi metode pomocu kojih se skenira sadrzaj argumenata komandne linije
_scan_arg_cmd:
  pusha

  cld
  mov cx, 0080h ;maksimalni broj izvrsavanja instrukcije sa prefiksom REPx
  mov di, 0081h ;pocetak stringa argumenata komandne linije
  mov al, ' ' ; upisujemo space u AL kako bismo pozvali scasb sa repe, koji ce povecavati DI sve dok se ne preskoce svi whitespace-ovi na pocetku komandne linije
  repe scasb

  dec di ;otisli smo jedno mesto unapred, zato dekrementiramo DI
  mov si, di ;cuvamo pocetak stringa u SI
  mov al, 0dh ; ASCII za Enter
  repne scasb
  mov byte [di-1],0h ; terminisemo string nulom "-start\n" -> "-start0" (Nije ASCII znak nula vec vrednost nula)

  ;;; sada imamo SI pokazivac na trimovan argument komandne linije i DI na terminalnu nulu
  mov word [trimmed_arg_address], si ; cuvamo pocetni indeks argumenta komandne linije




  ;proveravamo da li je "-start" zadat kao komanda
  mov si, start_str ; poredimo start_str i argument komandne linije
  mov di, word [trimmed_arg_address]
  call _strcmp ; poredimo argument komandne linije i labelu "-start"

  mov al, byte [cmp_result] ; smestamo rezultat u AL
  cmp al, 1; testiramo da li su stringovi isti
  jz .found_start_cmd ; stringovi se podudaraju pa skacemo za handler za "start"




  ;proveravamo da li je "-stop" zadat kao komanda
  mov si, stop_str
  mov di, word [trimmed_arg_address]
  call _strcmp ; poredimo stop_str i argument komandne linije

  mov al, byte [cmp_result] ; smestamo rezultat u AL
  cmp al, 1
  jz .found_stop_cmd




  ;proveravamo da li je "-peek" zadat kao komanda
  mov si, peek_str
  mov di, word [trimmed_arg_address]
  call _strcmp

  mov al, byte [cmp_result]
  cmp al, 1
  jz .found_peek_cmd

  ;proveravamo da li je "-poke" zadat kao komanda
  mov si, poke_str
  mov di, word [trimmed_arg_address]
  call _strcmp

  mov al, byte [cmp_result]
  cmp al, 1
  jz .found_poke_cmd


  ;do ovog dela dolazi iskljucivo kad nijedna od prethodnih linija koda nije napravila skok,
  ;u smislu da nijedna komanda nije prepoznata
  .found_no_arguments:
    popa
    mov byte[parsed_cmd_ID], 0
    ret
  .found_start_cmd:
    popa
    mov byte[parsed_cmd_ID], 1
    ret

  .found_stop_cmd:
    popa
    mov byte[parsed_cmd_ID], 2
    ret

  .found_peek_cmd:
    call .parse_bonus_params ;skenira bonus parametre
    popa
    mov byte[parsed_cmd_ID], 3
    ret
    
  .found_poke_cmd:
    call .parse_bonus_params
    popa
    mov byte [parsed_cmd_ID], 4
    ret

  .parse_bonus_params:
    pusha
    ;idemo do prvog parametra u "-p*** XXXX YYYY"
    cld
    mov cx, 0080h
    mov di, 0081h
    mov al, ' '
    repe scasb ; preskace whitespace sve do '-' karaktera u "-p*** XXXX YYYY"
    dec di
    repne scasb ; preskacemo do prvog space-a posle komande "-p***_XXXX YYYY" - "_" oznacava poziciju do koje zelimo da stignemo


    mov si, bonus_cmd_param_1
    mov cx, 4 ;zelimo 4 bajta da uzmemo

    ;parsiramo bajtove prvog parametra
    parse_through_param1:
      mov bl, byte [di] ;smestamo sadrzaj parametra u BX
      mov [si], bl ;smestamo sadrzaj BX u bonus_cmd_param_1
      ;prelazimo na sledeci bajt parametra
      inc si
      inc di
      loop parse_through_param1

    ;idemo do drugog space posle komande ("-p*** XXXX_YYYY") - "_" je pozicija na koju zelimo da dodjemo
    mov al, ' '
    mov cx, 0080h
    repe scasb ; preskace whitspace sve do prvog karaktera Y ispred "_" pozicije
    mov si, bonus_cmd_param_2
    mov cx, 4 ;zelimo 4 bajta da uzmemo

    ;parsiramo bajtove drugog parametra
    parse_through_param2:
      mov bl, [di]
      mov [si], bl
      inc si
      inc di
      loop parse_through_param2

    popa
    ret


segment .data
start_str: db "-start",0h
stop_str: db "-stop",0h
peek_str: db "-peek",0h
poke_str: db "-poke",0h
trimmed_arg_address: db 0 ; cuvamo memorijsku adresu ociscenog stringa od space-ova
parsed_cmd_ID: db 0 ; 0 za pogresan argument 1 za start, 2 za stop, 3 za peek, 4 poke
bonus_cmd_param_1: times 4 db 0 ;odnosi se konkretno na komande -peek i -poke, cuva prvi prosledjeni argument posle komande
bonus_cmd_param_2: times 4 db 0 ;cuva drugi prosledjeni argument posle komande
