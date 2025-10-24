#!/bin/bash

# vdl4k Installation Script
# This script helps set up vdl4k for first-time users

echo "=== vdl4k Installation Helper ==="
echo

# Check if we're in the right directory
if [ ! -f "bin/vdl4k" ] || [ ! -f "vdl4k-portable" ]; then
    echo "Error: Please run this script from the vdl4k project directory"
    exit 1
fi

echo "Setting up vdl4k..."

# Make scripts executable
chmod +x bin/vdl4k
chmod +x vdl4k-portable

echo "✓ Made scripts executable"

# Check dependencies
echo
echo "Checking dependencies..."

if command -v yt-dlp >/dev/null 2>&1; then
    echo "✓ yt-dlp found: $(yt-dlp --version)"
else
    echo "✗ yt-dlp not found. Install with: pip install yt-dlp"
fi

if command -v ffmpeg >/dev/null 2>&1; then
    echo "✓ ffmpeg found: $(ffmpeg -version | head -1 | cut -d' ' -f3)"
else
    echo "✗ ffmpeg not found. Install with: sudo apt install ffmpeg (Ubuntu/Debian)"
fi

if command -v ffprobe >/dev/null 2>&1; then
    echo "✓ ffprobe found"
else
    echo "! ffprobe not found separately (usually included with ffmpeg)"
fi

echo
echo "Installation options:"
echo "1. Modular version (recommended for development): ./bin/vdl4k"
echo "2. Portable version (recommended for users): ./vdl4k-portable"
echo
echo "Try: ./bin/vdl4k --help"
echo "Try: ./vdl4k-portable --help"
echo
echo "First run will create configuration files in ~/.config/vdl4k/"
echo
echo "=== Installation Complete ==="
