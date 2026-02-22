16-bit Bootloader — Stage 1

This folder contains Stage 1 of a custom OS bootloader.
It runs in BIOS real mode (16-bit) and provides minimal functionality: printing a message to the screen and halting safely.

---

Features

Load Address: 0x7C00 (BIOS loads the first sector here)

Architecture: x86 16-bit real mode

Stack: located at 0x7BE0, grows downward

Interrupts: disabled before stack setup (cli)

Message Output: prints a null-terminated string using BIOS INT 0x10 (AH=0x0E)

Safe Halt: uses CLI + HLT loop

Size: 512 bytes (padded with zeros and ends with boot signature 0xAA55)

BIOS Services Used: teletype output only

---

Usage

1. Build the bootloader and floppy disk image

Make sure you have the Makefile in this folder, then run:

make

This will:

Assemble src/main.asm into build/main.bin

Create a 1.44MB floppy disk image build/main_floppy.img containing the bootloader


2. Run the bootloader in a virtual machine (e.g., QEMU)

qemu-system-x86_64 -fda build/main_floppy.img

Note: if you prefer using -drive:

qemu-system-x86_64 -drive file=build/main_floppy.img,format=raw,if=floppy

3. Expected output

Bootloader stage 1 loaded!

---

Troubleshooting

"Boot failed: could not read the boot disk"
If you see this message followed by your bootloader output:

Booting from Floppy...
Boot failed: could not read the boot disk
Booting from Hard Disk...
Bootloader stage 1 loaded!
This is normal and NOT an error in our bootloader.

The message comes from the BIOS/SeaBIOS during the boot process:

BIOS first attempts to boot from a floppy disk (which doesn't exist in most QEMU setups)

When it fails to read from the floppy, it shows "Boot failed: could not read the boot disk"

BIOS then moves to the next boot device (hard disk) and successfully loads our bootloader

To suppress this message and boot directly from the hard disk image:

qemu-system-x86_64 -drive format=raw,file=build/main.bin -boot order=c
The -boot order=c option tells QEMU to only attempt booting from the first hard disk, skipping the floppy check entirely.

---

Code Overview

1. start
Disable interrupts (cli)

Initialize segments (DS = ES = SS = 0x0000)

Set up the stack (SP = 0x7BE0)

2. print_string
Reads bytes from DS:SI until a null terminator

Prints each character using BIOS teletype (INT 0x10, AH=0x0E)

3. hang_loop
Halts execution safely with a CLI + HLT loop

4. Padding
Zero-fill remaining bytes up to 510

Add boot signature 0xAA55
