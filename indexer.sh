#!/bin/bash

# ==============================================================================
# Asciidoctor Indexer
#
# Description:
# This script reads a list of index terms from a file and inserts them into
# an Asciidoctor document. The script is designed to work with a specific
# input format where each line contains the term to find and the index entry,
# separated by a semicolon.
#
# For a line like:
#   John Nash; Nash, John
#
# The script will find all occurrences of "John Nash" as a whole word in the
# Asciidoctor file and replace them with "John Nash(((Nash, John)))".
#
# It uses a two-stage process for reliability:
# 1. A simple `grep` to check if the literal term exists in the file. This
#    is used to flag terms that are not found.
# 2. A powerful `perl` command to perform the actual replacement, which
#    correctly handles whole-word matching and avoids duplicate entries.
#
# It is designed to be idempotent, meaning running it multiple times on the
# same file will not create duplicate index entries.
#
# Usage:
# ./asciidoctor_indexer.sh <asciidoctor_file> <index_terms_file>
#
# Arguments:
#   <asciidoctor_file>    : The path to the .adoc file to be modified.
#   <index_terms_file>  : The path to the text file containing the index terms.
#
# ==============================================================================

# --- Configuration and Setup ---

# Exit immediately if a command exits with a non-zero status.
# We temporarily disable this inside the loop for the existence check.
set -e

# --- Argument Validation ---

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ];
    then
    echo "Usage: $0 <asciidoctor_file> <index_terms_file>"
    exit 1
fi

ASCIIDOC_FILE="$1"
INDEX_FILE="$2"

# Check if the Asciidoctor file exists and is readable
if [ ! -f "$ASCIIDOC_FILE" ] || [ ! -r "$ASCIIDOC_FILE" ]; then
    echo "Error: Asciidoctor file '$ASCIIDOC_FILE' not found or not readable."
    exit 1
fi

# Check if the index terms file exists and is readable
if [ ! -f "$INDEX_FILE" ] || [ ! -r "$INDEX_FILE" ]; then
    echo "Error: Index terms file '$INDEX_FILE' not found or not readable."
    exit 1
fi

# --- Main Processing Loop ---

echo "Starting the indexing process for '$ASCIIDOC_FILE'..."

# Create a temporary file for processing to avoid issues with `perl -i` on some systems
TEMP_FILE=$(mktemp)
cp "$ASCIIDOC_FILE" "$TEMP_FILE"

# Array to store terms from the index file that were not found in the document
NOT_FOUND_TERMS=()

# Read the index file line by line
# The `|| [[ -n $line ]]` part ensures that the last line is processed
# even if it doesn't end with a newline character.
while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines
    if [ -z "$line" ]; then
        continue
    fi

    # Parse the line into the search term and the index format
    # The format is: search_term; index_format
    search_term=$(echo "$line" | cut -d';' -f1 | sed 's/^[ \t]*//;s/[ \t]*$//')
    index_format=$(echo "$line" | cut -d';' -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')

    # Check if both parts were successfully parsed
    if [ -z "$search_term" ] || [ -z "$index_format" ]; then
        echo "Warning: Skipping malformed line: '$line'"
        continue
    fi

    # --- Stage 1: Check if term exists using a simple, literal search ---
    # We use `grep -Fq` which is fast and reliable for checking if an exact
    # string exists, including those with special UTF-8 characters.
    # The `--` prevents terms starting with a hyphen from being treated as options.
    # We wrap this in `set +e` and `set -e` to prevent the script from exiting
    # if grep returns a non-zero status (which it does when a term is not found).
    set +e
    grep -qF -- "$search_term" "$TEMP_FILE"
    GREP_EXIT_CODE=$?
    set -e

    if [ $GREP_EXIT_CODE -ne 0 ]; then
        # If grep's exit code is not 0, the term was not found.
        NOT_FOUND_TERMS+=("$line")
        continue
    fi

    # --- Stage 2: Perform the smart, whole-word replacement ---
    # If we get here, the term exists. Now we use the powerful perl regex
    # to ensure we only modify the term when it appears as a whole word.
    echo "Processing: '$search_term' -> '((($index_format)))'"

    replacement="((($index_format)))"

    # We pass variables via the environment to avoid injection issues.
    export search_term
    export replacement

    # The -CS flag ensures that STDIN/STDOUT/STDERR and environment variables are treated as UTF-8.
    # The regex uses lookarounds to match whole words only and to be idempotent.
    perl -CS -i -pe 's/(?<!\w)\Q$ENV{search_term}\E(?!\w|\(\(\()/$& . $ENV{replacement}/ge' "$TEMP_FILE"

done < "$INDEX_FILE"

# Overwrite the original file with the modified temporary file
mv "$TEMP_FILE" "$ASCIIDOC_FILE"

echo "-------------------------------------"
echo "Indexing process completed successfully."
echo "File '$ASCIIDOC_FILE' has been updated."

# --- Report Not Found Terms ---
# Check if the array of not found terms has any elements
if [ ${#NOT_FOUND_TERMS[@]} -ne 0 ]; then
    echo
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!! WARNING: The following index terms were not found in the document:"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    # Loop through the array and print each unfound term
    for term in "${NOT_FOUND_TERMS[@]}"; do
        echo "  - $term"
    done
    echo
    echo "Please check the terms above for typos or remove them from your index file."
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
fi
