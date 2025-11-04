#!/bin/bash

# Build script for "How to Scale Your Model" LaTeX book
# Usage: ./build.sh [flags] [command]
#
# Commands:
#   all      - Build complete book (default)
#   clean    - Remove build artifacts
#   help     - Show this help message
#
# Flags:
#   --skip-images  - Skip syncing images from source submodule

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Directories
SOURCE_DIR="scaling-book-tex"
BUILD_DIR="build"
MAIN_FILE="scaling-book-main.tex"
OUTPUT_PDF="scaling-book.pdf"

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to clean build artifacts
clean() {
    print_info "Cleaning build artifacts..."
    rm -rf "$BUILD_DIR"/*
    rm -f "$SOURCE_DIR"/*.aux "$SOURCE_DIR"/*.log "$SOURCE_DIR"/*.toc "$SOURCE_DIR"/*.out "$SOURCE_DIR"/*.fdb_latexmk "$SOURCE_DIR"/*.fls "$SOURCE_DIR"/*.synctex.gz "$SOURCE_DIR"/*.bbl "$SOURCE_DIR"/*.blg
    rm -f "$SOURCE_DIR"/chapters/*.aux
    print_info "Clean complete."
}

# Global flag for skipping image sync
SKIP_IMAGES=false

# Function to initialize git submodule if needed
init_submodule() {
    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Check if scaling-book submodule is empty
    if [ -d "$SCRIPT_DIR/scaling-book" ] && [ ! "$(ls -A "$SCRIPT_DIR/scaling-book")" ]; then
        print_info "Initializing git submodule..."
        cd "$SCRIPT_DIR" && git submodule update --init --recursive
    fi
}

# Function to sync images from source submodule
sync_images() {
    if [ "$SKIP_IMAGES" = true ]; then
        print_info "Skipping image sync (--skip-images flag set)"
        return 0
    fi

    print_info "Syncing images from source submodule..."

    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local SOURCE_IMG="$SCRIPT_DIR/scaling-book/assets/img"
    local SOURCE_GPU="$SCRIPT_DIR/scaling-book/assets/gpu"
    local DEST_IMG="$SCRIPT_DIR/$SOURCE_DIR/images"

    # Check if source directories exist
    if [ ! -d "$SOURCE_IMG" ]; then
        print_warning "Source image directory not found: $SOURCE_IMG"
        print_warning "Make sure the git submodule is initialized"
        return 1
    fi

    # Create destination directories
    mkdir -p "$DEST_IMG/gpu"

    # Copy PNG files using rsync (only updates changed files)
    rsync -au --exclude="*.gif" "$SOURCE_IMG/" "$DEST_IMG/" 2>/dev/null || true

    # Copy GPU images
    if [ -d "$SOURCE_GPU" ]; then
        rsync -au "$SOURCE_GPU/" "$DEST_IMG/gpu/" 2>/dev/null || true
    fi

    # Copy specific GIF files that are kept as GIFs in LaTeX
    for gif in all-gather continuous-batching pointwise-product; do
        if [ -f "$SOURCE_IMG/${gif}.gif" ]; then
            cp -p "$SOURCE_IMG/${gif}.gif" "$DEST_IMG/"
        fi
    done

    print_info "Image sync complete"
}

# Function to build complete book
build_book() {
    print_info "Building complete book: $MAIN_FILE"

    # Get absolute paths
    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local ABS_BUILD_DIR="$SCRIPT_DIR/$BUILD_DIR"
    local ABS_SOURCE_DIR="$SCRIPT_DIR/$SOURCE_DIR"

    # Initialize submodule if needed
    init_submodule

    # Sync images from source submodule
    sync_images

    # Create build directory if it doesn't exist
    mkdir -p "$ABS_BUILD_DIR"

    # Copy bibliography file to build directory if it exists
    if [ -f "$ABS_SOURCE_DIR/main.bib" ]; then
        cp "$ABS_SOURCE_DIR/main.bib" "$ABS_BUILD_DIR/"
    fi

    # Run xelatex three times for TOC and cross-references, with bibtex for bibliography
    print_info "Running xelatex (pass 1/3)..."
    cd "$ABS_SOURCE_DIR" && xelatex -output-directory="$ABS_BUILD_DIR" -interaction=nonstopmode "$MAIN_FILE" > /dev/null 2>&1 || true

    print_info "Running bibtex..."
    cd "$ABS_BUILD_DIR" && bibtex scaling-book-main > /dev/null 2>&1 || true

    print_info "Running xelatex (pass 2/3)..."
    cd "$ABS_SOURCE_DIR" && xelatex -output-directory="$ABS_BUILD_DIR" -interaction=nonstopmode "$MAIN_FILE" > /dev/null 2>&1 || true

    print_info "Running xelatex (pass 3/3)..."
    cd "$ABS_SOURCE_DIR" && xelatex -output-directory="$ABS_BUILD_DIR" -interaction=nonstopmode "$MAIN_FILE" > /dev/null 2>&1 || true

    # Return to script directory
    cd "$SCRIPT_DIR"

    # Check if PDF was created (xelatex may return non-zero due to warnings)
    if [ -f "$ABS_BUILD_DIR/scaling-book-main.pdf" ]; then
        # Copy PDF to root directory for easy access
        cp "$ABS_BUILD_DIR/scaling-book-main.pdf" "$OUTPUT_PDF"
        print_info "Build successful! PDF created: $OUTPUT_PDF"

        # Show file size
        local filesize=$(ls -lh "$OUTPUT_PDF" | awk '{print $5}')
        print_info "File size: $filesize"
    else
        print_error "Build failed. Check the log file in $BUILD_DIR/"
        cat "$ABS_BUILD_DIR/scaling-book-main.log" | tail -50
        exit 1
    fi
}

# Function to show help
show_help() {
    cat << EOF
Build script for "How to Scale Your Model" LaTeX book

Usage: ./build.sh [flags] [command]

Commands:
    all      - Build complete book with table of contents (default)
    clean    - Remove all build artifacts
    help     - Show this help message

Flags:
    --skip-images  - Skip syncing images from source submodule (faster rebuilds)

Examples:
    ./build.sh                    # Build complete book
    ./build.sh all                # Build complete book
    ./build.sh --skip-images all  # Build without syncing images
    ./build.sh clean              # Clean build files

Note: Images are automatically synced from the scaling-book submodule.
Use --skip-images for faster rebuilds when images haven't changed.

EOF
}

# Main script logic
# Check for flags first
while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-images)
            SKIP_IMAGES=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

case "${1:-all}" in
    all)
        build_book
        ;;
    clean)
        clean
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
