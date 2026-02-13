#!/bin/bash
# convert_pdfs_to_svgs.sh
# Converts all PDFs in the figures/ directory (and subdirectories) to SVGs if an SVG does not already exist.
# Requires: pdf2svg (install via Homebrew: brew install pdf2svg)

FIGURES_DIR="$(dirname "$0")/figures"

if ! command -v pdf2svg &> /dev/null; then
  echo "Error: pdf2svg is not installed. Install it with: brew install pdf2svg"
  exit 1
fi

if [ ! -d "$FIGURES_DIR" ]; then
  echo "figures directory not found"
  exit 1
fi

find "$FIGURES_DIR" -type f -name '*.pdf' | while read -r pdf; do
  svg="${pdf%.pdf}.svg"
  if [ ! -f "$svg" ]; then
    echo "Converting $pdf to $svg..."
    pdf2svg "$pdf" "$svg"
  else
    echo "$svg already exists, skipping."
  fi
done