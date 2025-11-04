#!/bin/bash

# Build script for "How to Scale Your Model" LaTeX book
# Usage: ./build.sh [command]
#
# Commands:
#   all      - Build complete book (default)
#   chapter  - Build specific chapter (usage: ./build.sh chapter 01)
#   clean    - Remove build artifacts
#   help     - Show this help message

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

# Function to initialize git submodule if needed
init_submodule() {
    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Check if scaling-book submodule is empty
    if [ -d "$SCRIPT_DIR/scaling-book" ] && [ ! "$(ls -A "$SCRIPT_DIR/scaling-book")" ]; then
        print_info "Initializing git submodule..."
        cd "$SCRIPT_DIR" && git submodule update --init --recursive
    fi
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

# Function to build individual chapter
build_chapter() {
    local chapter_num=$1

    if [ -z "$chapter_num" ]; then
        print_error "Please specify chapter number (e.g., ./build.sh chapter 01)"
        exit 1
    fi

    # Get absolute paths
    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local ABS_BUILD_DIR="$SCRIPT_DIR/$BUILD_DIR"
    local ABS_SOURCE_DIR="$SCRIPT_DIR/$SOURCE_DIR"

    # Find chapter file
    local chapter_file="$ABS_SOURCE_DIR/chapters/${chapter_num}-*.tex"

    if ! ls $chapter_file 1> /dev/null 2>&1; then
        print_error "Chapter file not found: $chapter_file"
        exit 1
    fi

    print_info "Building chapter: $chapter_file"

    # Create a temporary wrapper file
    local temp_file="$ABS_BUILD_DIR/temp-chapter-$chapter_num.tex"
    mkdir -p "$ABS_BUILD_DIR"

    cat > "$temp_file" << EOF
\documentclass[10pt,twoside]{book}
\usepackage{fontsetup}
\usepackage[b6paper,inner=2cm,outer=0.8cm,top=0cm,bottom=0.3cm,includeheadfoot]{geometry}
\usepackage{amsmath,amssymb}
\usepackage{graphicx}
\usepackage{hyperref}
\begin{document}
\include{$chapter_file}
\end{document}
EOF

    # Build the chapter
    cd "$ABS_SOURCE_DIR" && xelatex -output-directory="$ABS_BUILD_DIR" -interaction=nonstopmode "$temp_file"

    local output_pdf="$SCRIPT_DIR/chapter-${chapter_num}.pdf"
    cp "$ABS_BUILD_DIR/temp-chapter-$chapter_num.pdf" "$output_pdf" 2>/dev/null || true

    cd "$SCRIPT_DIR"
    print_info "Chapter built: $output_pdf"
}

# Function to show help
show_help() {
    cat << EOF
Build script for "How to Scale Your Model" LaTeX book

Usage: ./build.sh [command]

Commands:
    all      - Build complete book with table of contents (default)
    chapter  - Build specific chapter (usage: ./build.sh chapter 01)
    clean    - Remove all build artifacts
    help     - Show this help message

Examples:
    ./build.sh              # Build complete book
    ./build.sh all          # Build complete book
    ./build.sh chapter 01   # Build chapter 01 only
    ./build.sh clean        # Clean build files

EOF
}

# Main script logic
case "${1:-all}" in
    all)
        build_book
        ;;
    chapter)
        build_chapter "$2"
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
