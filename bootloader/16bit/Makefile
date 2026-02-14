# ============================================================
# Bootloader Build Configuration
# ============================================================

# Assembler to use (Netwide Assembler)
ASM=nasm

# Source directory containing assembly files
SRC_DIR=src

# Build directory for output files
BUILD_DIR=build

# ============================================================
# Default target
# Builds the final floppy disk image
# ============================================================
all: $(BUILD_DIR)/main_floppy.img

# ============================================================
# Create floppy disk image (1440KB)
# 1. Copy the binary bootloader to the image file
# 2. Resize the file to standard floppy disk size (1440KB)
# ============================================================
$(BUILD_DIR)/main_floppy.img: $(BUILD_DIR)/main.bin
	# Copy bootloader binary to floppy image
	cp $(BUILD_DIR)/main.bin $(BUILD_DIR)/main_floppy.img
	# Resize to 1.44MB floppy disk size
	truncate -s 1440k $(BUILD_DIR)/main_floppy.img

# ============================================================
# Assemble the bootloader from source
# -f bin   : Output raw binary format (required for bootloaders)
# -o       : Output file path
# ============================================================
$(BUILD_DIR)/main.bin: $(SRC_DIR)/main.asm | $(BUILD_DIR)
	# Assemble the bootloader code
	$(ASM) $(SRC_DIR)/main.asm -f bin -o $(BUILD_DIR)/main.bin

# ============================================================
# Create build directory if it doesn't exist
# -p flag : Create parent directories as needed, no error if exists
# ============================================================
$(BUILD_DIR):
	# Create build directory structure
	mkdir -p $(BUILD_DIR)

# ============================================================
# Clean up generated files
# Remove entire build directory
# ============================================================
clean:
	# Delete all build artifacts
	rm -rf $(BUILD_DIR)

# ============================================================
# Phony targets (targets that don't represent actual files)
# Prevents conflicts with files named 'all' or 'clean'
# ============================================================
.PHONY: all clean