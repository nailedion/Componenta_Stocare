.data
    memorie: .space 1048576
    O: .long 0
    co: .long 0
    formatc_dig: .asciz "%d"
    N: .long 0
    i: .long 0
    j: .long 0
    des: .long 0
    dim: .long 0
    formata_lsc: .asciz "%d: ((%d, %d), (%d, %d))\n"
    li: .long 0
    lf: .long 0
    ci: .long 0
    cf: .long 0
    lgsec: .long 0
    k: .long 0

.text

f_add:
    #ret
    #%esp
    #-4(%esp)
    pushl %esp
    movl %esp, %ebp
    
    pushl $N #citesc nr de adaugari
    pushl $formatc_dig
    call scanf
    addl $8, %esp

    cmpl $0, N #daca nr de adaugari este 0 sar la sf
    je sf_f_add

    movl $0, k #contorizator pentru adaugari
    et_parcurgere_adaugari:
        pushl $des #citesc descriptorul
        pushl $formatc_dig
        call scanf
        addl $8, %esp

        pushl $dim #citesc dimensiunea
        pushl $formatc_dig
        call scanf
        addl $8, %esp

        #transform dimensiunea in blocuri
        movl $0, %edx
        movl dim, %eax
        movl $8, %ecx
        divl %ecx
        movl %eax, dim
        cmpl $0, %edx
        je et_rest0
        addl $1, dim
        et_rest0:

        #pun 0-uri in coordonate in cazul in care nu e spatiu in memorie
        movl $0, ci
        movl $0, cf
        movl $0, li
        movl $0, lf

        movl $0, i #contorizator linii
        et_parc_linii_add:
            movl $0, lgsec

            movl $0, j #contorizator coloane
            et_parc_coloane_add:
                #calculez pozitia din memorie in %eax ca fiind 1024xi+j
                movl i, %eax
                movl $0, %edx
                movl $1024, %ecx
                mull %ecx
                addl j, %eax
                
                #daca e 0 adaug 1 la sec, altfel revine la 0
                cmpb $0, (%edi, %eax, 1)
                je et_eSpatiu
                movl $0, lgsec
                jmp et_compara
                et_eSpatiu:
                addl $1, lgsec

                et_compara:
                movl lgsec, %ecx #compar lgsec sa vad daca e cat dim
                cmpl %ecx, dim
                jne et_nuAmGasitSec #daca nu, mai caut

                #daca da, retin liniile si coloana de final si pun descriptorul pe pozitii
                movl i, %edx
                movl %edx, lf
                movl %edx, li
                movl j, %edx
                movl %edx, cf

                et_pun_des: #pun descriptorul pe lgsec pozitii de la dr spre st
                    movl des, %ebx
                    movb %bl, (%edi, %eax, 1)

                    subl $1, lgsec
                    subl $1, %eax #lgsec e nr de pozitii, iar %eax pozitia in memorie

                    cmpl $0, lgsec
                    jne et_pun_des #daca n am ajuns pe 0 repet

                    #altfel retin coloana de inceput si fac afisarea
                    addl $1, %eax
                    movl $0, %edx
                    movl $1024, %ecx
                    divl %ecx 
                    movl %edx, ci #restul impartirii lui %eax+1 la 1024 este coloana de inceput

                    jmp et_afisare_add

                et_nuAmGasitSec:
                addl $1, j
                cmpl $1024, j #daca ajunge la sfarsit trece de repetare
            jne et_parc_coloane_add

            addl $1, i #daca ajunge la sfarsit trece de repetare
            cmpl $1024, i
        jne et_parc_linii_add

    et_afisare_add:
    #printf(formata_lsc, des, li, ci, lf, cf)
    pushl cf
    pushl lf
    pushl ci
    pushl li
    pushl des
    pushl $formata_lsc
    call printf
    addl $24, %esp
    et_dupaaf:
    
    addl $1, k
    movl k, %ecx
    cmpl N, %ecx
    jne et_parcurgere_adaugari  #daca ajunge la N trece de repetare

    sf_f_add:
    popl %esp
    ret

f_get:
    

.global main

main:#scanf("%d", &O)
    pushl $O
    pushl $formatc_dig
    call scanf
    addl $8, %esp

    leal memorie, %edi

movl $0, %ecx
et_parc_op:
    #for(int i=0;i<O;i++)
    #scanf("%d", &co)
    #aleg fct potriv
    cmpl O, %ecx
    je et_exit
    addl $1, %ecx

    pushl %ecx
    pushl $co
    pushl $formatc_dig
    call scanf
    addl $8, %esp
    popl %ecx

    cmpl $1, co
    je et_add
    cmpl $2, co
    je et_get
    cmpl $3, co
    je et_delete
    cmpl $4, co
    je et_defragmentation

et_add:
    pushl %ecx #pun pe stiva %ecx-ul ca sa nu l pierd la apelarea fct f_add

    call f_add

    popl %ecx #scot %ecx-ul dupa fct

    jmp et_parc_op

et_get:
    pushl %ecx #pun pe stiva %ecx-ul ca sa nu l pierd la apelarea fct f_add

    call f_get

    popl %ecx #scot %ecx-ul dupa fct

    jmp et_parc_op

et_delete:

et_defragmentation:

et_exit:
    pushl $0
    call fflush
    popl %eax
    movl $1, %eax
    movl $0, %ebx
    int $0x80