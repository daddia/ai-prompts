#!/bin/bash

CONFLUENCE_USER="$1"
CONFLUENCE_API_TOKEN="$2"
CONFLUENCE_SPACE="$3"
CONFLUENCE_URL="$4"
METADATA_FILE="./metadata/pages_metadata.json"

# Sync each page based on the extracted metadata
jq -c 'to_entries[]' "$METADATA_FILE" | while read -r entry; do
    FILE_PATH=$(echo "$entry" | jq -r '.key')
    TITLE=$(echo "$entry" | jq -r '.value.title')
    DESCRIPTION=$(echo "$entry" | jq -r '.value.description')
    LABELS=$(echo "$entry" | jq -r '.value.labels')

    # Convert Markdown to HTML
    CONTENT=$(pandoc "$FILE_PATH" -f markdown -t html)

    # Create or update the Confluence page
    RESPONSE=$(curl -s -u "$CONFLUENCE_USER:$CONFLUENCE_API_TOKEN" \
        -X POST \
        -H "Content-Type: application/json" \
        --data @- \
        "$CONFLUENCE_URL/wiki/rest/api/content" <<EOF
{
  "type": "page",
  "title": "$TITLE",
  "space": {"key": "$CONFLUENCE_SPACE"},
  "body": {
    "storage": {
      "value": "$CONTENT",
      "representation": "storage"
    }
  }
}
EOF
    )

    PAGE_ID=$(echo "$RESPONSE" | jq -r '.id')

    # Add labels
    IFS=',' read -ra LABEL_ARRAY <<< "$LABELS"
    for label in "${LABEL_ARRAY[@]}"; do
        curl -s -u "$CONFLUENCE_USER:$CONFLUENCE_API_TOKEN" \
            -X POST \
            -H "Content-Type: application/json" \
            --data "{\"prefix\":\"global\",\"name\":\"$label\"}" \
            "$CONFLUENCE_URL/wiki/rest/api/content/$PAGE_ID/label"
    done

    # Add description
    if [ -n "$DESCRIPTION" ]; then
        curl -s -u "$CONFLUENCE_USER:$CONFLUENCE_API_TOKEN" \
            -X PUT \
            -H "Content-Type: application/json" \
            --data "{\"description\":\"$DESCRIPTION\"}" \
            "$CONFLUENCE_URL/wiki/rest/api/content/$PAGE_ID"
    fi

    echo "Synced: $TITLE"
done
