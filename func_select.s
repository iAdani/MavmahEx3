    # 208642884 Guy Adani
    
############ rodata ##############
.section .rodata
        # printf scanf formats
    f_invalid:  .string "invalid option!\n"
    f_invalid2: .string "invalid input!\n"
    f_50:       .string "first pstring length: %d, second pstring length: %d\n"
    f_52:       .string "old char: %c, new char: %c, first string: %s, second string: %s\n"
    f_53:       .string "length: %d, string: %s\n"
    f_55:       .string "compare result: %d\n"
    f_scans:    .string " %s"
    f_scand:    .string " %d"
    f_scanc:    .string " %c"
    
        # jmp table
    .align 8
.L1:
    .quad   .L4     #case 50
    .quad   .L2     #case 51 - invalid
    .quad   .L5     #case 52
    .quad   .L6     #case 53
    .quad   .L7     #case 54
    .quad   .L8     #case 55
    .quad   .L2     #case 56 - invalid
    .quad   .L2     #case 57 - invalid
    .quad   .L2     #case 58 - invalid
    .quad   .L2     #case 59 - invalid
    .quad   .L4     #case 60 - same as 50

############ text ##############
.section .text
    
# func_select function.
# 1st pstring in %rdi, 2nd pstring in %rsi, command in %rdx
    .globl  func_select
    .type   func_select, @function
func_select:
    ### initialize ###
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %r14
    pushq   %r15
    xorq    %r10, %r10
    movq    %rdx, %r10      # command
    movq    %rsi, %r15      # %r15 = 2st pstring
    movq    %rdi, %r14      # %r14 = 1st pstring
    
    ### start of switch-case ###
    subq    $50, %r10
    cmpq    $10, %r10
    jg      .L2             # x > 60 -> invalid
    cmpq    $0, %r10
    jl      .L2             # x < 50 -> invalid
    jmp     *.L1(,%r10,8)   # 50 <= x <= 60 -> table
    
.L4:                        # for 50 or 60
    movq    %r14, %rdi
    call    pstrlen
    movq    %rax, %rsi      # 1st pstring length
    movq    %r15, %rdi
    call    pstrlen
    movq    %rax, %rdx      # 2nd pstring length
    movq    $f_50, %rdi
    xorq    %rax, %rax
    call    printf
    jmp     .L3
  
.L5:                        # for 52
    ### initialize ###
    pushq   %r13
    pushq   %r12
    pushq   %rbx
    
    ### scanning ###
    leaq    -8(%rsp), %rbx  # scan address
    subq    $8, %rsp        # alocate for scanf
        # scanning old char
    movq    $f_scanc, %rdi
    movq    %rbx, %rsi
    xorq    %rax, %rax
    call    scanf
    xorq    %r12, %r12
    movb    (%rbx), %r12b   # %r12 = old char
        # scanning new char
    movq    $f_scanc, %rdi
    movq    %rbx, %rsi
    xorq    %rax, %rax
    call    scanf
    xorq    %r13, %r13
    movb    (%rbx), %r13b   # %r13 = new char
    
    ### replacing chars ###
        # first pstring
    movq    %r14, %rdi
    movq    %r12, %rsi
    movq    %r13, %rdx
    call    replaceChar
        # second pstring
    movq    %r15, %rdi
    movq    %r12, %rsi
    movq    %r13, %rdx
    call    replaceChar
    
    ### printing ###
    movq    $f_52, %rdi
    movq    %r12, %rsi      # old char
    movq    %r13, %rdx      # new char
    movq    %r14, %rcx
    incq    %rcx            # 1st pstring
    movq    %r15, %r8
    incq    %r8             # 2nd pstring
    xorq    %rax, %rax
    call    printf
    
    ### ending ###
    addq    $8, %rsp
    popq    %rbx
    popq    %r12
    popq    %r13
    jmp     .L3
    
.L6:                        # for 53
    ### initialize ###
    pushq   %r13
    pushq   %r12
    pushq   %rbx
    
    ### scanning ###
    leaq    -8(%rsp), %rbx  # scan address
    subq    $8, %rsp        # alocate for scanf
        # scanning i
    movq    $f_scand, %rdi
    movq    %rbx, %rsi
    xorq    %rax, %rax
    call    scanf
    xorq    %r12, %r12
    movb    (%rbx), %r12b   # %r12 = i
        # scanning j
    movq    $f_scand, %rdi
    movq    %rbx, %rsi
    xorq    %rax, %rax
    call    scanf
    xorq    %r13, %r13
    movb    (%rbx), %r13b   # %r13 = j
    
    ### copying ###
    movq    %r13, %rcx      # j
    movq    %r12, %rdx      # i
    movq    %r15, %rsi      # 2nd pstring
    movq    %r14, %rdi      # 1st pstring
    call    pstrijcpy
    
    ### printing ###
        # first pstring
    movq    %r14, %rdi
    call    pstrlen
    movq    %rax, %rsi      # length
    movq    %r14, %rdx
    incq    %rdx            # pstring
    movq    $f_53, %rdi
    xorq    %rax, %rax
    call    printf
        # second pstring
    movq    %r15, %rdi
    call    pstrlen
    movq    %rax, %rsi      # length
    movq    %r15, %rdx
    incq    %rdx            # pstring
    movq    $f_53, %rdi
    xorq    %rax, %rax
    call    printf
    
    ### ending ###
    addq    $8, %rsp
    popq    %rbx
    popq    %r12
    popq    %r13
    jmp     .L3
    
.L7:                        # for 54
    ### swapping ###
    movq    %r14, %rdi
    call    swapCase
    movq    %r15, %rdi
    call    swapCase

    ### printing ###
        # first pstring
    movq    %r14, %rdi
    call    pstrlen
    movq    %rax, %rsi      # length
    movq    %r14, %rdx
    incq    %rdx            # pstring
    movq    $f_53, %rdi
    xorq    %rax, %rax
    call    printf
        # second pstring
    movq    %r15, %rdi
    call    pstrlen
    movq    %rax, %rsi      # length
    movq    %r15, %rdx
    incq    %rdx            # pstring
    movq    $f_53, %rdi
    xorq    %rax, %rax
    call    printf
    
    jmp     .L3
    
.L8:                        # for 55
    ### initialize ###
    pushq   %r13
    pushq   %r12
    pushq   %rbx
    
    ### scanning ###
    leaq    -8(%rsp), %rbx  # scan address
    subq    $8, %rsp        # alocate for scanf
        # scanning i
    movq    $f_scand, %rdi
    movq    %rbx, %rsi
    xorq    %rax, %rax
    call    scanf
    xorq    %r12, %r12
    movb    (%rbx), %r12b   # %r12 = i
        # scanning j
    movq    $f_scand, %rdi
    movq    %rbx, %rsi
    xorq    %rax, %rax
    call    scanf
    xorq    %r13, %r13
    movb    (%rbx), %r13b   # %r13 = j
    
    ### comparing ###
    movq    %r13, %rcx      # j
    movq    %r12, %rdx      # i
    movq    %r15, %rsi      # 2nd pstring
    movq    %r14, %rdi      # 1st pstring
    call    pstrijcmp
    
    ### printing ###
    movq    %rax, %rsi
    movq    $f_55, %rdi
    xorq    %rax, %rax
    call    printf
    
    ### ending ###
    addq    $8, %rsp
    popq    %rbx
    popq    %r12
    popq    %r13
    jmp     .L3
      
          
.L2:                        # for invalid options
    movq    $f_invalid, %rdi
    xorq    %rax, %rax
    call    printf
    
.L3:                        # end of switch-case
    popq    %r15
    popq    %r14
    movq    %rbp, %rsp
    popq    %rbp
    ret
    