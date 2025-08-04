#!/usr/bin/env bash
set -euo pipefail

# ── Book Settings ─────────────────────────────────────────────────
FILENAME="mastering-cardano"
VERSION="v1.0.0"

rm -rf dist/images-processed
mkdir -p dist/images-processed
cp images-processed/* dist/images-processed/

bundle exec asciidoctor-pdf \
	-r ./theme/custom-highlight.rb \
	-a rouge-style=custom-highlight \
	-a imagesdir=dist/images-processed \
	-a pdf-themesdir=theme \
	-a pdf-fontsdir="theme;GEM_FONTS_DIR" \
	-a pdf-theme=custom \
	--failure-level WARN \
	main.adoc \
	-o dist/${FILENAME}-${VERSION}.pdf

