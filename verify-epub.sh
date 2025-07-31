#!/bin/bash

set -e

EPUB_FILE=$1
TEMP_DIR=$(mktemp -d)

# Unzip the epub file
unzip -q "$EPUB_FILE" -d "$TEMP_DIR"

# --- Verification checks ---
HAS_COVER=false
HAS_IMAGES=false
HAS_INDEX=false

# Find the root file
ROOT_FILE=$(find "$TEMP_DIR" -name "*.opf" | head -n 1)
if [ -z "$ROOT_FILE" ]; then
    echo "Error: Could not find .opf file in EPUB."
    exit 1
fi
ROOT_DIR=$(dirname "$ROOT_FILE")

# Check for cover image
COVER_HREF=$(grep '<item' "$ROOT_FILE" | grep 'properties="cover-image"' | sed -n 's/.*href="\([^"]*\)".*/\1/p')
if [ -n "$COVER_HREF" ] && [ -f "$ROOT_DIR/$COVER_HREF" ]; then
    HAS_COVER=true
fi

# Check for other images
IMAGE_COUNT=$(find "$ROOT_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.svg" \) | wc -l)
if [ "$IMAGE_COUNT" -gt 5 ]; then
    HAS_IMAGES=true
fi

# Check for index
if find "$ROOT_DIR" -name "*index.html" | grep -q "."; then
    HAS_INDEX=true
elif [ -f "$ROOT_DIR/ix01.html" ]; then
    HAS_INDEX=true
fi

# --- Report results ---
echo "Verification for: $EPUB_FILE"
echo "--------------------------"
echo "Has cover image: $HAS_COVER"
echo "Has other images: $HAS_IMAGES"
echo "Has index: $HAS_INDEX"
echo "--------------------------"

# Clean up
rm -rf "$TEMP_DIR"

# Exit with error code if any check fails
if [ "$HAS_COVER" = false ] || [ "$HAS_IMAGES" = false ] || [ "$HAS_INDEX" = false ]; then
    echo "Verification failed."
    exit 1
fi

echo "Verification successful."
exit 0
