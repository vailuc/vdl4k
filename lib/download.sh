#!/bin/bash

# vdl4k Download Module
# This module handles video downloading and file processing

# Execute video download using yt-dlp
download_video() {
    local url="$1"
    local temp_dir="$2"
    local output_dir="${3:-$temp_dir}"

    if ! command_exists yt-dlp; then
        print_error "yt-dlp is not installed or not in PATH"
        return 1
    fi

    # Change to temp directory for download
    cd "$temp_dir" || {
        print_error "Failed to change to temp directory: $temp_dir"
        return 1
    }

    # Build yt-dlp command
    local yt_dlp_cmd=(
        yt-dlp
        --verbose
        --ignore-config
        --format "$FORMAT"
        --merge-output-format mkv
        --no-embed-thumbnail
        --embed-subs
        --sub-langs "$SUB_LANGS"
        --convert-subs "$CONVERT_SUBS"
        --restrict-filenames
        --no-warnings
    )

    # Add ffmpeg location if available
    if command_exists ffmpeg; then
        yt_dlp_cmd+=(--ffmpeg-location "$(which ffmpeg)")
    fi

    # Add output template
    yt_dlp_cmd+=(--output "./${OUTPUT_TEMPLATE}")

    # Handle playlists
    if [ "${DOWNLOAD_PLAYLIST:-false}" = true ]; then
        yt_dlp_cmd+=(--yes-playlist)
        print_info "Downloading entire playlist..."
    else
        yt_dlp_cmd+=(--no-playlist)
    fi

    # Add cookies if available
    if [ -f "${COOKIE_FILE:-}" ]; then
        yt_dlp_cmd+=(--cookies "$COOKIE_FILE")
    fi

    # Add URL
    yt_dlp_cmd+=("$url")

    # Show command if verbose
    if [ "${VERBOSE:-false}" = true ]; then
        print_info "Executing yt-dlp command:"
        printf '  %s\n' "${yt_dlp_cmd[@]}"
    fi

    # Execute download and capture output
    local output
    local exit_code

    if [ "${SHOW_YTDLP_OUTPUT:-false}" = true ]; then
        # Show output in real-time
        "${yt_dlp_cmd[@]}"
        exit_code=$?
    else
        # Capture output for processing
        output=$("${yt_dlp_cmd[@]}" 2>&1)
        exit_code=$?

        # Show output if requested or if there was an error
        if [ $exit_code -ne 0 ] || [ "${VERBOSE:-false}" = true ]; then
            echo "$output"
        fi
    fi

    if [ $exit_code -eq 0 ]; then
        if [ "${VERBOSE:-false}" = true ]; then
            print_success "Download completed successfully"
        fi
        echo "$output"
        return 0
    else
        print_error "Download failed with exit code: $exit_code"
        if [ -n "$output" ]; then
            print_error "yt-dlp output:"
            echo "$output"
        fi
        return $exit_code
    fi
}

# Process downloaded file
process_downloaded_file() {
    local temp_dir="$1"
    local download_dir="$2"

    if [ "${VERBOSE:-false}" = true ]; then
        print_info "Processing downloaded files in: $temp_dir"
        print_info "Directory contents:"
        ls -la "$temp_dir" 2>/dev/null | sed 's/^/  /' || true
    fi

    # Look for video files (exclude subtitle files)
    local video_file
    video_file=$(find "$temp_dir" -type f \( \
        -name "*.mp4" -o \
        -name "*.mkv" -o \
        -name "*.avi" -o \
        -name "*.mov" -o \
        -name "*.wmv" -o \
        -name "*.flv" -o \
        -name "*.webm" -o \
        -name "*.m4v" \
    \) | head -1)

    if [ -z "$video_file" ]; then
        print_error "No video file found in temp directory"
        print_error "Contents of $temp_dir:"
        ls -la "$temp_dir" 2>/dev/null || true

        # Check if yt-dlp saved the file elsewhere
        if command_exists yt-dlp; then
            local expected_output
            expected_output=$(yt-dlp --get-filename -o "%(title)s.%(ext)s" "$URL" 2>/dev/null)
            if [ -f "$expected_output" ]; then
                print_info "Found file in current directory: $expected_output"
                mv -v "$expected_output" "$temp_dir/"
                video_file="$temp_dir/$(basename "$expected_output")"
            fi
        fi

        if [ -z "$video_file" ]; then
            return 1
        fi
    fi

    if [ "${VERBOSE:-false}" = true ]; then
        print_info "Found video file: $video_file"
    fi

    # Validate the video file
    if ! validate_video_file "$video_file"; then
        print_error "Downloaded file is not a valid video file"
        return 1
    fi

    # Get file information
    local filename
    filename=$(basename "$video_file")
    local target_file="$download_dir/$filename"

    # Check if file already exists and compare quality
    local kept="new"
    if [ -f "$target_file" ]; then
        if [ "${VERBOSE:-false}" = true ]; then
            print_info "Existing file found, comparing quality..."
        fi

        if compare_and_keep_higher_res "$video_file" "$target_file"; then
            kept="new"
        else
            kept="existing"
        fi
    else
        # Move new file to download directory
        if mv "$video_file" "$target_file"; then
            if [ "${VERBOSE:-false}" = true ]; then
                print_success "Moved file to: $target_file"
            fi
        else
            print_error "Failed to move file to download directory"
            print_error "Source: $video_file"
            print_error "Target: $target_file"
            ls -la "$(dirname "$target_file")" 2>/dev/null || true
            return 1
        fi
    fi

    # Return the target file path
    echo "$target_file"
    return 0
}

# Get video metadata without downloading
get_video_metadata() {
    local url="$1"

    if ! command_exists yt-dlp; then
        print_error "yt-dlp is not installed or not in PATH"
        return 1
    fi

    # Get basic metadata as JSON
    local metadata
    metadata=$(yt-dlp --dump-json --no-download --ignore-config "$url" 2>/dev/null)

    if [ $? -eq 0 ] && [ -n "$metadata" ]; then
        echo "$metadata"
        return 0
    else
        print_warning "Could not get video metadata"
        return 1
    fi
}

# Check if video is available (not private/deleted)
check_video_availability() {
    local url="$1"

    if ! command_exists yt-dlp; then
        print_error "yt-dlp is not installed or not in PATH"
        return 1
    fi

    # Try to get basic info without downloading
    if yt_dlp_output=$(yt-dlp --no-download --ignore-config --print-json "$url" 2>/dev/null); then
        # Check if video is private or deleted
        if echo "$yt_dlp_output" | grep -q -i "private\|deleted\|not available"; then
            print_warning "Video may be private, deleted, or not available"
            return 1
        fi
        return 0
    else
        print_error "Video is not accessible"
        return 1
    fi
}

# Get available formats for a video
get_available_formats() {
    local url="$1"

    if ! command_exists yt-dlp; then
        print_error "yt-dlp is not installed or not in PATH"
        return 1
    fi

    print_info "Available formats:"
    yt-dlp --list-formats --no-download --ignore-config "$url" 2>/dev/null || {
        print_error "Could not get available formats"
        return 1
    }
    return 0
}

# Download thumbnail only
download_thumbnail() {
    local url="$1"
    local output_dir="$2"
    local temp_dir="$3"

    if ! command_exists yt-dlp; then
        print_error "yt-dlp is not installed or not in PATH"
        return 1
    fi

    local work_dir="${temp_dir:-$output_dir}"

    if yt-dlp --write-thumbnail --skip-download --ignore-config \
              --output "%(title)s.%(ext)s" \
              --output-na-placeholder "" \
              "$url" 2>/dev/null; then

        # Find the downloaded thumbnail
        local thumbnail_file
        thumbnail_file=$(find "$work_dir" -name "*.jpg" -o -name "*.png" -o -name "*.webp" | head -1)

        if [ -n "$thumbnail_file" ]; then
            # Move thumbnail to output directory
            mv "$thumbnail_file" "$output_dir/"
            print_success "Thumbnail downloaded: $(basename "$thumbnail_file")"
            return 0
        else
            print_warning "Thumbnail download completed but file not found"
            return 1
        fi
    else
        print_error "Failed to download thumbnail"
        return 1
    fi
}
