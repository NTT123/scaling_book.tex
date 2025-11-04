# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a LaTeX version of "How to Scale Your Model: A Systems View of LLMs on TPUs" by Jacob Austin, Sholto Douglas, Roy Frostig, and others. The project converts the original markdown book from [jax-ml/scaling-book](https://github.com/jax-ml/scaling-book) into a professionally typeset B6 book format.

## Build Commands

### Primary Build Command
```bash
./build.sh
```
This is the main command. It automatically:
- Initializes git submodules if needed
- **Syncs images from the source submodule** (new!)
- Runs XeLaTeX three times for cross-references
- Processes bibliography with BibTeX
- Generates `scaling-book.pdf` (16MB) in project root

### Other Build Commands
```bash
./build.sh clean              # Remove all build artifacts
./build.sh --skip-images      # Build without syncing images (faster rebuilds)
./build.sh help               # Show help
```

## Architecture

### Directory Structure
- **`scaling-book-tex/`** - All LaTeX source files
  - `scaling-book-main.tex` - Main document with preamble, packages, and custom commands
  - `chapters/` - Chapter files organized by number
  - `images/` - All figures and diagrams (synced from submodule during build, not committed)
  - `main.bib` - Bibliography database
- **`build/`** - Build artifacts (gitignored)
- **`scaling-book/`** - Git submodule of original markdown source (for reference and image source)

### Chapter Organization
Chapters use a hybrid structure:
- Simple chapters: Single `.tex` file (e.g., `01-roofline.tex`, `02-tpus.tex`)
- Complex chapters: Directory with main file + subdocuments
  - `03-sharding.tex` includes files from `03-sharding/`
  - `04-transformers.tex` includes files from `04-transformers/`
  - `05-training.tex` includes files from `05-training/`
  - `06-llama3.tex` includes files from `06-llama3/`
  - `07-inference.tex` includes files from `07-inference/`

Main chapter files use `\input{}` to include subdocuments.

### Build Process Details
The build script (`build.sh`) operates from project root and:
1. Initializes the git submodule if needed
2. **Syncs images from `scaling-book/assets/img/` to `scaling-book-tex/images/`** using rsync
3. Changes to `scaling-book-tex/` for XeLaTeX compilation
4. Outputs to `build/` in project root using absolute paths
5. Copies final PDF to project root as `scaling-book.pdf`

This separation keeps source and build artifacts in different locations. Images are not committed to the repository - they are automatically synced from the upstream submodule during each build.

### LaTeX Configuration
`scaling-book-main.tex` is heavily customized for B6 format:
- Uses New Computer Modern font via `fontsetup` package
- Tight margins optimized for small format (B6: 125mm × 176mm)
- Custom syntax highlighting commands for code blocks
- Custom `takeawaybox` environment using tcolorbox
- Configured for two-sided printing with inner/outer margins
- Math display breaks allowed across pages
- Bibliography uses natbib with authoryear style

### Key LaTeX Packages Used
- `geometry` - B6 paper with custom margins
- `tcolorbox` - Colored boxes for takeaways
- `natbib` - Bibliography management
- `hyperref` - Internal links and bookmarks
- `graphicx` - Image handling with auto-sizing
- `longtable`, `booktabs` - Table formatting
- `listings`, `minted` - Code syntax highlighting

## Git Submodule

The original markdown source is at `scaling-book/` as a submodule pointing to https://github.com/jax-ml/scaling-book.git. The build script automatically initializes it if empty, so manual `git submodule update --init` is not required.

## Common Workflows

### Adding/Editing Content
1. Edit `.tex` files in `scaling-book-tex/chapters/`
2. For new images:
   - Images are automatically synced from the `scaling-book` submodule during build
   - If adding new images to the project, add them to the upstream repository at `https://github.com/jax-ml/scaling-book`
   - Images in `scaling-book-tex/images/` are gitignored and will be overwritten on next build
3. Run `./build.sh` to regenerate PDF (images sync automatically)
4. Use `./build.sh --skip-images` for faster rebuilds when images haven't changed
5. Check build output for errors in `build/scaling-book-main.log`

### Debugging Build Issues
- Build logs: `build/scaling-book-main.log`
- LaTeX warnings about overfull boxes are common with tight B6 margins
- Math overflow can be addressed by:
  - Breaking long equations with `aligned` or `split`
  - Using `\allowbreak` in appropriate places
  - Adjusting math sizing in preamble

### Working with Bibliography
- Bibliography entries are in `scaling-book-tex/main.bib`
- Citations use natbib format: `\cite{key}`, `\citep{key}`, `\citet{key}`
- BibTeX automatically runs during build process
