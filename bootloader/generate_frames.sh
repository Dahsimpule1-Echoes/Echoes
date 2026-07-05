#!/bin/bash
# Echoes Boot Animation - Frame Generator
# Generates boot animation frames programmatically

set -e

echo "Echoes Boot Animation - Frame Generator"
echo "========================================"
echo ""

# Configuration
WIDTH=1080
HEIGHT=2340
FPS=60
DURATION_PART0=60  # 1 second at 60 FPS
DURATION_PART1=120 # 2 seconds at 60 FPS

# Output directories
PART0_DIR="part0"
PART1_DIR="part1"

echo "Creating directories..."
mkdir -p "$PART0_DIR"
mkdir -p "$PART1_DIR"

echo "Generating boot animation frames..."
echo "  Resolution: ${WIDTH}x${HEIGHT}"
echo "  FPS: $FPS"
echo "  Part0 frames: $DURATION_PART0"
echo "  Part1 frames: $DURATION_PART1"
echo ""

# Generate frames using Python
python3 << 'PYTHON_EOF'
import struct
import zlib
import os

def create_black_png(filename, width=1080, height=2340):
    """Create a simple black PNG file"""
    
    # PNG signature
    png_sig = b'\x89PNG\r\n\x1a\n'
    
    # IHDR chunk (image header)
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    ihdr_crc = zlib.crc32(b'IHDR' + ihdr_data) & 0xffffffff
    ihdr_chunk = struct.pack('>I', len(ihdr_data)) + b'IHDR' + ihdr_data + struct.pack('>I', ihdr_crc)
    
    # IDAT chunk (image data - black)
    raw_data = b''
    for y in range(height):
        raw_data += b'\x00'  # Filter type
        raw_data += b'\x00\x00\x00' * width  # Black pixels (RGB)
    
    compressed = zlib.compress(raw_data, 9)
    idat_crc = zlib.crc32(b'IDAT' + compressed) & 0xffffffff
    idat_chunk = struct.pack('>I', len(compressed)) + b'IDAT' + compressed + struct.pack('>I', idat_crc)
    
    # IEND chunk (image end)
    iend_crc = zlib.crc32(b'IEND') & 0xffffffff
    iend_chunk = struct.pack('>I', 0) + b'IEND' + struct.pack('>I', iend_crc)
    
    # Write PNG file
    with open(filename, 'wb') as f:
        f.write(png_sig + ihdr_chunk + idat_chunk + iend_chunk)

print("Generating Part 0 (Startup - 60 frames)...")
for i in range(60):
    filename = f'part0/{i:05d}.png'
    create_black_png(filename)
    if (i + 1) % 10 == 0:
        print(f"  {i + 1}/60 frames created")

print("✓ Part 0 complete")
print("")

print("Generating Part 1 (Ready - 120 frames)...")
for i in range(120):
    filename = f'part1/{i:05d}.png'
    create_black_png(filename)
    if (i + 1) % 20 == 0:
        print(f"  {i + 1}/120 frames created")

print("✓ Part 1 complete")

PYTHON_EOF

echo ""
echo "========================================"
echo "Frame generation complete!"
echo "========================================"
echo ""
echo "Frames created:"
echo "  Part 0: $PART0_DIR/ ($(ls $PART0_DIR | wc -l) files)"
echo "  Part 1: $PART1_DIR/ ($(ls $PART1_DIR | wc -l) files)"
echo ""
echo "Next step: Create bootanimation.zip"
echo "  bash build.sh"
