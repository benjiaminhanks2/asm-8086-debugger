org 100h
  call _scan_arg_cmd ;proveravamo koja je komanda prosledjena pri pokretanju programa
                     ;rezultat provere se nalazi u labeli parsed_cmd_ID

  cmp byte [parsed_cmd_ID], 0
  je _print_missing_args_msg

  cmp byte [parsed_cmd_ID], 1 ;ispitujemo da li ID rezultat odgovara ID-u start komande
  je _print_start_msg ;skacemo na ispis ukoliko jeste

  cmp byte [parsed_cmd_ID], 2 ;ispitujemo da li ID rezultat odgovara ID-u stop komande
  je _print_stop_msg

  cmp byte [parsed_cmd_ID], 3 ;peek komanda
  je _print_peek_msg

  cmp byte [parsed_cmd_ID], 4 ;poke komanda
  je _print_poke_msg
  ret

%include "str_ops.asm"
%include "psp_scn.asm"
%include "monitor.asm"
