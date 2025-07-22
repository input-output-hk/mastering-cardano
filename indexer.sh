#!/bin/bash

# ==============================================================================
# Robust Asciidoctor Indexer - Clean Version
# ==============================================================================

set -e

# --- Argument Validation ---
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <asciidoctor_file> <index_terms_file>"
    exit 1
fi

ASCIIDOC_FILE="$1"
INDEX_FILE="$2"

# Check if files exist and are readable
if [ ! -f "$ASCIIDOC_FILE" ] || [ ! -r "$ASCIIDOC_FILE" ]; then
    echo "Error: Asciidoctor file '$ASCIIDOC_FILE' not found or not readable."
    exit 1
fi

if [ ! -f "$INDEX_FILE" ] || [ ! -r "$INDEX_FILE" ]; then
    echo "Error: Index terms file '$INDEX_FILE' not found or not readable."
    exit 1
fi

echo "Starting the indexing process for '$ASCIIDOC_FILE'..."

# Create temporary files
TEMP_FILE=$(mktemp)
SORTED_TERMS=$(mktemp)
PYTHON_SCRIPT=$(mktemp --suffix=.py)
cp "$ASCIIDOC_FILE" "$TEMP_FILE"

# Create the Python processing script
cat > "$PYTHON_SCRIPT" << 'EOF'
import re
import sys

def process_file(filename, search_term, index_format):
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    lines = content.split('\n')
    result_lines = []
    
    in_code_block = False
    in_listing_block = False
    
    for line in lines:
        stripped_line = line.strip()
        
        # Track code block boundaries
        if stripped_line.startswith('```'):
            in_code_block = not in_code_block
            result_lines.append(line)
            continue
        
        if stripped_line.startswith('----'):
            in_listing_block = not in_listing_block
            result_lines.append(line)
            continue
        
        # Skip processing if in code/listing block or already has markup
        if in_code_block or in_listing_block or '(((' in line:
            result_lines.append(line)
            continue
        
        # Skip special AsciiDoc formatting and code-like lines
        stripped = line.strip()
        skip_conditions = [
            stripped.startswith('='),
            stripped.startswith('*'),
            stripped.startswith('.'),
            stripped.startswith('['),
            stripped.startswith('|'),
            stripped.startswith('//'),
            stripped.startswith('::'),
            stripped.startswith('+'),
            stripped.startswith('-'),
            stripped.startswith('cardano-cli'),
            stripped.startswith('\\'),
            stripped.startswith('{'),
            stripped.startswith('}'),
            stripped.startswith('"'),
            stripped.startswith("'"),
            stripped.endswith(' Lovelace'),
            stripped.endswith(' lovelace'),
            'pool ' in stripped and ('minpoll' in stripped or 'maxpoll' in stripped),
            stripped.startswith('maxupdateskew'),
            stripped.startswith('makestep'),
            stripped.startswith('rtsync'),
            stripped.startswith('leapsectz')
        ]
        
        if any(skip_conditions):
            result_lines.append(line)
            continue
        
        # Skip lines that are just numbers followed by Lovelace
        if re.match(r'^\d+\s+(Lovelace|lovelace)$', stripped):
            result_lines.append(line)
            continue
        
        # Perform the replacement
        pattern = r'\b' + re.escape(search_term) + r'\b'
        replacement = search_term + '(((' + index_format + ')))'
        new_line = re.sub(pattern, replacement, line)
        result_lines.append(new_line)
    
    with open(filename, 'w', encoding='utf-8') as f:
        f.write('\n'.join(result_lines))

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <filename> <search_term> <index_format>")
        sys.exit(1)
    
    filename = sys.argv[1]
    search_term = sys.argv[2]
    index_format = sys.argv[3]
    
    process_file(filename, search_term, index_format)
EOF

# Pre-process and sort terms by length (longest first)
echo "Preprocessing and sorting terms..."
while IFS= read -r line || [[ -n "$line" ]]; do
    if [ -z "$line" ]; then
        continue
    fi
    
    search_term=$(echo "$line" | cut -d';' -f1 | sed 's/^[ \t]*//;s/[ \t]*$//')
    index_format=$(echo "$line" | cut -d';' -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')
    
    if [ -z "$search_term" ] || [ -z "$index_format" ]; then
        continue
    fi
    
    echo "${#search_term}|$line"
done < "$INDEX_FILE" | sort -nr -t'|' -k1,1 | cut -d'|' -f2- > "$SORTED_TERMS"

# Array to store terms not found
NOT_FOUND_TERMS=()

# Process terms in sorted order (longest first)
while IFS= read -r line || [[ -n "$line" ]]; do
    if [ -z "$line" ]; then
        continue
    fi

    search_term=$(echo "$line" | cut -d';' -f1 | sed 's/^[ \t]*//;s/[ \t]*$//')
    index_format=$(echo "$line" | cut -d';' -f2 | sed 's/^[ \t]*//;s/[ \t]*$//')

    if [ -z "$search_term" ] || [ -z "$index_format" ]; then
        echo "Warning: Skipping malformed line: '$line'"
        continue
    fi

    # Check if term exists
    set +e
    grep -qF -- "$search_term" "$TEMP_FILE"
    GREP_EXIT_CODE=$?
    set -e

    if [ $GREP_EXIT_CODE -ne 0 ]; then
        NOT_FOUND_TERMS+=("$line")
        continue
    fi

    echo "Processing: '$search_term' -> '((($index_format)))'"
    python3 "$PYTHON_SCRIPT" "$TEMP_FILE" "$search_term" "$index_format"

done < "$SORTED_TERMS"

# Clean up temporary files
rm "$SORTED_TERMS"
rm "$PYTHON_SCRIPT"

# Replace original file
mv "$TEMP_FILE" "$ASCIIDOC_FILE"

echo "-------------------------------------"
echo "Indexing process completed successfully."
echo "File '$ASCIIDOC_FILE' has been updated."

# Report not found terms and clean up index file
if [ ${#NOT_FOUND_TERMS[@]} -ne 0 ]; then
    echo
    echo "=============================================================="
    echo "Cleaning up index file - removing terms not found in document"
    echo "=============================================================="
    
    # Create a temporary file for the cleaned index
    CLEANED_INDEX=$(mktemp)
    
    # Read the original index file and only keep terms that were found
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines
        if [ -z "$line" ]; then
            echo "$line" >> "$CLEANED_INDEX"
            continue
        fi
        
        # Check if this line is in the NOT_FOUND_TERMS array
        found_in_not_found=false
        for not_found_term in "${NOT_FOUND_TERMS[@]}"; do
            if [ "$line" = "$not_found_term" ]; then
                found_in_not_found=true
                break
            fi
        done
        
        # Only keep the line if it wasn't in the not found list
        if [ "$found_in_not_found" = false ]; then
            echo "$line" >> "$CLEANED_INDEX"
        fi
    done < "$INDEX_FILE"
    
    # Replace the original index file with the cleaned version
    mv "$CLEANED_INDEX" "$INDEX_FILE"
    
    echo "Removed ${#NOT_FOUND_TERMS[@]} unused terms from '$INDEX_FILE'"
    echo
    echo "The following terms were removed:"
    for term in "${NOT_FOUND_TERMS[@]}"; do
        # Just show the search term part (before the semicolon)
        search_term=$(echo "$term" | cut -d';' -f1 | sed 's/^[ \t]*//;s/[ \t]*$//')
        echo "  - $search_term"
    done
    echo "=============================================================="
else
    echo "All index terms were found in the document - no cleanup needed."
fi
