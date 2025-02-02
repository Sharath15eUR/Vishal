#!/bin/bash

# Check if correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <source_directory> <backup_directory> <file_extension>"
    exit 1
fi

SOURCE_DIR="$1"
BACKUP_DIR="$2"
FILE_EXT="$3"

# Ensure source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory does not exist."
    exit 1
fi

# Create backup directory if it does not exist
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR" || { echo "Error: Failed to create backup directory."; exit 1; }
fi

# Find files matching the extension
FILES=($(find "$SOURCE_DIR" -maxdepth 1 -type f -name "*$FILE_EXT"))

# Check if files exist
if [ "${#FILES[@]}" -eq 0 ]; then
    echo "No files with extension $FILE_EXT found in $SOURCE_DIR."
    exit 0
fi

# Initialize backup count
export BACKUP_COUNT=0
TOTAL_SIZE=0

# Perform backup
for FILE in "${FILES[@]}"; do
    FILE_NAME=$(basename "$FILE")
    DEST_FILE="$BACKUP_DIR/$FILE_NAME"
    FILE_SIZE=$(stat -c %s "$FILE")
    echo "Backing up: $FILE_NAME ($FILE_SIZE bytes)"
    
    # Check if file exists in backup directory and compare timestamps
    if [ -f "$DEST_FILE" ]; then
        if [ "$FILE" -nt "$DEST_FILE" ]; then
            cp "$FILE" "$DEST_FILE"
            echo "Updated: $FILE_NAME"
        else
            echo "Skipped (Already up to date): $FILE_NAME"
            continue
        fi
    else
        cp "$FILE" "$DEST_FILE"
        echo "Copied: $FILE_NAME"
    fi
    
    BACKUP_COUNT=$((BACKUP_COUNT + 1))
    TOTAL_SIZE=$((TOTAL_SIZE + FILE_SIZE))

done

# Generate report
REPORT_FILE="$BACKUP_DIR/backup_report.log"
echo "Backup Report - $(date)" > "$REPORT_FILE"
echo "Total files backed up: $BACKUP_COUNT" >> "$REPORT_FILE"
echo "Total size of files: $TOTAL_SIZE bytes" >> "$REPORT_FILE"
echo "Backup Directory: $BACKUP_DIR" >> "$REPORT_FILE"

echo "Backup completed. Report saved to $REPORT_FILE"
