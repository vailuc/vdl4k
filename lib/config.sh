#!/bin/bash

# vdl4k Configuration Loader
# This module handles loading and managing configuration files

# Default configuration values
set_defaults() {
    # Directory settings
    DOWNLOAD_DIR="${DOWNLOAD_DIR:-${HOME}/Downloads/Videos Archive}"
    CONFIG_DIR="${CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/vdl4k}"
    CACHE_DIR="${CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/vdl4k}"
    TEMP_BASE_DIR="${TEMP_BASE_DIR:-${CACHE_DIR}/temp}"

    # File paths
    LOG_FILE="${LOG_FILE:-${CACHE_DIR}/vdl4k.log}"
    ARCHIVE_FILE="${ARCHIVE_FILE:-${CACHE_DIR}/downloaded.txt}"
    COOKIE_FILE="${COOKIE_FILE:-${CONFIG_DIR}/cookies.txt}"

    # Download settings
    FORMAT="${FORMAT:-'bestvideo[height<=2160]+bestaudio/best[height=2160]/bestvideo[height<=1080]+bestaudio/best[height=1080]/best'}"
    OUTPUT_TEMPLATE="${OUTPUT_TEMPLATE:-'%(title)s.%(ext)s'}"
    SUB_LANGS="${SUB_LANGS:-'en,en.*'}"
    CONVERT_SUBS="${CONVERT_SUBS:-'srt'}"

    # Default flags
    FORCE_DOWNLOAD="${FORCE_DOWNLOAD:-false}"
    DISABLE_ARCHIVE="${DISABLE_ARCHIVE:-false}"
    DOWNLOAD_PLAYLIST="${DOWNLOAD_PLAYLIST:-false}"
    AUTO_YES="${AUTO_YES:-false}"
    VERBOSE="${VERBOSE:-false}"
    SHOW_YTDLP_OUTPUT="${SHOW_YTDLP_OUTPUT:-false}"
}

# Load configuration from a file
load_config() {
    local config_file="$1"

    if [ -f "$config_file" ]; then
        if [ "${VERBOSE:-false}" = true ]; then
            print_info "Loading configuration from: $config_file"
        fi

        # Source the configuration file
        source "$config_file" 2>/dev/null || {
            print_warning "Failed to load configuration from: $config_file"
            return 1
        }
        return 0
    else
        if [ "${VERBOSE:-false}" = true ]; then
            print_info "Configuration file not found: $config_file"
        fi
        return 1
    fi
}

# Load all configuration files in order of precedence
load_all_configs() {
    local script_dir
    script_dir="$(dirname "$(readlink -f "$0")")"

    # 1. Set defaults first
    set_defaults

    # 2. Load default config from script directory
    load_config "${script_dir}/../config/default.conf"

    # 3. Load system-wide config if it exists
    load_config "/etc/vdl4k.conf"

    # 4. Load user config from XDG directory
    load_config "${CONFIG_DIR}/vdl4k.conf"

    # 5. Load user override config (highest priority)
    load_config "${CONFIG_DIR}/config.sh"

    # 6. Apply command line overrides (these should be set by the caller)
    # Command line arguments will override any config file settings
}

# Create user configuration directory and copy default config if needed
setup_user_config() {
    # Create config directory
    ensure_dir_exists "$CONFIG_DIR" "750"

    # Create cache directory
    ensure_dir_exists "$CACHE_DIR" "750"

    # Create temp directory
    ensure_dir_exists "$TEMP_BASE_DIR" "700"

    # Copy default config if user config doesn't exist
    if [ ! -f "${CONFIG_DIR}/vdl4k.conf" ]; then
        if [ -f "${script_dir}/../config/default.conf" ]; then
            cp "${script_dir}/../config/default.conf" "${CONFIG_DIR}/vdl4k.conf"
            print_info "Created user configuration file: ${CONFIG_DIR}/vdl4k.conf"
        fi
    fi

    # Create log file if it doesn't exist
    if [ ! -f "$LOG_FILE" ]; then
        touch "$LOG_FILE" 2>/dev/null || print_warning "Could not create log file: $LOG_FILE"
    fi

    # Create archive file if it doesn't exist
    if [ ! -f "$ARCHIVE_FILE" ]; then
        touch "$ARCHIVE_FILE" 2>/dev/null || print_warning "Could not create archive file: $ARCHIVE_FILE"
    fi
}

# Display current configuration
show_config() {
    print_info "Current Configuration:"
    echo "  Download Directory: $DOWNLOAD_DIR"
    echo "  Config Directory: $CONFIG_DIR"
    echo "  Cache Directory: $CACHE_DIR"
    echo "  Log File: $LOG_FILE"
    echo "  Archive File: $ARCHIVE_FILE"
    echo "  Cookie File: $COOKIE_FILE"
    echo "  Format: $FORMAT"
    echo "  Output Template: $OUTPUT_TEMPLATE"
    echo "  Subtitle Languages: $SUB_LANGS"
    echo "  Convert Subs: $CONVERT_SUBS"
    echo "  Force Download: $FORCE_DOWNLOAD"
    echo "  Disable Archive: $DISABLE_ARCHIVE"
    echo "  Download Playlist: $DOWNLOAD_PLAYLIST"
    echo "  Auto Yes: $AUTO_YES"
    echo "  Verbose: $VERBOSE"
    echo "  Show yt-dlp Output: $SHOW_YTDLP_OUTPUT"
}

# Validate configuration
validate_config() {
    local errors=0

    # Check if required directories exist or can be created
    if ! ensure_dir_exists "$DOWNLOAD_DIR" "755" 2>/dev/null; then
        print_error "Cannot create download directory: $DOWNLOAD_DIR"
        ((errors++))
    fi

    # Check if required commands are available
    if ! command_exists yt-dlp; then
        print_error "yt-dlp is not installed or not in PATH"
        ((errors++))
    fi

    if ! command_exists ffmpeg; then
        print_warning "ffmpeg is not installed or not in PATH (some features may not work)"
    fi

    if ! command_exists ffprobe; then
        print_warning "ffprobe is not installed or not in PATH (video analysis may not work)"
    fi

    if [ $errors -gt 0 ]; then
        print_error "Configuration validation failed with $errors error(s)"
        return 1
    else
        print_success "Configuration validation passed"
        return 0
    fi
}
