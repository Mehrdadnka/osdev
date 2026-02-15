; ============================================================
; DESIGN NOTES
; ------------------------------------------------------------
; - We assume BIOS loads us at 0x0000:0x7C00
; - CS normalization intentionally skipped
; - Stack placed at 0x7C00 for minimal usage
; - Only BIOS teletype interrupt (int 0x10, ah=0x0E) used
; ============================================================

; ============================================================
; Bootloader - Stage 1 (Minimal & Safe)
; ============================================================
; Architecture : x86 (Real Mode)
; Load Address : 0x0000:0x7C00 (Physical 0x7C00)
; Size Limit   : 512 bytes
; Environment  : BIOS
; ============================================================

; ------------------------------------------------------------
; BIOS loads the first sector to physical address 0x7C00
; ORG tells the assembler where this code will live in memory
; ------------------------------------------------------------
org 0x7C00
bits 16

start:

    ; --------------------------------------------------------
    ; 1. Disable interrupts
    ; Prevent unexpected interrupts before stack is ready
    ; --------------------------------------------------------
    cli

    ; --------------------------------------------------------
    ; 2. Clear segment registers
    ; Set DS, ES, SS to 0x0000
    ; Ensures predictable memory addressing
    ; --------------------------------------------------------
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax

    ; --------------------------------------------------------
    ; 3. Initialize stack
    ; Stack grows downward from 0x7C00
    ; (safe temporary choice for Stage 1)
    ; --------------------------------------------------------
    mov sp, 0x7C00


; ------------------------------------------------------------
; Print a null-terminated string using BIOS teletype service
; ------------------------------------------------------------
; Usage:
;   mov si, msg
;   call print_string
;
; Requirements:
;   - DS must point to the segment where 'msg' is located
;   - Direction Flag must be clear for forward string reading
;
; Behavior:
;   - Reads bytes one-by-one from DS:SI
;   - Stops when it encounters 0x00 (null terminator)
;   - Prints each character using BIOS interrupt 0x10
;
; BIOS Service Used:
;   int 0x10, AH=0x0E  (Teletype Output)
;   - Prints AL to screen
;   - Advances cursor automatically
;   - Works in real mode without extra setup
; ------------------------------------------------------------

    mov si, msg        ; SI = offset of the string (DS:SI points to first char)
    call print_string  ; print until null terminator

    cli                ; disable interrupts (we are done executing)
    
; ------------------------------------------------------------
; print_string
; ------------------------------------------------------------
; Prints a null-terminated string pointed to by DS:SI
;
; Registers used:
;   SI - string pointer
;   AL - current character
;   AH - BIOS function selector
;
; Clobbers:
;   AL, AH, SI
;
; Notes:
;   - 'cld' ensures LODSB increments SI (forward direction)
;   - Safe for minimal Stage 1 debugging output
; ------------------------------------------------------------

print_string:
    cld                ; clear Direction Flag to ensure SI increments

.loop:
    lodsb              ; load byte from DS:SI into AL, then SI++
    or al, al          ; check if AL == 0 (null terminator)
    jz .done           ; if zero, end of string reached

    mov ah, 0x0E       ; BIOS teletype function
    int 0x10           ; print character in AL

    jmp .loop          ; continue with next character

.done:
    ret                ; return to caller


; ------------------------------------------------------------
; Data Section
; ------------------------------------------------------------
; Null-terminated string.
; The final 0 marks the end so the print loop knows when to stop.
; ------------------------------------------------------------

msg db 'Bootloader stage 1 loaded!', 0

    ; --------------------------------------------------------
    ; 4. Halt safely
    ; Use CLI + HLT loop to avoid undefined execution
    ; --------------------------------------------------------
.hang:
    hlt
    jmp .hang

; ============================================================
; Boot Sector Padding
; Fill remaining bytes up to 510 with zeros
; ============================================================
times 510-($-$$) db 0

; ============================================================
; Boot Signature (Required by BIOS)
; Must be exactly 0xAA55 at bytes 511-512
; ============================================================
dw 0xAA55
