# Scaling Book - LaTeX Version

LaTeX version of "How to Scale Your Model: A Systems View of LLMs on TPUs" by Jacob Austin, Sholto Douglas, Roy Frostig, and others.

## Overview

This repository contains the LaTeX source files for converting the scaling book into a professionally typeset B6 format book (125mm × 176mm). The original markdown version is available at [jax-ml/scaling-book](https://github.com/jax-ml/scaling-book).

## Repository Structure

- `build.sh` - Build script for generating the PDF
- `scaling-book-tex/` - LaTeX source files
  - `scaling-book-main.tex` - Main document file
  - `chapters/` - Individual chapter files (12 chapters)
  - `images/` - Figures and diagrams (auto-synced from submodule, not committed)
  - `main.bib` - Bibliography
- `scaling-book/` - Git submodule containing original markdown source and images
- `build/` - Build artifacts (generated, not tracked)

## Requirements

- XeLaTeX (from TeX Live or MacTeX)
- BibTeX (included with TeX distributions)
- Git (for submodule management)
- rsync (standard on Unix systems)

## Compilation

### Quick Start

```bash
./build.sh
```

This will automatically:
1. Initialize the git submodule if needed
2. **Sync images from the submodule** (PNG/GIF files)
3. Run XeLaTeX three times to resolve cross-references
4. Process bibliography with BibTeX
5. Generate `scaling-book.pdf` (16MB) in the project root

### Build Commands

```bash
# Build complete book (default)
./build.sh

# Build complete book (explicit)
./build.sh all

# Build without syncing images (faster rebuilds)
./build.sh --skip-images

# Build specific chapter only
./build.sh chapter 01

# Clean build artifacts
./build.sh clean

# Show help
./build.sh help
```

### Image Syncing

Images are automatically synced from the `scaling-book` submodule during build:
- **Source:** `scaling-book/assets/img/` and `scaling-book/assets/gpu/`
- **Destination:** `scaling-book-tex/images/`
- **Note:** Images are not committed to this repository - they are generated during build
- **Fast rebuilds:** Use `./build.sh --skip-images` when images haven't changed

## Output

The build process creates:
- `scaling-book.pdf` - The complete book (16MB, 277 pages)
- `build/` - Directory containing intermediate build files
- `scaling-book-tex/images/` - Synced images from submodule (99 files)

## Book Contents

The book covers 12 chapters on scaling large language models:

0. **Introduction** - Overview and motivation
1. **All About Rooflines** - Performance modeling and bottleneck analysis
2. **How to Think About TPUs** - TPU architecture and characteristics
3. **Sharding and Communication** - Partitioning strategies and communication primitives
4. **Transformers** - Architecture, FLOPs, and parameter counting
5. **Training** - Data parallelism, FSDP, tensor parallelism, and pipelining
6. **Training LLaMA 3 on TPUs** - Applied training example with LLaMA 3
7. **Inference** - KV caching, batching strategies, and optimization techniques
8. **Applied Inference** - Practical inference with throughput analysis
9. **Profiling** - XProf, trace viewer, and performance debugging
10. **JAX and XLA** - Sharding APIs and auto-sharding
11. **Conclusion** - Summary and future directions
12. **How to Think About GPUs** - GPU architecture, networking, and rooflines

## Project Information

### Format
- **Paper size:** B6 (125mm × 176mm)
- **Font:** New Computer Modern
- **Total pages:** 277
- **File size:** ~16MB

### LaTeX Features
- Custom takeaway boxes using tcolorbox
- Optimized margins for small format printing
- Two-sided printing with inner/outer margins
- Comprehensive bibliography with natbib
- Syntax highlighting for code examples

## License

This work is based on the original scaling book from the JAX ML community. Please refer to the original repository for licensing information.

## Contributing

For content contributions or issues with the original material, please refer to [jax-ml/scaling-book](https://github.com/jax-ml/scaling-book).

For issues specific to the LaTeX conversion, please open an issue in this repository.

## Acknowledgments

- Original authors: Jacob Austin, Sholto Douglas, Roy Frostig, and contributors
- Original source: [JAX ML Scaling Book](https://github.com/jax-ml/scaling-book)
