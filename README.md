# Scaling Book - LaTeX Version

LaTeX version of "How to Scale Your Model" - a comprehensive guide to scaling machine learning models.

## Overview

This repository contains the LaTeX source files for the scaling book, converted from the original markdown version available at [jax-ml/scaling-book](https://github.com/jax-ml/scaling-book).

## Repository Structure

- `build.sh` - Build script for generating the PDF
- `scaling-book-tex/` - LaTeX source files
  - `scaling-book-main.tex` - Main document file
  - `chapters/` - Individual chapter files
  - `images/` - Figures and diagrams
  - `main.bib` - Bibliography
- `scaling-book/` - Git submodule containing original markdown source
- `build/` - Build artifacts (generated, not tracked)

## Prerequisites

To compile the book, you need:

- **XeLaTeX** - Part of a TeX distribution like [TeX Live](https://www.tug.org/texlive/) or [MacTeX](https://www.tug.org/mactex/)
- **BibTeX** - For bibliography processing (usually included with TeX distributions)

### Installing on macOS

```bash
brew install --cask mactex
```

### Installing on Linux

```bash
# Ubuntu/Debian
sudo apt-get install texlive-xetex texlive-bibtex-extra

# Fedora
sudo dnf install texlive-xetex texlive-bibtex
```

## Compilation

### Build the complete book

```bash
./build.sh
```

This will:
1. Run XeLaTeX three times to resolve cross-references
2. Process bibliography with BibTeX
3. Generate `scaling-book.pdf` in the project root

### Build a specific chapter

```bash
./build.sh chapter 01
```

This generates a standalone PDF for the specified chapter.

### Clean build artifacts

```bash
./build.sh clean
```

### Get help

```bash
./build.sh help
```

## Output

The build process creates:
- `scaling-book.pdf` - The complete book (7+ MB)
- `build/` - Directory containing intermediate build files

## Git Submodule

The original markdown source is included as a git submodule. To initialize it after cloning:

```bash
git submodule update --init --recursive
```

## License

This work is based on the original scaling book from the JAX ML community.

## Contributing

For issues or contributions, please refer to the original repository at [jax-ml/scaling-book](https://github.com/jax-ml/scaling-book).
