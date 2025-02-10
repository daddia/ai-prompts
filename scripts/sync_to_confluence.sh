#!/bin/bash

# Load environment variables from .env file
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "Error: .env file not found!"
    exit 1
fi

# Ensure required variables are set
if [ -z "$CONFLUENCE_USER" ] || [ -z "$CONFLUENCE_API_KEY" ] || [ -z "$CONFLUENCE_SPACE" ] || [ -z "$CONFLUENCE_URL" ]; then
    echo "Error: Missing required Confluence credentials in .env file."
    exit 1
fi

# Process each page from metadata
METADATA_FILE="./metadata/pages_metadata.json"
if [ ! -f "$METADATA_FILE" ]; then
    echo "Error: Metadata file not found!"
    exit 1
fi
echo "Reading metadata from: $METADATA_FILE"
cat "$METADATA_FILE"

jq -c 'to_entries[]' "$METADATA_FILE" | while read -r entry; do
    FILE_PATH=$(echo "$entry" | jq -r '.key')
    TITLE=$(echo "$entry" | jq -r '.value.title')
    DESCRIPTION=$(echo "$entry" | jq -r '.value.description')
    LABELS=$(echo "$entry" | jq -r '.value.labels')
    CONFLUENCE_ID=$(echo "$entry" | jq -r '.value.confluenceId // empty')

    # Extract folder name from file path and transform it
    FOLDER_NAME=$(echo "$FILE_PATH" | sed -n 's/^\.\/docs\/\([^/]*\)\/.*/\1/p' | tr '-' ' ' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
    echo "Processing: $TITLE in folder: $FOLDER_NAME"

    # Create or get parent folder
    if [ -n "$PARENT_ID_STORED" ]; then
        PARENT_ID=$PARENT_ID_STORED
    else
        PARENT_RESPONSE=$(curl -s -u "$CONFLUENCE_USER:$CONFLUENCE_API_KEY" \
            -X POST \
            -H "Content-Type: application/json" \
            --data "{
                \"type\": \"page\",
                \"title\": \"$FOLDER_NAME\",
                \"space\": {\"key\": \"$CONFLUENCE_SPACE\"},
                \"body\": {
                    \"storage\": {
                        \"value\": \"<h1>$FOLDER_NAME</h1><p>Collection of $FOLDER_NAME related prompts</p>\",
                        \"representation\": \"storage\"
                    }
                }
            }" \
            "$CONFLUENCE_URL/wiki/rest/api/content")
        PARENT_ID=$(echo "$PARENT_RESPONSE" | jq -r '.id')
        
        # Update metadata with parent ID
        jq --arg path "$FILE_PATH" --arg id "$PARENT_ID" \
            'to_entries | map(if .key == $path then .value.parentId = $id else . end) | from_entries' \
            "$METADATA_FILE" > "${METADATA_FILE}.tmp" && mv "${METADATA_FILE}.tmp" "$METADATA_FILE"
    fi

    # Debug output
    echo "Parent ID: $PARENT_ID"
    echo "Creating child page under parent..."

    # Convert Markdown to HTML and properly escape for JSON
    CONTENT=$(pandoc "$FILE_PATH" -f markdown -t html | jq -sR .)
    
    if [ -n "$CONFLUENCE_ID" ]; then
        # Get current version number for update
        VERSION_INFO=$(curl -s -u "$CONFLUENCE_USER:$CONFLUENCE_API_KEY" \
            -X GET \
            "$CONFLUENCE_URL/wiki/rest/api/content/$CONFLUENCE_ID?expand=version" )
        CURRENT_VERSION=$(echo "$VERSION_INFO" | jq -r '.version.number')
        NEXT_VERSION=$((CURRENT_VERSION + 1))

        # Update existing page
        JSON_PAYLOAD=$(cat <<EOF
{
    "type": "page",
    "title": "$TITLE",
    "ancestors": [{"id": "$PARENT_ID"}],
    "version": {"number": $NEXT_VERSION},
    "space": {"key": "$CONFLUENCE_SPACE"},
    "body": {
        "storage": {
            "value": ${CONTENT},
            "representation": "storage"
        }
    }
}
EOF
)
        RESPONSE=$(curl -s -u "$CONFLUENCE_USER:$CONFLUENCE_API_KEY" \
            -X PUT \
            -H "Content-Type: application/json" \
            --data "$JSON_PAYLOAD" \
            "$CONFLUENCE_URL/wiki/rest/api/content/$CONFLUENCE_ID")
        echo "Updated existing page: $TITLE (ID: $CONFLUENCE_ID)"
    else
        # Convert Markdown to HTML and properly escape for JSON
        CONTENT=$(pandoc "$FILE_PATH" -f markdown -t html | jq -sR .)

        # Create new page
        JSON_PAYLOAD=$(cat <<EOF
{
    "type": "page",
    "title": "$TITLE",
    "ancestors": [{"id": "$PARENT_ID"}],
    "space": {"key": "$CONFLUENCE_SPACE"},
    "body": {
        "storage": {
            "value": ${CONTENT},
            "representation": "storage"
        }
    }
}
EOF
)
        RESPONSE=$(curl -s -u "$CONFLUENCE_USER:$CONFLUENCE_API_KEY" \
            -X POST \
            -H "Content-Type: application/json" \
            --data "$JSON_PAYLOAD" \
            "$CONFLUENCE_URL/wiki/rest/api/content")
        
        # Extract new page ID
        NEW_PAGE_ID=$(echo "$RESPONSE" | jq -r '.id')
        
        if [ -n "$NEW_PAGE_ID" ] && [ "$NEW_PAGE_ID" != "null" ]; then
            # Update metadata file with new ID
            jq --arg path "$FILE_PATH" --arg id "$NEW_PAGE_ID" \
                'to_entries | map(if .key == $path then .value.confluenceId = $id else . end) | from_entries' \
                "$METADATA_FILE" > "${METADATA_FILE}.tmp" && mv "${METADATA_FILE}.tmp" "$METADATA_FILE"
            
            echo "Created new page: $TITLE (ID: $NEW_PAGE_ID)"
        fi
    fi

    PAGE_ID=${CONFLUENCE_ID:-$NEW_PAGE_ID}
    
    if [ -n "$PAGE_ID" ]; then
        # Add labels if present
        if [ -n "$LABELS" ]; then
            IFS=',' read -ra LABEL_ARRAY <<< "$LABELS"
            for label in "${LABEL_ARRAY[@]}"; do
                label_trimmed=$(echo "$label" | tr -d '"' | xargs)
                curl -s -u "$CONFLUENCE_USER:$CONFLUENCE_API_KEY" \
                    -X POST \
                    -H "Content-Type: application/json" \
                    --data "{\"prefix\":\"global\",\"name\":\"$label_trimmed\"}" \
                    "$CONFLUENCE_URL/wiki/rest/api/content/$PAGE_ID/label"
            done
        fi

        # Add description if present
        if [ -n "$DESCRIPTION" ]; then
            curl -s -u "$CONFLUENCE_USER:$CONFLUENCE_API_KEY" \
                -X PUT \
                -H "Content-Type: application/json" \
                --data "{\"description\":\"$DESCRIPTION\"}" \
                "$CONFLUENCE_URL/wiki/rest/api/content/$PAGE_ID"
        fi
    fi
done
