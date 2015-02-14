
extrn malloc
extrn getenv
extrn fopen
extrn fclose
extrn fread
extrn fwrite
extrn fseek
extrn ftell
extrn time
extrn exit
extrn 'free' as libc_free
extrn 'write' as libc_write

alloc:
	ccall	malloc,rax
	test	eax,eax
	jz	allocation_failed
	clc
	ret
allocation_failed:
	stc
	ret
free:
	ccall	libc_free,rax
	ret
display_string:
	lodsb
	or	al,al
	jz	string_displayed
	mov	dl,al
	call	display_character
	jmp	display_string
      string_displayed:
	ret
    display_character:
	mov	[character],dl
	ccall	libc_write,[display_handle],character,1
	ret
open:
	push	rsi rdi rbp
	call	adapt_path
	ccall	fopen,buffer,open_mode
	pop	rbp rdi rsi
	or	rax,rax
	jz	file_error
	mov	rbx,rax
	clc
	ret
adapt_path:
	mov	rsi,rdx
	mov	rdi,buffer
copy_path:
	lods	byte [rsi]
	cmp	al,'\'
	jne	path_char_ok
	mov	al,'/'
path_char_ok:
	stos	byte [rdi]
	or	al,al
	jnz	copy_path
	cmp	rdi,buffer+1000h
	ja	not_enough_memory
	ret
create:
	push	rsi rdi rbp
	call	adapt_path
	ccall	fopen,buffer,create_mode
	pop	rbp rdi rsi
	or	eax,eax
	jz	file_error
	mov	ebx,eax
	clc
	ret
close:
	push rsi
	ccall	fclose,rbx
	pop rsi
	ret
read:
	push	rbx rcx rdx rsi rdi
	ccall	fread,rdx,1,rcx,rbx
	pop	rdi rsi rdx rcx rbx
	cmp	eax,ecx
	jne	file_error
	clc
	ret
    file_error:
	stc
	ret
write:
	push	rbx rcx rdx rsi rdi
	ccall	fwrite,rdx,1,rcx,rbx
	pop	rdi rsi rdx rcx rbx
	cmp	eax,ecx
	jne	file_error
	clc
	ret
lseek:
	push	rbx
	movzx	eax,al
	ccall	fseek,rbx,rdx,rax
	mov	ebx,[rsp]
	ccall	ftell,rbx
	pop	rbx
	ret

open_mode db 'r',0
create_mode db 'w',0
