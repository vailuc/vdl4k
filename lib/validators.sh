#!/bin/bash

# vdl4k Validators
# This module contains functions for validating URLs, inputs, and extracting metadata

# Validate URL format (general HTTP/HTTPS)
validate_url() {
    local url="$1"
    if [[ "$url" =~ ^https?://[^[:space:]]+$ ]]; then
        return 0
    fi
    print_error "Invalid URL format: $url"
    return 1
}

# Extract video ID from URL using grep for reliability
extract_video_id() {
    local url="$1"

    # Extract video ID using grep
    local video_id
    video_id=$(echo "$url" | grep -oP '(?:v=|youtu\.be/|/embed/|/v/|/e/|/watch\?v=)([^&?/]+)' | head -1)

    # If not found, try to get the last part
    if [ -z "$video_id" ]; then
        local last_part
        last_part=$(echo "$url" | grep -oP '[^/]+$')
        last_part=$(echo "$last_part" | grep -oP '^[^?&]+')
        if [[ "$last_part" =~ ^[a-zA-Z0-9_-]{11}$ ]]; then
            echo "$last_part"
            return 0
        fi
    fi

    if [ -n "$video_id" ]; then
        echo "$video_id"
        return 0
    fi

    echo ""
    return 1
}

# Get video title using yt-dlp (quiet mode)
get_video_title() {
    local url="$1"
    local temp_dir="$2"

    if ! command_exists yt-dlp; then
        print_error "yt-dlp is not installed or not in PATH"
        return 1
    fi

    # Use temp directory if provided, otherwise use current directory
    local output_dir="${temp_dir:-.}"

    # Get title without downloading
    local title
    title=$(cd "$output_dir" && yt-dlp --get-title --no-download --ignore-config "$url" 2>/dev/null)

    if [ $? -eq 0 ] && [ -n "$title" ]; then
        echo "$title"
        return 0
    else
        print_warning "Could not get video title, using fallback"
        # Fallback: extract from URL or use generic name
        local video_id
        video_id=$(extract_video_id "$url")
        if [ -n "$video_id" ]; then
            echo "Video $video_id"
        else
            echo "Unknown Video"
        fi
        return 1
    fi
}

# Validate video file
validate_video_file() {
    local file="$1"

    if [ ! -f "$file" ]; then
        print_error "File does not exist: $file"
        return 1
    fi

    # Check if it's a video file by trying ffprobe
    if command_exists ffprobe; then
        if ffprobe -v error -select_streams v:0 -show_entries stream=codec_type -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null | grep -q video; then
            return 0
        else
            print_error "File is not a valid video file: $file"
            return 1
        fi
    else
        # Fallback: check file extension
        case "$file" in
            *.mp4|*.mkv|*.avi|*.mov|*.wmv|*.flv|*.webm|*.m4v)
                return 0
                ;;
            *)
                print_error "File type not recognized (no ffprobe available): $file"
                return 1
                ;;
        esac
    fi
}

# Sanitize filename for safe storage
sanitize_filename() {
    local filename="$1"

    # Replace problematic characters
    echo "$filename" | sed 's/[<>:"/\\|?*]/_/g' | sed 's/[[:space:]]\+/_/g' | sed 's/__\+/_/g' | sed 's/^_\+//;s/_\+$//'
}

# Check if URL is a playlist
is_playlist_url() {
    local url="$1"

    # Check for playlist indicators in URL
    if echo "$url" | grep -q -E '(playlist|list=)'; then
        return 0
    fi

    # Use yt-dlp to check if URL contains multiple videos
    if command_exists yt-dlp; then
        local count
        count=$(yt-dlp --flat-playlist --dump-json "$url" 2>/dev/null | wc -l)
        [ "$count" -gt 1 ] 2>/dev/null && return 0
    fi

    return 1
}

# Get video duration
get_video_duration() {
    local file="$1"

    if ! command_exists ffprobe; then
        echo "Unknown"
        return 1
    fi

    local duration
    duration=$(ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null)

    if [ -n "$duration" ] && [ "$duration" != "N/A" ]; then
        # Convert to human readable format
        local hours=$(( $(echo "$duration" | cut -d'.' -f1) / 3600 ))
        local minutes=$(( ($(echo "$duration" | cut -d'.' -f1) % 3600) / 60 ))
        local seconds=$(( $(echo "$duration" | cut -d'.' -f1) % 60 ))

        if [ $hours -gt 0 ]; then
            printf "%02d:%02d:%02d\n" $hours $minutes $seconds
        else
            printf "%02d:%02d\n" $minutes $seconds
        fi
        return 0
    else
        echo "Unknown"
        return 1
    fi
}
