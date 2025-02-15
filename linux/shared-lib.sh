#!/bin/bash
#
# Shared library of functions for system setup and configuration
# This library provides common utilities for:
# - Cross-platform package management
# - File downloads with verification
# - Logging and error handling
#

# Enable strict error handling:
# - e: Exit immediately if a command exits with non-zero status
# - o pipefail: Return value of a pipeline is the value of the last (rightmost) command to exit with non-zero status
set -eo pipefail

# Global configuration variables
DEFAULT_DOWNLOADS_DIR="downloads"  # Default directory for downloaded files
DOWNLOAD_TIMEOUT=30  # Maximum time in seconds to wait for downloads

# Logger function for consistent message formatting
# Usage: log "ERROR" "Something went wrong"
# Arguments:
#   $1 - Log level (INFO, ERROR, etc.)
#   $* - Message to log
log() {
    local level=$1
    shift
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $*"
}

# Cross-platform package manager wrapper
# Detects the operating system and uses the appropriate package manager
# Supports: apt (Debian/Ubuntu), dnf (CentOS/Fedora), pacman (Arch), brew (macOS)
# Usage: pkgmgr install package-name
# Arguments: Passed directly to the underlying package manager
function pkgmgr() {
    # Input validation
    if [ $# -eq 0 ]; then
        log "ERROR" "pkgmgr: No arguments provided"
        return 1
    fi

    # OS detection and package manager selection
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS support via Homebrew
        if command -v brew >/dev/null; then
            pm="brew"
        else
            log "ERROR" "Homebrew not found. Please install from https://brew.sh"
            return 1
        fi
    else
        # Linux distribution detection
        if [ ! -f /etc/os-release ]; then
            log "ERROR" "Cannot detect Linux distribution: /etc/os-release not found"
            return 1
        fi

        # Source the os-release file to get distribution info
        source /etc/os-release
        case "$ID" in
            "ubuntu"|"debian")
                pm="apt"  # Debian-based systems
                ;;
            "centos"|"fedora"|"rhel")
                pm="dnf"  # RedHat-based systems
                ;;
            "arch")
                # Arch Linux requires different command syntax
                pm="pacman"
                case "$1" in
                    "install")
                        set -- "-S" "${@:2}"
                        ;;
                    "update")
                        set -- "-Syu" "${@:2}"
                        ;;
                    "remove")
                        set -- "-R" "${@:2}"
                        ;;
                esac
                ;;
            *)
                log "ERROR" "Unsupported distribution: $ID"
                return 1
                ;;
        esac
    fi

    log "INFO" "Using package manager: $pm"

    # Check if we need sudo for system package managers
    if [[ "$pm" != "brew" ]]; then
        if [[ $EUID -ne 0 ]]; then
            log "INFO" "Running with sudo as non-root user"
            eval sudo $pm "$@"
        else
            eval $pm "$@"
        fi
    else
        eval $pm "$@"
    fi
}

# File download utility with verification
# Downloads a file using curl (or wget as fallback) and verifies the download
# Usage: download "https://example.com/file.txt" "local-file.txt"
# Arguments:
#   $1 - Source URL
#   $2 - Local filename
# Returns:
#   Path of downloaded file on success, exits with 1 on error
function download() {
    # Input validation
    if [ $# -ne 2 ]; then
        log "ERROR" "download: Expected 2 arguments (URL, filename), got $#"
        return 1
    fi

    local url=$1
    local filename=$2
    # Allow override of downloads directory via environment variable
    local downloads=${DOWNLOADS_DIR:-$DEFAULT_DOWNLOADS_DIR}

    # Ensure downloads directory exists
    if ! mkdir -p "$downloads"; then
        log "ERROR" "Failed to create downloads directory: $downloads"
        return 1
    fi

    local filepath="$downloads/$filename"

    # Try curl first, then wget as fallback
    if command -v curl >/dev/null; then
        log "INFO" "Downloading $url using curl"
        if ! curl --connect-timeout "$DOWNLOAD_TIMEOUT" -sfL "$url" -o "$filepath"; then
            log "ERROR" "curl download failed"
            return 1
        fi
    elif command -v wget >/dev/null; then
        log "INFO" "Downloading $url using wget"
        if ! wget --timeout="$DOWNLOAD_TIMEOUT" -q "$url" -O "$filepath"; then
            log "ERROR" "wget download failed"
            return 1
        fi
    else
        log "ERROR" "Neither curl nor wget is available"
        return 1
    fi

    # Verify download success
    if [ ! -f "$filepath" ]; then
        log "ERROR" "Download failed: file not created"
        return 1
    fi

    if [ ! -s "$filepath" ]; then
        log "ERROR" "Download failed: file is empty"
        rm -f "$filepath"
        return 1
    fi

    log "INFO" "Successfully downloaded to $filepath"
    echo "$filepath"
}

# Cleanup function called on script exit
# Add any necessary cleanup tasks here
function cleanup() {
    # Currently a no-op, add cleanup tasks as needed
    :
}

# Register cleanup function to run on script exit
trap cleanup EXIT
