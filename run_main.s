    # 208642884 Guy Adani

############ rodata ##############
.section .rodata
        # scanf formats
    f_scans:    .string " %s"
    f_scand:    .string " %d"
    
############ text ##############
.text
.globl  run_main
.type   run_main, @function
run_main:
    movq %rsp, %rbp #for correct debugging
    subq    $8, %rsp            # align for scanf
    movq    %rsp, %rbp          # save frame start
    
    ### first pstring ###
    subq    $256, %rsp          # alocate 256 bytes
        # get length
    movq    $f_scand, %rdi
    leaq    -256(%rbp), %rsi
    movq    %rsi, %r12          # save the string loc for later
    xorq    %rax, %rax
    call    scanf
        # get string
    movq    $f_scans, %rdi
    leaq    -255(%rbp), %rsi
    xorq    %rax, %rax
    call    scanf
    
    ### second pstring ###
    subq    $256, %rsp          # alocate 256 bytes
        # get length
    movq    $f_scand, %rdi
    leaq    -512(%rbp), %rsi
    movq    %rsi, %r13          # save the string loc for later
    xorq    %rax, %rax
    call    scanf
        # get string
    movq    $f_scans, %rdi
    leaq    -511(%rbp), %rsi
    xorq    %rax, %rax
    call    scanf
    
    ### command ###
    subq    $16, %rsp                # alocate 16 bytes
    movq    $f_scand, %rdi
    leaq    -528(%rbp), %rsi
    movq    %rsi, %r14          # save command for later
    xorq    %rax, %rax
    call    scanf
    
    ### go to func_select ###
    xorq    %rdx, %rdx
    movb    (%r14), %dl
    movq    %r13, %rsi
    movq    %r12, %rdi
    call    func_select
    
    ### end main ###
    movq    %rbp, %rsp
    addq    $8, %rsp
    xorq    %rax, %rax
    ret