############ rodata ##############
.section .rodata
    # printf formats
    f_invalid:  .string "invalid option!\n"
    f_invalid2: .string "invalid input!\n"
    f_50:       .string "first pstring length: %d, second pstring length: %d\n"
    f_52:       .string "old char: %c, new char: %c, first string: %s, second string: %s\n"
    f_53_54:    .string "length: %d, string: %s\n"
    f_55:       .string "compare result: %d\n"
    f_scans:    .string " %s"
    f_scand:    .string " %d"
    
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


.section .text
############## run_main.s #############
.globl main
main:
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
    
    ####################### TEST ########################
    movq    %r12, %rdi
    movq    %r13, %rsi
    movq    $0, %rdx
    movq    $4, %rcx
    call    pstrijcmp
    movq    %rax, %rsi
    movq    $f_55, %rdi
    call    printf
    
    movq    %r12, %rdi
    movq    %r13, %rsi
    movq    $5, %rdx
    movq    $5, %rcx
    call    pstrijcpy
    
    movq    %r12, %rdi
    call    pstrlen
    movq    %rax, %rsi
    movq    $f_53_54, %rdi
    movq    %r12, %rdx
    incq    %rdx
    xorq    %rax, %rax
    call    printf
    
    movq    %r12, %rdi
    xorq    %rsi, %rsi
    xorq    %rdx, %rdx
    movq    $1, %rsi
    movq    $120, %rdx
    call    replaceChar
    xorq    %rsi, %rsi
    movb    (%r12), %sil
    movq    $f_53_54, %rdi
    leaq    1(%r12), %rdx
    xorq    %rax, %rax
    call    printf
    
    movq    %r13, %rdi
    call    pstrlen
    movq    %rax, %rsi
    movq    $f_53_54, %rdi
    leaq    1(%r13), %rdx
    xorq    %rax, %rax
    call    printf

    #####################################################
    
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
    
#################### func_select.s ####################

# func_select function.
# 1st pstring in %rdi, 2nd pstring in %rsi, command in %rdx
    .globl  func_select
    .type   func_select, @function
func_select:
    ### initialize ###
    pushq   %rbp
    movq    %rsp, %rbp
    xorq    %r10, %r10
    movq    %rdx, %r10      # command
    movq    %rsi, %r9       # 2st pstring
    movq    %rdi, %r8       # 1st pstring
    
    ### start of switch-case ###
    subq    $50, %r10
    cmpq    $10, %r10
    jg      .L2             # x > 60 -> invalid
    cmpq    $0, %r10
    jl      .L2             # x < 50 -> invalid
    jmp     *.L1(,%r10,8)   # 50 <= x <= 60 -> table
    
.L4:                        # for 50 or 60
    #DO THINGS
    jmp     .L3
  
.L5:                        # for 52
    #DO THINGS
    jmp     .L3
    
.L6:                        # for 53
    #DO THINGS
    jmp     .L3
    
.L7:                        # for 54
    #DO THINGS
    jmp     .L3
    
.L8:                        # for 55
    #DO THINGS
    jmp     .L3
      
          
.L2:                        # for invalid options
    movq    $f_invalid, %rdi
    xorq    %rax, %rax
    call    printf
    
.L3:                        # end of switch-case
    movq    %rbp, %rsp
    popq    %rbp
    ret
    
    
#################### pstring.s ####################

# pstrlen function. loc of pstring in %rdi, returns its length.
    .globl  pstrlen
    .type   pstrlen, @function
pstrlen:
    xorq    %rax, %rax
    movb    (%rdi), %al
    ret
    
# replaceChar function. replace all the old char in the new char.
# pstring in %rdi, old char in %rsi, %new char in %rdx
    .globl  replaceChar
    .type   replaceChar, @function
replaceChar:
    movq    %rdi, %r8       # save the pstring loc
    jmp     .L10            # first check the while condition
    ### start of loop ###
.L9:
    cmpb    (%rdi), %sil    # if old char = new char
    jne     .L10
    movb    %dl, (%rdi)     # replace

.L10:                       # while current char != '\0', jump to loop
    incq    %rdi            
    cmpq    $0, (%rdi)      # '\0' equals 0 in ASCII
    jne     .L9
    movq    %r8, %rax
    ret
    
# pstrijcpy function. put the src in dst in i-j index
# dst in %rdi, src in %rsi, i in %rdx, j in %rcx
    .globl  pstrijcpy
    .type   pstrijcpy, @function
pstrijcpy:
    ### initialize ###
    call    pstrlen         # dst already in %rdi
    movq    %rax, %r8       # dst length in %r8
    
    movq    %rdi, %r9       # save %rdi for later
    movq    %rsi, %rdi
    call    pstrlen
    movq    %r9, %rdi       # restore %rdi
    movq    %rax, %r9       # src length in %r9
    movq    %rdi, %r10      # save dst loc for return value


    ### input check ###
    cmpq    $0, %rdx
    jl      .L11            # if i < 0 -> invalid
    cmpq    %rdx, %rcx      # cmp j:i
    jl      .L11            # if j < i -> invalid
    cmpq    %rcx, %r8       # cmp (dst length):j
    jl      .L11            # if length < j -> invalid
    cmpq    %rcx, %r9       # cmp (src length):j
    jl      .L11            # if length < j -> invalid
    
    movq    %rdi, %r10      # save dst loc for return value
    leaq    1(%rdi, %rdx), %rdi      # %rdi = dst[i]
    leaq    1(%rsi, %rdx), %rsi      # %rsi = src[i]
    
    ### while loop ###
    jmp .L13
    
.L14:                       # the loop
    movb    (%rsi), %r11b
    movb    %r11b, (%rdi)   # replace!
    incq    %rdx            # i++
    incq    %rdi            # %rdi = dst[i+1]
    incq    %rsi            # %rsi = src[i+1]
    
    
.L13:                       # while condition
    cmpq    %rdx, %rcx      # cmp j:i
    jge     .L14            # if j != i -> loop
    jmp     .L12            # done -> end function
    
.L11:                       # invalid input
    movq    $f_invalid2, %rdi
    xorq    %rax, %rax
    call    printf

.L12:                       # end function
    movq    %r10, %rax
    ret

# swapCase function. turns uppercase to lowercase and the opposite.
# pstring in %rdi.
    .globl  swapCase
    .type   swapCase, @function
swapCase:
    ### start of while loop ###
    jmp     .L16            # jump to condition

.L15:                       # the loop
    cmpb    $65, (%rdi)     # cmp char:A
    jl      .L16            # if < -> break
    cmpb    $122, (%rdi)    # cmp char:z
    jg      .L16            # if > -> break
    cmpb    $90, (%rdi)     # cmp char:Z
    jle     .L18            # if <= -> uppercase to lowercase
    cmpb    $97, (%rdi)     # cmp char:a
    jge     .L17            # if >= -> lowercase to uppercase
    jmp     .L16            # otherwise its not a letter
    
        # uppercase -> lowercase
.L18:
    addb    $32, (%rdi)
    jmp .L16
    
        # lowercase -> uppercase
.L17:
    subb    $32, (%rdi)

.L16:                       # loop condition
    incq    %rdi
    cmpb    $0, (%rdi)      # cmp 0:char
    jne     .L15            # if != -> loop
    ret                     # done
    
# pstrijcmp function. returns: 0 if pstr1 = pstr2, 1 if
# pstr1 > pstr2, -1 if pstr1 < pstr2, -2 for invalid input.
# pstr1 in %rdi, pstr2 in %rsi, i in %rdx, j in %rcx.
    .globl  pstrijcmp
    .type   pstrijcmp, @function
pstrijcmp:
    ### initialize ###
    incq    %rdi
    incq    %rsi
    addq    %rdx, %rdi      # %rdi = pstr1[i]
    addq    %rdx, %rsi      # %rsi = pstr2[i]
    xorq    %r8, %r8
    movb    (%rdi), %r8b    # %r8 = pstr1 length
    xorq    %r9, %r9
    movb    (%rsi), %r9b    # %r9 = pstr2 length
    xorq    %r10, %r10      # for the loop
    
    ### input check ###
    cmpq    $0, %rdx
    jl      .L21            # if i < 0 -> invalid
    cmpq    %rdx, %rcx      # cmp j:i
    jl      .L21            # if j < i -> invalid
    cmpq    %rcx, %r8       # cmp (pstr1 length):j
    jl      .L21            # if length < j -> invalid
    cmpq    %rcx, %r9       # cmp (pstr2 length):j
    jl      .L21            # if length < j -> invalid
    
    ### while loop ###
    jmp     .L20            # jump to condition
.L19:                       # the loop
    movb    (%rdi), %r10b   # %r10 = pstr1[i] char value
    cmpb    (%rsi), %r10b   # cmp pstr1:pstr2 char value
    jl      .L23            # if < -> pstr1 > pstr2 (lex)
    cmpb    (%rsi), %r10b   # cmp pstr1:pstr2 char value
    jg      .L22            # if > -> pstr1 < pstr2 (lex)
    incq    %rdi            # %rdi = pstr1[i+1]
    incq    %rsi            # %rsi = pstr2[i+1]
    incq    %rdx            # i++

.L20:                       # while condition
    cmpq    %rdx, %rcx      # cmp j:i
    jne     .L19            # if j != i -> loop
        # if loop ended then pstrings are equal
    xorq    %rax, %rax
    jmp     .L24            # ret 0
    
.L23:                       # pstr1 > pstr2 (lexicographic)
    movq    $1, %rax
    jmp     .L24            # ret 1

.L22:                       # pstr1 < pstr2 (lexicographic)
    movq    $-1, %rax
    jmp     .L24            # ret -1

.L21:                       # invalid input
    movq    $f_invalid2, %rdi
    xorq    %rax, %rax
    call    printf
    movq    $-2, %rax       # ret -2
    
.L24:
    ret   
    