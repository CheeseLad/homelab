#!/bin/bash

# Config
MEDIA_DIR="/mnt/storage-hdd/Media"
EXTENSIONS=("mp4" "mkv" "avi" "mov" "flv")
REPORT_DIR="/home/jake/backups/media"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_FILE="${REPORT_DIR}/media_${TIMESTAMP}.txt"

# Create report directory if it doesn't exist
mkdir -p "$REPORT_DIR"

# Header
echo "Media Backup - $TIMESTAMP" > "$OUTPUT_FILE"
echo "Path: $MEDIA_DIR" >> "$OUTPUT_FILE"
echo "Extensions: ${EXTENSIONS[*]}" >> "$OUTPUT_FILE"
echo >> "$OUTPUT_FILE"

# Exclusion logic
should_skip_dir() {
    local path="$1"
    [[ "$path" == *"320 - 10x10"* || "$path" == *".trickplay"* ]]
}

# Build extension filters for find
build_find_ext_filters() {
    local filters=()
    for ext in "${EXTENSIONS[@]}"; do
        filters+=("-iname" "*.${ext}" "-o")
    done
    unset 'filters[-1]'  # Remove final "-o"
    echo "${filters[@]}"
}

EXT_FILTERS=$(build_find_ext_filters)

# Start scanning
for top_folder in "$MEDIA_DIR"/*/; do
    [ -d "$top_folder" ] || continue
    top_folder_name=$(basename "$top_folder")
    echo "$top_folder_name/" >> "$OUTPUT_FILE"

    if [ "$top_folder_name" == "Series" ]; then
        for show_dir in "$top_folder"*/; do
            [ -d "$show_dir" ] || continue
            show_name=$(basename "$show_dir")
            if should_skip_dir "$show_dir"; then continue; fi
            echo "  $show_name/" >> "$OUTPUT_FILE"

            for season_dir in "$show_dir"*/; do
                [ -d "$season_dir" ] || continue
                season_name=$(basename "$season_dir")
                if should_skip_dir "$season_dir"; then continue; fi
                echo "    $season_name/" >> "$OUTPUT_FILE"

                while IFS= read -r -d '' file; do
                    if should_skip_dir "$(dirname "$file")"; then continue; fi
                    echo "      $(basename "$file")" >> "$OUTPUT_FILE"
                done < <(find "$season_dir" -maxdepth 1 -type f \( $EXT_FILTERS \) -print0 | sort -z)

                echo >> "$OUTPUT_FILE"
            done
        done

    elif [ "$top_folder_name" == "Music" ]; then
        continue
    else
        for movie_dir in "$top_folder"*/; do
            [ -d "$movie_dir" ] || continue
            movie_name=$(basename "$movie_dir")
            if should_skip_dir "$movie_dir"; then continue; fi
            echo "  $movie_name/" >> "$OUTPUT_FILE"

            while IFS= read -r -d '' file; do
                if should_skip_dir "$(dirname "$file")"; then continue; fi
                echo "    $(basename "$file")" >> "$OUTPUT_FILE"
            done < <(find "$movie_dir" -maxdepth 1 -type f \( $EXT_FILTERS \) -print0 | sort -z)

            echo >> "$OUTPUT_FILE"
        done
    fi
done

echo "Media backup saved to $OUTPUT_FILE"
