#!/bin/bash

# vdl4k Archive Management
# This module handles download history and archive functionality

# Check if video is in archive
is_video_in_archive() {
    local video_id="$1"
    local archive_file="${ARCHIVE_FILE:-$HOME/.cache/vdl4k/downloaded.txt}"

    [ -f "$archive_file" ] && grep -q "^${video_id}$" "$archive_file" 2>/dev/null
}

# Add video to archive
add_to_archive() {
    local video_id="$1"
    local archive_file="${ARCHIVE_FILE:-$HOME/.cache/vdl4k/downloaded.txt}"

    if [ -z "$video_id" ]; then
        print_warning "Cannot add empty video ID to archive"
        return 1
    fi

    # Create archive directory if it doesn't exist
    ensure_dir_exists "$(dirname "$archive_file")" "750"

    # Add to archive if not already present
    if ! is_video_in_archive "$video_id"; then
        echo "$video_id" >> "$archive_file"

        # Keep archive file clean by removing duplicates and empty lines
        if [ -f "$archive_file" ]; then
            # Remove duplicates, empty lines, and sort
            sort -u -o "$archive_file" "$archive_file" 2>/dev/null || true
            sed -i '/^$/d' "$archive_file" 2>/dev/null || true
        fi

        if [ "${VERBOSE:-false}" = true ]; then
            print_info "$(date '+%H:%M:%S'): Added $video_id to archive"
        fi
        return 0
    else
        if [ "${VERBOSE:-false}" = true ]; then
            print_info "$(date '+%H:%M:%S'): Video $video_id already in archive"
        fi
        return 1
    fi
}

# Remove video from archive
remove_from_archive() {
    local video_id="$1"
    local archive_file="${ARCHIVE_FILE:-$HOME/.cache/vdl4k/downloaded.txt}"

    if [ -z "$video_id" ]; then
        print_warning "Cannot remove empty video ID from archive"
        return 1
    fi

    if [ -f "$archive_file" ]; then
        # Remove the video ID from archive
        grep -v "^${video_id}$" "$archive_file" > "${archive_file}.tmp" 2>/dev/null && mv "${archive_file}.tmp" "$archive_file" 2>/dev/null

        if [ "${VERBOSE:-false}" = true ]; then
            print_info "$(date '+%H:%M:%S'): Removed $video_id from archive"
        fi
        return 0
    else
        print_warning "Archive file does not exist: $archive_file"
        return 1
    fi
}

# Get archive statistics
get_archive_stats() {
    local archive_file="${ARCHIVE_FILE:-$HOME/.cache/vdl4k/downloaded.txt}"

    if [ ! -f "$archive_file" ]; then
        echo "0 videos in archive"
        return 1
    fi

    local count
    count=$(wc -l < "$archive_file" 2>/dev/null || echo "0")

    if [ "$count" -eq 1 ]; then
        echo "$count video in archive"
    else
        echo "$count videos in archive"
    fi

    return 0
}

# Show recent downloads from archive
show_recent_downloads() {
    local count="${1:-10}"
    local archive_file="${ARCHIVE_FILE:-$HOME/.cache/vdl4k/downloaded.txt}"

    if [ ! -f "$archive_file" ]; then
        print_info "No download history found"
        return 1
    fi

    print_info "Recent downloads (last $count):"
    tail -n "$count" "$archive_file" | while read -r video_id; do
        if [ -n "$video_id" ]; then
            echo "  - $video_id"
        fi
    done
}

# Clear archive (with confirmation)
clear_archive() {
    local force="${1:-false}"
    local archive_file="${ARCHIVE_FILE:-$HOME/.cache/vdl4k/downloaded.txt}"

    if [ ! -f "$archive_file" ]; then
        print_info "Archive is already empty"
        return 0
    fi

    if [ "$force" = false ]; then
        print_warning "This will clear all download history. Continue? [y/N]"
        read -r response
        [[ ! $response =~ ^[Yy]$ ]] && return 1
    fi

    if rm -f "$archive_file"; then
        print_success "Archive cleared"
        return 0
    else
        print_error "Failed to clear archive"
        return 1
    fi
}

# Search archive for video ID pattern
search_archive() {
    local pattern="$1"
    local archive_file="${ARCHIVE_FILE:-$HOME/.cache/vdl4k/downloaded.txt}"

    if [ ! -f "$archive_file" ]; then
        print_info "No archive found"
        return 1
    fi

    local matches
    matches=$(grep "$pattern" "$archive_file" 2>/dev/null || true)

    if [ -n "$matches" ]; then
        print_info "Found matching video IDs:"
        echo "$matches"
        return 0
    else
        print_info "No matching video IDs found"
        return 1
    fi
}

# Check if URL is in archive (by extracting video ID first)
is_url_in_archive() {
    local url="$1"

    local video_id
    video_id=$(extract_video_id "$url")

    if [ -n "$video_id" ]; then
        is_video_in_archive "$video_id"
        return $?
    else
        print_warning "Could not extract video ID from URL: $url"
        return 1
    fi
}

# Get archive file path
get_archive_file() {
    echo "${ARCHIVE_FILE:-$HOME/.cache/vdl4k/downloaded.txt}"
}

# Backup archive
backup_archive() {
    local backup_dir="${1:-${CACHE_DIR}/backups}"
    local archive_file="${ARCHIVE_FILE:-$HOME/.cache/vdl4k/downloaded.txt}"

    if [ ! -f "$archive_file" ]; then
        print_info "No archive to backup"
        return 1
    fi

    # Create backup directory
    ensure_dir_exists "$backup_dir" "750"

    local backup_file="${backup_dir}/archive_$(date +%Y%m%d_%H%M%S).txt"

    if cp "$archive_file" "$backup_file"; then
        print_success "Archive backed up to: $backup_file"
        return 0
    else
        print_error "Failed to backup archive"
        return 1
    fi
}
