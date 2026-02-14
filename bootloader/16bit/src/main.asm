; ============================================================
; Bootloader - Stage 1
; ============================================================

; BIOS loads bootloader at physical address 0x7C00
org 0x7C00

; Use 16-bit real mode (BIOS environment)
bits 16

; ============================================================
; Main entry point
; ============================================================
main:
    ; Halt the CPU (stop execution)
    ; This is temporary - we'll add more code later
    hlt

; ============================================================
; Infinite halt loop
; Prevents CPU from executing garbage after our code
; ============================================================
.halt:
    jmp .halt

; ============================================================
; Boot sector padding and signature
; ============================================================

; Fill the rest of the 512-byte boot sector with zeros
; 510 - ($-$$) calculates remaining bytes
; $  : current address
; $$ : start address of current section
times 510-($-$$) db 0

; Boot signature (0xAA55)
; BIOS checks this to verify it's a valid boot sector
dw 0AA55h