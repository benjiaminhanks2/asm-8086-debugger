org 100h

  ;call _scan_arg_cmd
;  call _parse_file_data
  ;lcall _draw_frame
  ; call _scan_arg_cmd ; parsira argumente komandne linije
  ; cmp byte[parsed_cmd_ID], 1 ; ukoliko je uneta komanda start
  ; je start_handler
  call _parse_file_data
  call _debugger
  ret


start_handler:
  call _parse_file_data ; ucitava podatke iz fajla
  ret

segment .data



%include "str_ops.asm"
%include "psp_scn.asm"
%include "monitor.asm"
%include "file_ops.asm"
%include "dbg_lib.asm"
%include "dbgr.asm"
