#!/bin/bash

ERROR_LOG="errors.log"

# Recursive function to search for a keyword in a directory and subdirectories
search_directory() {
    local dir="$1"
    local keyword="$2"
    for file in "$dir"/*; do
        if [[ -d "$file" ]]; then
            search_directory "$file" "$keyword"
        elif [[ -f "$file" ]]; then
            grep -q "$keyword" "$file" && echo "Match found in: $file"
        fi
    done
}

# Show help menu
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
  -d <directory>  Search recursively for a keyword in a directory.
  -k <keyword>    Keyword to search for.
  -f <file>       Search for a keyword in a specific file.
  --help          Display this help message.

Examples:
  $0 -d logs -k error   # Search 'error' in 'logs' directory.
  $0 -f script.sh -k TODO  # Search 'TODO' in 'script.sh'.
EOF
}

# Parse command-line arguments
while getopts ":d:k:f:-:" opt; do
    case "$opt" in
        d) directory="$OPTARG" ;;
        k) keyword="$OPTARG" ;;
        f) file="$OPTARG" ;;
        -) [[ "$OPTARG" == "help" ]] && show_help && exit 0 ;; 
        ?) echo "Invalid option: -$OPTARG" | tee -a "$ERROR_LOG"; exit 1 ;;
    esac
done

# Validate inputs
if [[ -z "$keyword" ]]; then
    echo "Error: Missing keyword" | tee -a "$ERROR_LOG"
    exit 1
fi

# Validate keyword (only allow alphanumeric and underscore)
if ! [[ "$keyword" =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "Error: Invalid keyword. Use only alphanumeric characters and underscores." | tee -a "$ERROR_LOG"
    exit 1
fi

# Search in directory
if [[ -n "$directory" ]]; then
    if [[ -d "$directory" ]]; then
        search_directory "$directory" "$keyword"
    else
        echo "Error: Directory '$directory' not found." | tee -a "$ERROR_LOG"
        exit 1
    fi
fi

# Search in file
if [[ -n "$file" ]]; then
    if [[ -f "$file" ]]; then
        if grep -q "$keyword" "$file"; then
            echo "Match found in: $file"
        else
            echo "No match found in: $file"
        fi
    else
        echo "Error: File '$file' not found." | tee -a "$ERROR_LOG"
        exit 1
    fi
fi

# Show help if no valid options were provided
if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi
