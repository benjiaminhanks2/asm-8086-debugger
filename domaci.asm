org 100h

  ;call _scan_arg_cmd
;  call _parse_file_data
  ;lcall _draw_frame
  ; call _scan_arg_cmd ; parsira argumente komandne linije
  ; cmp byte[parsed_cmd_ID], 1 ; ukoliko je uneta komanda start
  ; je start_handler
  ; call _parse_file_data
  ; call _debugger
  ; ret
  ;test_case
  mov ax, 1234h
  mov bx, 5667h
  mov cx, 890h
  mov dx, 0AAAAh

  call _parse_file_data
  call _calculate_starting_pos

  mov ax, 1234h
  push ax
  mov ax, 5678h
  push ax
  mov ax, 0089h
  push ax
  mov ax, 0AAAAh
  push ax
  mov ax, 0BBBBh
  push ax
  mov ax, 0CCCCh
  push ax


  mov ah, 1
  call _int_60h_handler
  call _draw_stack_frame


  pop ax
  pop ax
  pop ax
  pop ax
  pop ax
  pop ax

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
