#!/bin/bash

# vdl4k Video Utilities
# This module contains functions for video processing, resolution comparison, and file management

# Get video resolution from file using ffprobe
get_video_resolution() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "0x0"
        return 1
    fi

    # Try to get both width and height
    local resolution
    resolution=$(ffprobe -v error -select_streams v:0 \
              -show_entries stream=width,height \
              -of csv=s=x:p=0 "$file" 2>/dev/null)

    # Clean the resolution string
    resolution=$(echo "$resolution" | tr -d ' ')

    if [ -z "$resolution" ] || ! [[ "$resolution" =~ ^[0-9]+x[0-9]+$ ]]; then
        # Fallback to just height if widthxheight format fails
        resolution="0x$(ffprobe -v error -select_streams v:0 \
                   -show_entries stream=height \
                   -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null | tr -d ' ' || echo "0")"
    fi

    echo "$resolution"
}

# Calculate total pixels from resolution (WxH)
calculate_pixels() {
    local resolution="$1"
    local width=$(echo "$resolution" | cut -d'x' -f1)
    local height=$(echo "$resolution" | cut -d'x' -f2)

    # Validate that width and height are numbers
    if ! [[ "$width" =~ ^[0-9]+$ ]] || ! [[ "$height" =~ ^[0-9]+$ ]]; then
        echo "0"
        return 1
    fi

    echo $((width * height))
}

# Compare and keep higher resolution file
compare_and_keep_higher_res() {
    local file1="$1"
    local file2="$2"

    # Get resolutions
    local res1 res2
    res1=$(get_video_resolution "$file1")
    res2=$(get_video_resolution "$file2")

    # Calculate pixels for comparison
    local pixels1 pixels2
    pixels1=$(calculate_pixels "$res1")
    pixels2=$(calculate_pixels "$res2")

    print_info "Comparing resolutions:"
    print_info "  $file1: $res1 (${pixels1} pixels)"
    print_info "  $file2: $res2 (${pixels2} pixels)"

    if [ $pixels1 -gt $pixels2 ]; then
        print_success "New file has higher resolution. Replacing..."
        mv -f "$file1" "$file2"
        return 0
    elif [ $pixels1 -eq $pixels2 ]; then
        print_warning "Resolutions are equal. Keeping existing."
        rm -f "$file1"
        return 1
    else
        print_warning "Existing file has higher resolution. Keeping existing."
        rm -f "$file1"
        return 1
    fi
}

# Get video codec information
get_video_codec() {
    local file="$1"

    if ! command_exists ffprobe; then
        echo "Unknown"
        return 1
    fi

    ffprobe -v error -select_streams v:0 \
            -show_entries stream=codec_name \
            -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null
}

# Get audio codec information
get_audio_codec() {
    local file="$1"

    if ! command_exists ffprobe; then
        echo "Unknown"
        return 1
    fi

    ffprobe -v error -select_streams a:0 \
            -show_entries stream=codec_name \
            -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null
}

# Get video bitrate
get_video_bitrate() {
    local file="$1"

    if ! command_exists ffprobe; then
        echo "Unknown"
        return 1
    fi

    local bitrate
    bitrate=$(ffprobe -v error \
              -show_entries format=bit_rate \
              -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null)

    if [ -n "$bitrate" ] && [ "$bitrate" != "N/A" ]; then
        # Convert to Mbps for readability
        local mbps=$((bitrate / 1000000))
        echo "${mbps} Mbps"
        return 0
    else
        echo "Unknown"
        return 1
    fi
}

# Check if file has embedded subtitles
has_embedded_subtitles() {
    local file="$1"

    if ! command_exists ffprobe; then
        return 1
    fi

    # Check for subtitle streams
    ffprobe -v error -select_streams s \
            -show_entries stream=index \
            -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null | grep -q "^[0-9]"
}

# Get file size in human readable format
get_file_size() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "0 B"
        return 1
    fi

    du -h "$file" 2>/dev/null | cut -f1
}

# Check if video file is corrupted
is_video_corrupted() {
    local file="$1"

    if ! command_exists ffprobe; then
        # Fallback: check if file size is reasonable (>1MB)
        local size
        size=$(du -b "$file" 2>/dev/null | cut -f1)
        [ "$size" -lt 1048576 ] 2>/dev/null && return 0
        return 1
    fi

    # Try to read video stream info
    if ffprobe -v error -select_streams v:0 \
               -show_entries stream=duration \
               -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null | grep -q "^[0-9]"; then
        return 1  # Not corrupted
    else
        return 0  # Corrupted
    fi
}

# Optimize video file (if ffmpeg is available)
optimize_video() {
    local input_file="$1"
    local output_file="$2"
    local quality="${3:-medium}"

    if ! command_exists ffmpeg; then
        print_warning "ffmpeg not available, skipping optimization"
        return 1
    fi

    print_info "Optimizing video quality..."

    case "$quality" in
        "high") local crf="18" ;;
        "medium") local crf="23" ;;
        "low") local crf="28" ;;
        *) local crf="23" ;;
    esac

    if ffmpeg -i "$input_file" \
              -c:v libx264 \
              -crf "$crf" \
              -preset medium \
              -c:a aac \
              -b:a 128k \
              -movflags +faststart \
              -y "$output_file" 2>/dev/null; then

        print_success "Video optimized successfully"
        return 0
    else
        print_warning "Video optimization failed, keeping original"
        return 1
    fi
}

# Extract frame as thumbnail
extract_thumbnail() {
    local input_file="$1"
    local output_file="$2"
    local timestamp="${3:-00:00:01}"

    if ! command_exists ffmpeg; then
        print_warning "ffmpeg not available, cannot extract thumbnail"
        return 1
    fi

    if ffmpeg -i "$input_file" \
              -ss "$timestamp" \
              -vframes 1 \
              -q:v 2 \
              -y "$output_file" 2>/dev/null; then

        print_success "Thumbnail extracted: $output_file"
        return 0
    else
        print_warning "Failed to extract thumbnail"
        return 1
    fi
}
