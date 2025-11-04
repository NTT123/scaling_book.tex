# Scaling Book - LaTeX Version

LaTeX version of "How to Scale Your Model".

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

## Compilation

### Build the complete book

```bash
./build.sh
```

This will:
1. Run XeLaTeX three times to resolve cross-references
2. Process bibliography with BibTeX
3. Generate `scaling-book.pdf` in the project root

## Output

The build process creates:
- `scaling-book.pdf` - The complete book (7+ MB)
- `build/` - Directory containing intermediate build files


## License

This work is based on the original scaling book from the JAX ML community.

## Contributing

For issues or contributions, please refer to the original repository at [jax-ml/scaling-book](https://github.com/jax-ml/scaling-book).
