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
