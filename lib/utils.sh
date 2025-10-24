#!/bin/bash

# vdl4k Core Utilities
# This module contains core utility functions for logging, output, and system operations

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD_MAGENTA='\033[1;35m'
BOLD_BLUE='\033[1;34m'
BOLD_WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Print functions
print_error() {
    echo -e "${RED}Error: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_info() {
    echo -e "${CYAN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

# Logging function with timestamps
log() {
    local level="$1"
    local message="$2"
    local log_file="${LOG_FILE:-$HOME/.cache/vdl4k/vdl4k.log}"

    # Create log directory if it doesn't exist
    mkdir -p "$(dirname "$log_file")" 2>/dev/null

    case "$level" in
        "INFO") echo -e "${CYAN}[$(date '+%H:%M:%S')] INFO: $message${NC}" ;;
        "ERROR") echo -e "${RED}[$(date '+%H:%M:%S')] ERROR: $message${NC}" >&2 ;;
        "WARNING") echo -e "${YELLOW}[$(date '+%H:%M:%S')] WARNING: $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}[$(date '+%H:%M:%S')] SUCCESS: $message${NC}" ;;
        *) echo -e "[$(date '+%H:%M:%S')] $level: $message" ;;
    esac

    # Log to file if VERBOSE is true or for errors
    if [ "${VERBOSE:-false}" = true ] || [ "$level" = "ERROR" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $level: $message" >> "$log_file" 2>/dev/null || true
    fi
}

# Ensure directory exists with proper permissions
ensure_dir_exists() {
    local dir="$1"
    local permissions="${2:-755}"

    if mkdir -p "$dir" 2>/dev/null; then
        chmod "$permissions" "$dir" 2>/dev/null || true
        return 0
    else
        print_error "Failed to create directory: $dir"
        return 1
    fi
}

# Check if command exists
command_exists() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1
}

# Get URL from clipboard using xsel
get_url_from_clipboard() {
    if command_exists xsel; then
        xsel -b -o 2>/dev/null | tr -d '\n\r\t' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/\?$//;s/\\$//;s/\\?/?/g;s/\\=/=/g'
    fi
}

# Clean up temp directory on exit
cleanup_temp() {
    local temp_dir="$1"
    if [ -n "$temp_dir" ] && [ -d "$temp_dir" ]; then
        rm -rf "$temp_dir" 2>/dev/null || true
        if [ "${VERBOSE:-false}" = true ]; then
            print_info "Cleaned up temp directory: $temp_dir"
        fi
    fi
}

# Setup temp directory with proper permissions
setup_temp_dir() {
    local temp_base="${TEMP_BASE_DIR:-$HOME/.cache/vdl4k-temp}"
    local temp_dir="$temp_base/$(date +%s)"

    # Clean up old temp directories (older than 1 day)
    find "$temp_base" -maxdepth 1 -type d -mtime +1 -exec rm -rf {} \; 2>/dev/null || true

    # Create base temp directory
    ensure_dir_exists "$temp_base" "700"

    # Create new temp directory
    if ! mkdir -p "$temp_dir" 2>/dev/null; then
        print_error "Failed to create temp directory: $temp_dir"
        return 1
    fi

    # Set permissions
    chmod 700 "$temp_dir" 2>/dev/null

    # Verify directory is writable
    if [ ! -w "$temp_dir" ]; then
        print_error "Temp directory is not writable: $temp_dir"
        return 1
    fi

    echo "$temp_dir"
    return 0
}

# Show progress message with optional spinner
show_progress() {
    local message="$1"
    local show_spinner="${2:-false}"

    if [ "$show_spinner" = true ]; then
        echo -n -e "${CYAN}$message...${NC}"
    else
        print_info "$message..."
    fi
}

# Complete progress message
complete_progress() {
    local message="$1"
    local success="${2:-true}"

    if [ -n "$message" ]; then
        if [ "$success" = true ]; then
            echo -e "\r${GREEN}$message${NC}"
        else
            echo -e "\r${RED}$message${NC}"
        fi
    fi
}
