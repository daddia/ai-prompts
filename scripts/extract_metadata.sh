#!/bin/bash

# Directory where markdown files are stored
DOCS_DIR="./docs"
OUTPUT_FILE="./metadata/pages_metadata.json"

# Ensure output directory exists
mkdir -p ./metadata
echo "{}" > "$OUTPUT_FILE"  # Clear the existing metadata

# Extract metadata from each Markdown file
find "$DOCS_DIR" -name "*.md" | while read -r file; do
    TITLE=$(grep -m1 '^title:' "$file" | sed 's/^title: //;s/"//g')
    DESCRIPTION=$(grep -m1 '^description:' "$file" | sed 's/^description: //;s/"//g')
    LABELS=$(grep '^labels:' -A 10 "$file" | sed -n '/- /s/- //p' | tr '\n' ',' | sed 's/,$//')

    # Fallback to filename if no title is provided
    [ -z "$TITLE" ] && TITLE=$(basename "$file" .md)

    # Store metadata in JSON format
    jq --arg path "$file" --arg title "$TITLE" --arg desc "$DESCRIPTION" --arg labels "$LABELS" \
    '. + {($path): {"title": $title, "description": $desc, "labels": $labels}}' \
    "$OUTPUT_FILE" > tmp.json && mv tmp.json "$OUTPUT_FILE"
done

echo "Metadata extraction completed. Stored in $OUTPUT_FILE."