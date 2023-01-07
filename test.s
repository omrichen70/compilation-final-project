apply:
       push rbp
       mov rbp, rsp 
       ;; last argument is a proper list
  mov r10, qword [rbp + 3 * WORD_SIZE]
  dec r10
  mov rbx, PVAR(r10)  ;; rbx holds the proper list ptr

  xor rax, rax  
  xor rcx, rcx  ;; rcx holds the total number of arguments directed to func

  ;; Gets the proper list length into rax
  mov rdx, rbx
    find_list_length:
    cmp rdx, SOB_NIL_ADDRESS
    je prep_args_copy
    inc rax
    CDR rdx, rdx		;; rdx = rdx.next
    jmp find_list_length
    prep_args_copy:
  ;; Sub the rsp in order to push the proper list elements in reverse
  ;; e.g '(3 4) 3 is below 4 in the stack (has lower address)
 shl rax, 3
  sub rsp, WORD_SIZE
  mov qword [rsp], SOB_NIL_ADDRESS
  sub rsp, rax
  dec r10
  .proper_list_loop:
    cmp rbx, SOB_NIL_ADDRESS
    je .simple_arg_loop

    CAR rdx, rbx
    mov [rsp + 8 * rcx], qword rdx
    CDR rbx, rbx
    inc rcx

    jmp .proper_list_loop

  ;; In the same manner pushing the rest of arguments in reverse
  .simple_arg_loop:
    cmp r10, 0
    je .call

    push PVAR(r10)
    inc rcx
    dec r10
    jmp .simple_arg_loop

  .call:
    push rcx
    mov rax, PVAR(0)
    CLOSURE_ENV rbx, rax
    push rbx
    push qword [rbp + 8]
    push qword [rbp]
    add rcx, 5
    SHIFT_FRAME rcx
    CLOSURE_CODE rcx, rax
   jmp rcx
         pop rbp
         ret