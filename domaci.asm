org 100h

  call _parse_file_data


  mov ax, 256
  ret


segment .data
test_str_to_int: db "48059", 0


%include "str_ops.asm"
%include "psp_scn.asm"
%include "monitor.asm"
%include "file_ops.asm"
