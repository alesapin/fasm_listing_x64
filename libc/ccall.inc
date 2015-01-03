macro ccall proc,first,second,third,fourth,fifth,sixth,[arg]
{    
	common
		push rdi
		push rsi
		push rdx
		push rcx
		push r8
		push r9
        if ~ first eq
            mov rdi,first
        end if
        if ~ second eq
            mov rsi,second
        end if
        if ~ third eq
            mov rdx,third
        end if
        if ~ fourth eq
            mov rcx,fourth
        end if
        if ~ fifth eq
            mov r8,fifth
        end if
		if ~ sixth eq
			mov r9,sixth
		end if
     	local size
     	size = 0
	reverse
		if ~ arg eq
			pushq arg
			size = size + 8
		end if
    common
	 	xor rax,rax
     	call proc
	 	add rsp,size
        pop r9
        pop r8
        pop rcx
		pop rdx
        pop rsi
		pop rdi
}

