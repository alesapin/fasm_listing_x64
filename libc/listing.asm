
	format	ELF64
	public	main

include 'ccall.inc'

section '.text' executable align 16

  main:
	mov	rcx,rdi
	mov	[argc],rcx
	mov	rbx,rsi
	mov	[argv],rbx

	mov	[display_handle],1

	call	get_params
	jnc	make_listing

	mov	rsi,_usage
	call	display_string
	ccall	exit,2

  make_listing:
	call	listing
	ccall	exit,0

  error:
	mov	[display_handle],2
	mov	rsi,_error_prefix
	call	display_string
	pop	rsi
	call	display_string
	mov	rsi,_error_suffix
	call	display_string
	ccall	exit,0

  get_params:
	mov	rcx,[argc]
	mov	rbx,[argv]
	add	rbx,8
	dec	rcx
	jz	bad_params
get_param:
	mov	rsi,[rbx]
	mov	al,[rsi]
	cmp	al,'-'
	je	option_param
	cmp	[input_file],0
	jne	get_output_file
	mov	[input_file],rsi
	jmp	next_param
      get_output_file:
	cmp	[output_file],0
	jne	bad_params
	mov	[output_file],rsi
	jmp	next_param
      option_param:
	inc	rsi
	lodsb
	cmp	al,'a'
	je	addresses_option
	cmp	al,'A'
	je	addresses_option
	cmp	al,'b'
	je	bytes_per_line_option
	cmp	al,'B'
	je	bytes_per_line_option
      bad_params:
	stc
	ret
      addresses_option:
	cmp	byte [rsi],0
	jne	bad_params
	mov	[show_addresses],1
	jmp	next_param
      bytes_per_line_option:
	cmp	byte [rsi],0
	jne	get_bytes_per_line_setting
	dec	rcx
	jz	bad_params
	add	rbx,8
	mov	rsi,[rbx]
get_bytes_per_line_setting:
	call	get_option_value
	or	rdx,rdx
	jz	bad_params
	cmp	rdx,1000
	ja	bad_params
	mov	[code_bytes_per_line],rdx
next_param:
	add	rbx,8
	dec	rcx
	jnz	get_param
	cmp	[input_file],0
	je	bad_params
	cmp	[output_file],0
	je	bad_params
	clc
	ret
get_option_value:
	xor	rax,rax
	mov	rdx,rax
get_option_digit:
	lodsb
	cmp	al,20h
	je	option_value_ok
	cmp	al,0Dh
	je	option_value_ok
	or	al,al
	jz	option_value_ok
	sub	al,30h
	jc	invalid_option_value
	cmp	al,9
	ja	invalid_option_value
	imul	rdx,10
	jo	invalid_option_value
	add	rdx,rax
	jc	invalid_option_value
	jmp	get_option_digit
option_value_ok:
	dec	rsi
	clc
	ret
invalid_option_value:
	stc
	ret

  include 'system.inc'

  include '..\listing.inc'

section '.data' writeable align 4

  input_file dq 0
  output_file dq 0
  code_bytes_per_line dq 16
  show_addresses db 0

  line_break db 0Dh,0Ah

  _usage db 'listing generator for flat assembler',0Dh,0Ah
	 db 'usage: listing <input> <output>',0Dh,0Ah
	 db 'optional settings:',0Dh,0Ah
	 db ' -a           show target addresses for assembled code',0Dh,0Ah
	 db ' -b <number>  set the amount of bytes listed per line',0Dh,0Ah
	 db 0
  _error_prefix db 'error: ',0
  _error_suffix db '.',0Dh,0Ah,0

section '.bss' writeable align 4

  argc dq ?
  argv dq ?

  input dd ?
  assembled_code dd ?
  assembled_code_length dd ?
  code_end dd ?
  code_offset dd ?
  code_length dd ?
  output_handle dd ?
  output_buffer dd ?
  current_source_file dd ?
  current_source_line dd ?
  source dd ?
  source_length dd ?
  maximum_address_length dd ?
  address_start dd ?
  last_listed_address dd ?

  display_handle dq ?
  character db ?

  params rb 1000h
  characters rb 100h
  buffer rb 1000h
