; ============================================================
; DESIGN NOTES
; ------------------------------------------------------------
; Bootloader Stage 1 (Minimal & Safe)
; ------------------------------------------------------------
; - Architecture: x86 (Real Mode)
; - Load Address: 0x0000:0x7C00 (physical 0x7C00)
; - Size Limit: 512 bytes (1 sector)
; - Environment: BIOS
; - Dependencies: Only BIOS teletype interrupt (int 0x10, AH=0x0E)
; - CS normalization intentionally skipped for simplicity
; - Stack temporarily placed at 0x7BE0 for minimal usage
; ============================================================

; ------------------------------------------------------------
; BIOS loads the first sector to physical address 0x7C00
; ORG directive tells the assembler the intended memory location
; ------------------------------------------------------------
org 0x7C00
bits 16

; ============================================================
; Data Section
; ------------------------------------------------------------
; msg: Null-terminated string to print
; The final 0 marks the end of the string for the print loop
; ============================================================
msg:
    db 'Bootloader stage 1 loaded!', 13, 10
    times 8 db 0           ; padding (optional, not used)

; ============================================================
; Code Section
; ------------------------------------------------------------
; Entry point: start
; -----------------------------------------------------------
start:

    ; --------------------------------------------------------
    ; 1. Disable interrupts temporarily
    ; Prevents unexpected interrupts before stack and segments are ready
    ; --------------------------------------------------------
    cli

    ; --------------------------------------------------------
    ; 2. Initialize segment registers
    ; DS, ES, SS set to 0x0000 for predictable memory addressing
    ; --------------------------------------------------------
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax

    ; --------------------------------------------------------
    ; 3. Initialize stack
    ; Stack grows downward from 0x7BE0
    ; Safe temporary choice for Stage 1
    ; --------------------------------------------------------
    mov sp, 0x7BE0

    ; --------------------------------------------------------
    ; 4. Print the boot message
    ; Usage:
    ;    mov si, msg
    ;    call print_string
    ; Requirements:
    ;    - DS points to the segment containing 'msg'
    ;    - Direction Flag cleared (CLD)
    ; Behavior:
    ;    - Reads bytes from DS:SI
    ;    - Stops at null terminator
    ;    - Prints each character via BIOS int 0x10, AH=0x0E
    ; --------------------------------------------------------
    mov si, msg
    call print_string

    ; --------------------------------------------------------
    ; 5. Halt the CPU safely
    ; Disable interrupts and enter infinite HLT loop
    ; --------------------------------------------------------
    cli
    jmp .hang

; ============================================================
; Subroutine: print_string
; ------------------------------------------------------------
; Prints a null-terminated string pointed to by DS:SI
;
; Registers used:
;   SI - pointer to current character
;   AL - current character
;   AH - BIOS function selector (0x0E)
;
; Clobbered registers:
;   AL, AH, SI
;
; Notes:
;   - CLD ensures SI increments on LODSB
;   - Safe for minimal Stage 1 debugging output
; ============================================================
print_string:
    cld                 ; Clear Direction Flag

.loop:
    lodsb               ; Load byte from DS:SI into AL, increment SI
    test al, al         ; Check for null terminator (0x00)
    jz .done            ; Exit loop if end of string

    mov ah, 0x0E        ; BIOS teletype function
    int 0x10            ; Print character in AL

    jmp .loop           ; Continue with next character

.done:
    ret                 ; Return to caller

; ============================================================
; Infinite halt loop
; ------------------------------------------------------------
; Halts CPU safely after execution
; ============================================================
.hang:
    hlt
    jmp .hang

; ============================================================
; Boot Sector Padding
; ------------------------------------------------------------
; Fill remaining bytes up to 510 with zeros
; ============================================================
times 510-($-$$) db 0

; ============================================================
; Boot Signature (Required by BIOS)
; ------------------------------------------------------------
; Must be exactly 0xAA55 at bytes 511-512
; ============================================================
dw 0xAA55
