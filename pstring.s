    # 208642884 Guy Adani
    
############ rodata ##############
.section .rodata
    f_invalid2: .string "invalid input!\n"
    
############ text ##############
.text
.global main
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
    jle      .L11           # if length < j -> invalid
    cmpq    %rcx, %r9       # cmp (src length):j
    jle      .L11           # if length < j -> invalid
    
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
    xorq    %r8, %r8
    movb    (%rdi), %r8b    # %r8 = pstr1 length
    xorq    %r9, %r9
    movb    (%rsi), %r9b    # %r9 = pstr2 length
    decq    %r8
    decq    %r9             # dec lengths for input check
    incq    %rdi
    incq    %rsi
    addq    %rdx, %rdi      # %rdi = pstr1[i]
    addq    %rdx, %rsi      # %rsi = pstr2[i]
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
.L19:                       # the loop
    movb    (%rdi), %r10b   # %r10 = pstr1[i] char value
    cmpb    (%rsi), %r10b   # cmp pstr1:pstr2 char value
    jg      .L23            # if > -> pstr1 > pstr2 (lex)
    cmpb    (%rsi), %r10b   # cmp pstr1:pstr2 char value
    jl      .L22            # if < -> pstr1 < pstr2 (lex)
    incq    %rdi            # %rdi = pstr1[i+1]
    incq    %rsi            # %rsi = pstr2[i+1]
    incq    %rdx            # i++

.L20:                       # while condition
    cmpq    %rdx, %rcx      # cmp j:i
    jge     .L19            # if j >= i -> loop
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
