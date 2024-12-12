.data
    memorie: .space 1024
    lgmem: .long -1
    O: .long 0
    co: .long 0
    formatc_dig: .asciz "%d"
    formata_add0: .asciz "(0, 0)\n" #formata_add0: .asciz "%d: (0, 0)\n"
    formata_add: .asciz "%d: (%d, %d)\n"
    formata_get: .asciz "(%d, %d)\n"
    afis: .asciz "%c %d"
    N: .long 0
    des: .long 0
    dim: .long 0
    poz: .long 0
    lgsec: .long 0

.text

.global main

main:#scanf("%d", &O)
    pushl $O
    pushl $formatc_dig
    call scanf
    addl $8, %esp

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
    leal memorie, %edi
    pushl %ecx #pun %ecx-ul din parcurgerea op
    pushl $N
    pushl $formatc_dig
    call scanf
    addl $8, %esp

    movl $0, %ecx
    et_citire_des_dim:
        pushl %ecx #pun %ecx-ul din parcurgerea des si dim
        
        pushl $des
        pushl $formatc_dig
        call scanf
        addl $8, %esp

        pushl $dim
        pushl $formatc_dig
        call scanf
        addl $8, %esp

        movl $0, %edx
        movl dim, %eax
        pushl %ecx #fac divl $8
        movl $8, %ecx
        divl %ecx
        popl %ecx
        cmpl $0, %edx
        je et_are_rest0
        addl $1, %eax
        et_are_rest0:
        movl %eax, dim
        
        movl $-1, poz
        movl $0, lgsec
        movl $-1, %ecx
        et_cauta_poz: #caut pozitiile pe care ar incapea fisierul des
            addl $1, %ecx

            cmpb $0, (%edi,%ecx,1)
            jne et_nucreste_lgsec
            addl $1, lgsec
            jmp et_creste_lgsec
            et_nucreste_lgsec:
            movl $0, lgsec
            et_creste_lgsec:

            movl dim, %eax
            cmpl %eax, lgsec
            jne et_verif_sf_poz #posibil sa nu verifice daca incape in memorie ocupa un singur byte
            
            #compar ecx cu lgmem sa memorez locatia ultimului byte ocup in memorie
            cmpl %ecx, lgmem #lgmem ecx
            jg et_lgMaiMare
            movl %ecx, lgmem
            et_lgMaiMare:

            #afis pozitiile pe care am pus descriptorul
            #printf(formata_add ,des ,%ecx-dim+1 ,%ecx)
            movl %ecx, %eax
            subl dim, %eax
            addl $1, %eax

            pushl %ecx
            pushl %eax
            pushl des
            pushl $formata_add
            call printf
            addl $12, %esp
            popl %ecx

            #acum pun de la dreapta la stanga des pe dim pozitii
            movl %ecx, %edx #edx va fi poz din vector, iar ecx va fi contor pentru cati bytes tb inlocuiti
            movl dim, %ecx
            movl des, %ebx
            et_pune_des: #daca a intrat pe eticheta asta sare pana la ... sa nu mai am tb cu ecx-ul
                movb %bl, (%edi, %edx, 1)
                subl $1, %edx

                loop et_pune_des

            jmp et_gasit_poz

            et_verif_sf_poz:
                cmpl $1024, %ecx #verific daca a ajuns
                jne et_cauta_poz
                #printf(formata_add0, des)
                pushl %ecx
                #pushl des
                pushl $formata_add0
                call printf
                #addl $8, %esp
                addl $4, %esp
                popl %ecx

        et_gasit_poz:
        popl %ecx #scot %ecx-ul din parcurgerea des si dim
        addl $1, %ecx
        cmpl N, %ecx
        jne et_citire_des_dim

    popl %ecx #scot %ecx-ul din parcurgerea op
    jmp et_parc_op

et_get: #oare or pune descriptorul 0????
    pushl %ecx #pun contorizatorul din parc op

    #scanf(formatc_dig, des)
    pushl $des
    pushl $formatc_dig
    call scanf
    addl $8, %esp
    movl des, %ebx

    movl $-1, dim

    movl $0, %ecx
    et_get_des:
        cmpb %bl, (%edi, %ecx, 1)
        jne et_sariPesteGet
        movl %ecx, dim

        et_cautSf_get:
            addl $1, %ecx

            cmpl %ecx, lgmem #lgmem ecx
            jb et_afis_get

            cmpb %bl, (%edi, %ecx, 1)
            jne et_afis_get

            jmp et_cautSf_get

    et_sariPesteGet:
        addl $1, %ecx
        cmpl %ecx, lgmem #lgmem ecx
        jge et_get_des

    et_afis_get:
        cmpl $-1, dim
        jne et_afis_get_exista

        pushl $0
        pushl $0
        pushl $formata_get
        call printf
        addl $12, %esp

        jmp et_sf_get

    et_afis_get_exista:
        movl dim, %ebx
        movl %ecx, dim
        subl $1, dim
        pushl dim
        movl %ebx, dim
        pushl dim
        pushl $formata_get
        call printf
        addl $12, %esp

    et_sf_get:

    popl %ecx #scot contorizatorul din parc op
    jmp et_parc_op

et_delete:
    pushl %ecx #pun contorizatorul din parc op

    #scanf(formatc_dig, des) si pun des in %ebx
    pushl $des
    pushl $formatc_dig
    call scanf #citire
    addl $8, %esp
    movl des, %ebx

    movl $-1, dim

    movl lgmem, %ecx
    movl %ecx, lgsec #pun in lgsec lungimea pt ca lgmem va fi inlocuita la final cu lgsec

    movl $0, %ecx
    et_delete_des: #cautarea des care tb sters
        cmpb %bl, (%edi, %ecx, 1)
        jne et_sariPesteDelete
        movl %ecx, dim

        et_cautSf_Delete: #cauta capatul drept
            addl $1, %ecx

            cmpl %ecx, lgmem #lgmem ecx
            movl dim, %edx
            jb et_schimba_lgmem 

            cmpb %bl, (%edi, %ecx, 1)
            jne et_afis_delete

            jmp et_cautSf_Delete

    et_sariPesteDelete:
        addl $1, %ecx
        cmpl %ecx, lgmem #lgmem ecx
        jge et_delete_des

    jmp et_afis_delete

    et_schimba_lgmem:
        subl $1, %edx
        movl %edx, lgsec

    et_afis_delete:
        movl dim, %ebx
        cmpl $-1, dim
        je et_afis_delete_exista

        #%ebx=start %ecx=stop+1
        et_trecem_pe0:
            movb $0, (%edi, %ebx, 1)
            addl $1, %ebx
            cmpl %ebx, %ecx
            jne et_trecem_pe0

    et_afis_delete_exista:     
        movl $0, dim #folosesc dim pt capat st si %ecx pt capat dr si des pt descriptor
        movl $0, %ebx
        movl $0, %ecx
        movb (%edi, %ecx, 1), %bl
        movl %ebx, des

        #for(i=0;i<=lgmem;i++)
        #if(v[i]!=st)
        #afis (st, dr)

        movl $1, %ecx
        
        cmpl %ecx, lgmem #lgmem %ecx
        jge et_afis_dupa_delete
        #cazul de mai jos unde am un sg elem sau niciunul
        
        #if(des !=0)
        #printf("format",des , st, dr)
        cmpl $0, %ebx
        popl %ecx #scot contorizatorul din parc op ####
        je et_parc_op

        pushl %ecx
        pushl $0
        pushl %ebx
        pushl $formata_add
        call printf
        addl $8, %esp
        popl %ecx

        et_afis_dupa_delete:
            movl $0, %ebx
            movb (%edi, %ecx, 1), %bl
            cmpl des, %ebx
            je et_salt_delete

                cmpl $0, des
                je et_inainte_salt_delete

                pushl %ebx
                subl $1, %ecx
                pushl %ecx
                pushl dim
                pushl des
                pushl $formata_add
                call printf
                addl $12, %esp
                popl %ecx
                popl %ebx
                addl $1, %ecx

            et_inainte_salt_delete:
                movl %ecx, dim

            et_salt_delete:
            movl %ebx, des
            addl $1, %ecx
            cmpl %ecx, lgmem #lgmem %ecx
            jge et_afis_dupa_delete

    cmpl $0, des
    je et_sf_del

    pushl %ebx
    subl $1, %ecx
    pushl %ecx
    pushl dim
    pushl des
    pushl $formata_add
    call printf
    addl $12, %esp
    popl %ecx
    popl %ebx
    addl $1, %ecx

    et_sf_del:
    movl lgsec, %edx
    cmpb $0, (%edi, %edx, 1)
    jne et_muta_lgsecINlgmem
    movl $-1, lgsec

    movl $-1, %ecx
    et_cauta_dif0:
        addl $1, %ecx

        cmpl $0, (%edi, %ecx, 1)
        je et_sari_cauta_dif0
        movl %ecx, lgsec

        et_sari_cauta_dif0:
        cmpl %ecx, %edx
        jne et_cauta_dif0

    et_muta_lgsecINlgmem:
    movl lgsec, %edx
    movl %edx, lgmem
    popl %ecx #scot contorizatorul din parc op
    jmp et_parc_op

et_defragmentation:
    pushl %ecx #pun ecx-ul din parcurgerea co
    movl $0, %edx #contorizez in %edx cate pozitii am mutat in memorie ca sa stiu cate sa scad la sfarsit

    cmpl $-1, lgmem
    je et_termina_defragmentation

    movl lgmem, %ecx
    movl %ecx, lgsec #salvez lgmem in lgsec

    movl $-1, %ecx
    et_parc_memorie: #parcurgerea memoriei
        addl $1, %ecx
        cmpl %ecx, lgmem #lgmem ecx
        jb et_sfarsit_defragmentation

        cmpb $0, (%edi, %ecx, 1) 
        jne et_parc_memorie #daca nu e 0 pe pozitia ecx, mai cauta

        et_reluare_secv0:
        movl %ecx, %ebx #retin adresa primului 0

        et_cauta_nenul: #caut pozitia primului element nenul
            addl $1, %edx
            addl $1, %ecx
            cmpl %ecx, lgmem #lgmem ecx
            jb et_sfarsit_defragmentation #desi cred ca e degeaba(nu are cum sa fie 0 la finalul memoriei), mai bine sa fie decat sa nu

            cmpb $0, (%edi, %ecx, 1)
            je et_cauta_nenul #daca elem de pe ecx e 0, mai cauta

            #daca a ajuns aici, toate elementele nenule, le muta la stanga cu %ecx-%ebx pozitii(o sa merg cu %ebx si %ecx in acelasi timp) si pun pe poz ecx 0, in cazul in care mai trec pe acolo
            movb (%edi, %ecx, 1), %al
            movb %al, (%edi, %ebx, 1)
            movb $0, (%edi, %ecx, 1)

            et_cauta_nul: #muta si contorizeaza pana gaseste alt element 0 sau sfarsitul memoriei. Daca da de sfarsit se termina, daca da de 0, %ecx devine %ebx si cautam iar sf sec de 0
                addl $1, %ebx
                addl $1, %ecx #trecem la urmatoarele 2 poz
                
                cmpl %ecx, lgmem #lgmem ecx
                jb et_sfarsit_defragmentation #verific sa nu fiu la finalul memoriei, iar daca sunt, sar la final

                cmpb $0, (%edi, %ecx, 1)
                je et_cauta_nenul #daca am mai gasit o secventa de 0-uri refac procesul

                movb (%edi, %ecx, 1), %al
                movb %al, (%edi, %ebx, 1)
                movb $0, (%edi, %ecx, 1) #daca sunt nenule, interschimb val de pe poz ebx si ecx

                jmp et_cauta_nul #refac procesul pana dau de alta secv nula

        jmp et_parc_memorie

    et_sfarsit_defragmentation:
    subl %edx, lgmem #scad din lgmem cate elem am deplasat la stanga

    #afisez memoria
    cmpl $-1, lgmem
    je et_termina_defragmentation #daca memoria e goala, nu am ce afisa

    movl $0, %eax #retin adresa de inceput a primului descriptor 
    movl $0, %ebx #si descriptorul
    movb (%edi, %eax, 1), %bl  

    movl $0, %ecx
    et_afisare_defragmentation:
        addl $1, %ecx
        cmpl %ecx, lgmem #lgmem %ecx 
        jb et_ultima_afis #daca sunt la sf memoriei, fac ultima afisare

        cmpb %bl, (%edi, %ecx, 1)
        je et_afisare_defragmentation #daca sunt egale, continui sa caut capatul

        #scanf(formata_add, %ebx, %eax, %ecx-1) afisez descriptorul si capetele lui
        #%eax=%ecx
        #%bl=(%edi, %ecx, 1)

        pushl %ecx #pun ecx pe stiva pentru ca am nev sa l pun in eax dupa

        subl $1, %ecx
        pushl %ecx
        pushl %eax
        pushl %ebx
        pushl $formata_add
        call printf
        addl $16, %esp

        popl %ecx #scot ecx pe stiva pentru ca am nev sa l pun in eax dupa

        movl %ecx, %eax #retin adresa de inceput a descriptorului
        movl $0, %ebx
        movb (%edi, %eax, 1), %bl #si descriptorul

        jmp et_afisare_defragmentation

    et_ultima_afis:
        subl $1, %ecx
        pushl %ecx
        pushl %eax
        pushl %ebx
        pushl $formata_add
        call printf
        addl $16, %esp

    et_termina_defragmentation:
    popl %ecx #scot ecx-ul din parcurgerea co
    jmp et_parc_op

et_exit:
    pushl $0
    call fflush
    popl %eax
    movl $1, %eax
    movl $0, %ebx
    int $0x80