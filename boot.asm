[BITS 16]
[ORG 0x7C00]

start:
    cli
    cld

    ; Charger le noyau en mémoire
    mov ax, 0x1000      ; Segment de destination du noyau
    mov es, ax
    mov bx, 0x0000      ; Offset de destination
    call load_kernel

    ; Passer en mode protégé
    call enter_protected_mode

    ; Transférer le contrôle au noyau
    jmp 0x1000:0x0000   ; Sauter à l'adresse de départ du noyau

load_kernel:
    ; Initialiser les registres pour l'interruption 0x13
    mov ah, 0x02        ; Fonction de lecture du BIOS
    mov al, 3           ; Nombre de secteurs à lire (exemple)
    mov ch, 0           ; Cylindre 0
    mov cl, 2           ; Secteur 2 (le secteur 1 est le secteur de boot)
    mov dh, 0           ; Tête 0
    mov dl, 0x80        ; Premier disque dur
    int 0x13            ; Appel de l'interruption du BIOS
    jc disk_error       ; Gérer les erreurs de disque
    ret

enter_protected_mode:
    ; Configuration du mode protégé (simplifiée)
    ; Chargement du GDT (Global Descriptor Table)
    lgdt [gdt_descriptor]

    ; Activer le mode protégé
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Sauter en mode protégé (16 bits à 32 bits)
    jmp 0x08:protected_mode_entry

gdt_descriptor:
    dw gdt_end - gdt - 1
    dd gdt
gdt:
    ; Descripteurs GDT (simplifiés)
    dq 0x0000000000000000
    dq 0x00CF9A000000FFFF ; Code segment
    dq 0x00CF92000000FFFF ; Data segment
gdt_end:

protected_mode_entry:
    ; Configurer les segments en mode protégé
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000    ; Pile en mode protégé

    ; Transférer le contrôle au noyau (code 32 bits)
    jmp 0x08:0x0000

disk_error:
    ; Gérer les erreurs ici (facultatif)
    hlt

times 510-($-$$) db 0
dw 0xAA55
