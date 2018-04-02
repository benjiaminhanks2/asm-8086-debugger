;fajl koji sadrzi metode za ispis pomocnih poruka na ekran

;ispisuje string terminisan '$' na ekran
;adresa poruke koja se ispisuje mora se nalaziti u DX pre poziva ove funkcije
_print_msg:
      pusha
      mov  ah, 9       ; DOS funkcija za ispisivanje
      int  21h         ; DOS sistemski poziv
      popa
      ret

;stampa sadrzaj od start_msg labele
_print_start_msg:
      pusha ; cuva registre
      mov dx, start_msg ;smesta pocetnu adresu poruke u DX
      call _print_msg ; poziva ispis poruke na ekran
      popa ; vraca vrednosti sacuvanih registara
      ret

_print_ax_msg:
      pusha ; cuva registre
      mov dx, ax_val ;smesta pocetnu adresu poruke u DX
      call _print_msg ; poziva ispis poruke na ekran
      popa ; vraca vrednosti sacuvanih registara
      ret

_print_stop_msg:
      pusha ; cuva registre
      mov dx, stop_msg ;smesta pocetnu adresu poruke u DX
      call _print_msg ; poziva ispis poruke na ekran
      popa ; vraca vrednosti sacuvanih registara
      ret

_print_peek_msg:
      pusha
      mov dx, peek_msg
      call _print_msg
      popa
      ret
_print_missing_args_msg:
      pusha
      mov dx, peek_missing_str
      call _print_msg
      popa
      ret

_print_poke_msg:
      pusha
      mov dx, poke_msg
      call _print_msg
      popa
      ret
_print_poke_args:
      pusha
      mov dx, bonus_cmd_param_1
      call _print_msg
      ; mov dx, bonus_cmd_param_2
      ; call _print_msg
      ; mov dx, bonus_cmd_param_3
      ; call _print_msg
      popa
      ret
segment .data
start_msg: db "Program je startovan.",'$'
stop_msg: db "Program je zaustavljen.",'$'
peek_msg: db "Peek komanda pozvana!","$"
poke_msg: db "Poke komanda pozvana!",'$'
peek_missing_str: db "Los unos argumenata pri pozivu komande!",'$'
