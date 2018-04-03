org 100h

call _scan_arg_cmd ; parsira argumente komandne linije

cmp byte [parsed_cmd_ID], 0 ; invalidni argumenti
je invalid_arg_handler

cmp byte [parsed_cmd_ID], 1 ; -start
je start_handler

cmp byte [parsed_cmd_ID], 2 ; -stop
je stop_handler

cmp byte [parsed_cmd_ID], 3 ; -peek
je peek_handler

cmp byte [parsed_cmd_ID], 4 ; -poke
je poke_handler

ret

invalid_arg_handler:
  call _print_missing_args_msg
  ret

start_handler:
  call _parse_file_data ; parsira sadrzaj "poz.txt" fajla
  call _print_start_msg
  ret

stop_handler:
  call _print_stop_msg
  ret

peek_handler:
  call _print_peek_msg
  ret

poke_handler:
  call _print_poke_msg
  ret

segment .data
test_test: db "FF11", 0

%include "str_ops.asm"
%include "psp_scn.asm"
%include "monitor.asm"
%include "file_ops.asm"
%include "dbg_lib.asm"
