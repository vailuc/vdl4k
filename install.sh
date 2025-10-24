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

# Setup local bin directory
LOCAL_BIN="$HOME/bin"
if [ ! -d "$LOCAL_BIN" ]; then
    echo
    echo "Creating local bin directory: $LOCAL_BIN"
    mkdir -p "$LOCAL_BIN"
    echo "✓ Created $LOCAL_BIN"
fi

# Add to PATH if not already there
if ! echo "$PATH" | grep -q "$LOCAL_BIN"; then
    echo
    echo "Adding $LOCAL_BIN to your PATH..."

    # Add to bashrc if it exists
    if [ -f ~/.bashrc ]; then
        # Remove any existing vdl4k PATH entries to avoid duplicates
        sed -i '/export PATH.*bin.*PATH/d' ~/.bashrc 2>/dev/null || true
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
        echo "✓ Added $LOCAL_BIN to ~/.bashrc"
    fi

    # Add to zshrc if it exists
    if [ -f ~/.zshrc ]; then
        # Remove any existing vdl4k PATH entries to avoid duplicates
        sed -i '/export PATH.*bin.*PATH/d' ~/.zshrc 2>/dev/null || true
        echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
        echo "✓ Added $LOCAL_BIN to ~/.zshrc"
    fi

    echo "✓ Added $LOCAL_BIN to shell configuration files"
    echo "⚠️  Please restart your terminal or run: source ~/.bashrc (or ~/.zshrc if using zsh)"
fi

# Install scripts to local bin
echo
echo "Installing vdl4k to $LOCAL_BIN..."

# Create a wrapper script for the modular version that works from anywhere
cat > "$LOCAL_BIN/vdl4k" << 'EOF'
#!/bin/bash

# vdl4k - YouTube Downloader with 4K support (Global Install)
# Version: 0.57
# This is a wrapper that ensures proper module loading

# Find the original project directory
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# If we're in ~/bin, look for the project in the original location
if [[ "$PROJECT_DIR" == *"/bin" ]] && [ -d "$PROJECT_DIR/../vdl4k" ]; then
    PROJECT_DIR="$PROJECT_DIR/../vdl4k"
elif [[ "$PROJECT_DIR" == *"/bin" ]] && [ -d "$HOME/vdl4k" ]; then
    PROJECT_DIR="$HOME/vdl4k"
elif [[ "$PROJECT_DIR" == *"/bin" ]] && [ -d "$(dirname "$SCRIPT_DIR")/vdl4k" ]; then
    PROJECT_DIR="$(dirname "$SCRIPT_DIR")/vdl4k"
fi

# Fallback: search for vdl4k project directory
if [[ "$PROJECT_DIR" == *"/bin" ]]; then
    # First try to find in common locations
    for search_dir in "$HOME/Documents" "$HOME/PycharmProjects" "$HOME/Projects" "$HOME/Desktop"; do
        if [ -d "$search_dir" ]; then
            # Look for vdl4k directory within this search directory
            vdl4k_path=$(find "$search_dir" -name "vdl4k" -type d 2>/dev/null | head -1)
            if [ -n "$vdl4k_path" ] && [ -f "$vdl4k_path/lib/config.sh" ]; then
                PROJECT_DIR="$vdl4k_path"
                break
            fi
        fi
    done
fi

# Ultimate fallback: use find to locate vdl4k project with lib directory
if [[ "$PROJECT_DIR" == *"/bin" ]] || [ ! -d "$PROJECT_DIR/lib" ]; then
    # Try to find the project by looking for the lib directory directly
    PROJECT_DIR=$(find /home -type d -name "vdl4k" 2>/dev/null | head -1)
    if [ -z "$PROJECT_DIR" ] || [ ! -f "$PROJECT_DIR/lib/config.sh" ]; then
        echo "Error: Could not locate vdl4k project directory" >&2
        echo "Please ensure the vdl4k project is available in your home directory" >&2
        echo "Searched locations: /home/*/Documents, /home/*/PycharmProjects, /home/*/" >&2
        exit 1
    fi
fi

# Load all modules
load_module() {
    local module="$1"
    local module_path="${PROJECT_DIR}/lib/${module}.sh"

    if [ ! -f "$module_path" ]; then
        echo "Error: Module not found: $module_path" >&2
        exit 1
    fi

    # shellcheck source=/dev/null
    source "$module_path" || {
        echo "Error: Failed to load module: $module" >&2
        exit 1
    }
}

# Load all required modules
load_module "config"
load_module "utils"
load_module "validators"
load_module "video_utils"
load_module "archive"
load_module "download"

# Script metadata
readonly SCRIPT_NAME="vdl4k"
readonly SCRIPT_VERSION="0.57"

# Trap for cleanup on exit
cleanup() {
    if [ -n "${TEMP_DIR:-}" ] && [ -d "$TEMP_DIR" ]; then
        cleanup_temp "$TEMP_DIR"
    fi
}
trap cleanup EXIT INT TERM

# Show help message
show_help() {
    # Load basic config for display
    set_defaults
    load_config "${PROJECT_DIR}/config/default.conf"

    echo -e "${GREEN}Usage: $0 [OPTIONS] [URL]${NC}"
    echo "Download videos with yt-dlp using modular architecture"
    echo
    echo "Options:"
    echo "  -d, --dir DIR      Set download directory (default: ${DOWNLOAD_DIR:-$HOME/Downloads/Videos Archive})"
    echo "  -p, --playlist     Download playlist instead of single video"
    echo "  -f, --force        Force re-download even if video is in archive"
    echo "  -t, --no-tracking  Disable download tracking (no archive updates)"
    echo "  -v, --verbose      Enable verbose output with timestamps"
    echo "  -s, --show-yt-dlp  Show yt-dlp output during download"
    echo "  -y, --yes          Automatically answer yes to all prompts"
    echo "  -c, --config       Show current configuration"
    echo "  -h, --help         Show this help message and exit"
    echo
    echo "Configuration:"
    echo "  Default config: ${PROJECT_DIR}/config/default.conf"
    echo "  User config: ${CONFIG_DIR:-$HOME/.config/vdl4k}/vdl4k.conf (created on first run)"
    echo "  Override config: ${CONFIG_DIR:-$HOME/.config/vdl4k}/config.sh"
    exit 0
}

# Show configuration
show_config() {
    # Load basic config for display
    set_defaults
    load_config "${PROJECT_DIR}/config/default.conf"

    print_info "Current Configuration:"
    echo "  Download Directory: ${DOWNLOAD_DIR:-$HOME/Downloads/Videos Archive}"
    echo "  Config Directory: ${CONFIG_DIR:-$HOME/.config/vdl4k}"
    echo "  Cache Directory: ${CACHE_DIR:-$HOME/.cache/vdl4k}"
    echo "  Log File: ${LOG_FILE:-$HOME/.cache/vdl4k/vdl4k.log}"
    echo "  Archive File: ${ARCHIVE_FILE:-$HOME/.cache/vdl4k/downloaded.txt}"
    echo "  Cookie File: ${COOKIE_FILE:-$HOME/.config/vdl4k/cookies.txt}"
    echo "  Format: ${FORMAT:-'bestvideo[height<=2160]+bestaudio/best[height=2160]/bestvideo[height<=1080]+bestaudio/best[height=1080]/best'}"
    echo "  Output Template: ${OUTPUT_TEMPLATE:-'%(title)s.%(ext)s'}"
    echo "  Subtitle Languages: ${SUB_LANGS:-'en,en.*'}"
    echo "  Convert Subs: ${CONVERT_SUBS:-'srt'}"
    echo "  Force Download: ${FORCE_DOWNLOAD:-false}"
    echo "  Disable Archive: ${DISABLE_ARCHIVE:-false}"
    echo "  Download Playlist: ${DOWNLOAD_PLAYLIST:-false}"
    echo "  Auto Yes: ${AUTO_YES:-false}"
    echo "  Verbose: ${VERBOSE:-false}"
    echo "  Show yt-dlp Output: ${SHOW_YTDLP_OUTPUT:-false}"
    exit 0
}

# Main function
main() {
    # Parse command line arguments
    local force_download=false
    local disable_archive=false
    local download_playlist=false
    local auto_yes=false
    local verbose=false
    local show_ytdlp_output=false
    local url=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--dir) DOWNLOAD_DIR="$2"; shift 2 ;;
            -p|--playlist) download_playlist=true; shift ;;
            -f|--force) force_download=true; shift ;;
            -t|--no-tracking) disable_archive=true; shift ;;
            -v|--verbose) verbose=true; shift ;;
            -s|--show-yt-dlp) show_ytdlp_output=true; shift ;;
            -y|--yes) auto_yes=true; shift ;;
            -c|--config) show_config ;;
            -h|--help) show_help ;;
            --) shift; break ;;
            -*) print_error "Unknown option: $1"; show_help ;;
            *) url="$1"; shift ;;
        esac
    done

    # Export variables for modules to use
    export FORCE_DOWNLOAD="$force_download"
    export DISABLE_ARCHIVE="$disable_archive"
    export DOWNLOAD_PLAYLIST="$download_playlist"
    export AUTO_YES="$auto_yes"
    export VERBOSE="$verbose"
    export SHOW_YTDLP_OUTPUT="$show_ytdlp_output"

    # Setup user configuration
    setup_user_config

    # Validate configuration
    if ! validate_config; then
        print_error "Configuration validation failed"
        exit 1
    fi

    # Get URL from arguments or interactive input
    if [ -z "$url" ] && [ -t 0 ]; then
        local clipboard_url
        clipboard_url=$(get_url_from_clipboard)

        if [ -n "$clipboard_url" ]; then
            echo "Clipboard content: $clipboard_url"
            if validate_url "$clipboard_url"; then
                url="$clipboard_url"
                if [ "$verbose" = true ]; then
                    print_info "Using URL from clipboard"
                fi
            else
                read -p "Enter URL: " url
            fi
        else
            read -p "Enter URL: " url
        fi
    fi

    # Validate URL
    if ! validate_url "$url"; then
        exit 1
    fi

    # Extract video ID
    local video_id
    video_id=$(extract_video_id "$url")
    if [ -z "$video_id" ]; then
        video_id=$(echo "$url" | md5sum | cut -d' ' -f1)
        print_warning "Could not extract video ID, using hash: $video_id"
    fi

    # Check if video is already in archive
    local was_in_archive=false
    if [ "$disable_archive" = false ] && is_video_in_archive "$video_id"; then
        was_in_archive=true
        print_warning "This video is already in your download archive"

        if [ "$auto_yes" = false ] && [ -t 0 ]; then
            read -p "Re-download? [y/N] " -n 1 -r
            echo
            [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0
        fi
    fi

    # Setup temp directory
    TEMP_DIR=$(setup_temp_dir)
    if [ $? -ne 0 ]; then
        print_error "Failed to setup temp directory"
        exit 1
    fi

    if [ "$verbose" = true ]; then
        print_info "Using temp directory: $TEMP_DIR"
    fi

    # Check video availability before download
    if ! check_video_availability "$url"; then
        print_warning "Video may not be available or accessible"
        if [ "$auto_yes" = false ] && [ -t 0 ]; then
            read -p "Continue anyway? [y/N] " -n 1 -r
            echo
            [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0
        fi
    fi

    # Execute download
    show_progress "Starting download"
    local download_output
    download_output=$(download_video "$url" "$TEMP_DIR")
    local download_exit_code=$?

    if [ $download_exit_code -ne 0 ]; then
        print_error "Download failed with exit code: $download_exit_code"
        complete_progress "Download failed" false
        exit $download_exit_code
    fi

    complete_progress "Download completed" true

    # Process downloaded file
    show_progress "Processing downloaded file"
    local target_file
    target_file=$(process_downloaded_file "$TEMP_DIR" "$DOWNLOAD_DIR")

    if [ $? -ne 0 ] || [ -z "$target_file" ]; then
        print_error "Failed to process downloaded file"
        exit 1
    fi

    complete_progress "File processed" true

    # Get video title for summary
    local video_title
    video_title=$(get_video_title "$url" "$TEMP_DIR")
    if [ $? -ne 0 ]; then
        video_title="Unknown Video"
    fi

    # Get final file information
    local final_size
    local final_resolution
    final_size=$(get_file_size "$target_file")
    final_resolution=$(get_video_resolution "$target_file")

    if [[ "$final_resolution" == "0x0" ]]; then
        print_warning "Could not determine video resolution"
        final_resolution="Unknown"
    fi

    # Add to archive if not disabled
    if [ "$disable_archive" = false ]; then
        add_to_archive "$video_id"
    fi

    # Generate summary
    show_download_summary "$url" "$video_title" "$target_file" "$final_size" "$final_resolution" "$was_in_archive"

    print_success "Download completed successfully"
    exit 0
}

# Show download summary
show_download_summary() {
    local url="$1"
    local title="$2"
    local file_path="$3"
    local file_size="$4"
    local resolution="$5"
    local was_in_archive="$6"

    echo
    echo -e "${CYAN}========================================${NC}"
    print_info "=== DOWNLOAD SUMMARY ==="
    echo -e "${BOLD_MAGENTA}• Source${NC}"
    print_info "  - URL: $url"
    print_info "  - Title: $title"
    print_info "  - Download Date: $(date '+%Y-%m-%d %H:%M:%S')"
    print_info "  - Previously Downloaded: $(if [ "$was_in_archive" = true ]; then echo "Yes"; else echo "No"; fi)"
    echo
    echo -e "${BOLD_BLUE}• File Information${NC}"
    print_info "  Resolution: $resolution"
    print_info "  File Size: $file_size"
    print_info "  Subtitles: Embedded ($SUB_LANGS)"
    print_info "  Location: $file_path"
    echo -e "${CYAN}========================================${NC}"

    # Log to file
    {
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Downloaded '$title' from $url"
        echo "  Final: $file_size, $resolution at $file_path"
        echo "  Archive: $(if [ "$was_in_archive" = true ]; then echo "Previously downloaded"; else echo "New"; fi)"
        echo ""
    } >> "$LOG_FILE" 2>/dev/null || true
}

# Run main function with all arguments
main "$@"
EOF

# Make the wrapper executable
chmod +x "$LOCAL_BIN/vdl4k"
echo "✓ Installed modular version: vdl4k (with project path detection)"

# Install portable version (this one works as-is)
cp vdl4k-portable "$LOCAL_BIN/vdl4k-portable"
chmod +x "$LOCAL_BIN/vdl4k-portable"
echo "✓ Installed portable version: vdl4k-portable"

echo
echo "🎉 Installation complete!"
echo
echo "You can now use vdl4k from anywhere:"
echo "  vdl4k --help          # Show help"
echo "  vdl4k --config        # Show configuration"
echo "  vdl4k <URL>           # Download video"
echo
echo "Or use the portable version:"
echo "  vdl4k-portable --help"
echo "  vdl4k-portable <URL>"

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

if ! echo "$PATH" | grep -q "$LOCAL_BIN"; then
    echo
    echo "⚠️  Please restart your terminal or run: source ~/.bashrc"
    echo "   Then you can use 'vdl4k' from anywhere!"
fi

echo
echo "Configuration files will be created in ~/.config/vdl4k/ on first run"
echo
echo "=== Installation Complete ==="
