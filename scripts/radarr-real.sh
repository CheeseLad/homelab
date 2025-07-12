#!/bin/bash

MOVIES_DIR="/mnt/usb2/Plex/Movies"
cd "$MOVIES_DIR" || exit 1

shopt -s nullglob

normalize_title() {
    echo "$1" | sed -E 's/[._]+/ /g' | sed -E 's/ +/ /g' | sed 's/^ *//;s/ *$//'
}

extract_year() {
    if [[ "$1" =~ ([\(]?((19|20)[0-9]{2})[\)]?) ]]; then
        echo "${BASH_REMATCH[2]}"
    else
        echo ""
    fi
}

# Extract common tags from filename (everything after year)
extract_tags() {
    local name="$1"
    local year="$2"

    # Remove everything before and including the year (and any parentheses)
    local rest=$(echo "$name" | sed -E "s/.*(\(?${year}\)?)[ _.-]?//I")

    # Trim spaces
    echo "$rest" | sed -E 's/^ +//; s/ +$//'
}

for video in *.mkv *.mp4 *.avi *.mov *.wmv; do
    [ -e "$video" ] || continue

    filename="${video%.*}"
    ext="${video##*.}"

    year=$(extract_year "$filename")
    if [[ -z "$year" ]]; then
        echo "Skipping '$video': Year not found."
        continue
    fi

    # Title: remove year (and parentheses) and tags after it
    # Keep only what's before year
    title=$(echo "$filename" | sed -E "s/[\(\[]?${year}[\)\]]?//g" )
    # Remove trailing tags after year
    # We'll get tags separately
    title=$(echo "$title" | sed -E 's/[._-]+$//')

    title=$(normalize_title "$title")

    tags=$(extract_tags "$filename" "$year")

    folder_name="${title} (${year})"
    # If tags exist, append with a space before tags
    if [[ -n "$tags" ]]; then
        new_file_name="${title} (${year}) ${tags}.${ext}"
    else
        new_file_name="${title} (${year}).${ext}"
    fi

    mkdir -p "$folder_name"
    mv -n "$video" "$folder_name/$new_file_name"

    # Move subtitle files, rename to match movie + language + ext
    basefile="${filename}"
    for sub in "${basefile}".*.srt "${basefile}".*.sub; do
        [ -e "$sub" ] || continue

        lang=$(echo "$sub" | sed -E "s/^${basefile}\.([a-zA-Z0-9]+)\.(srt|sub)$/\1/")

        if [[ -n "$lang" ]]; then
            sub_ext="${sub##*.}"
            new_sub_name="${title} (${year}) ${tags}"
            # Append language if exists
            new_sub_name+=".${lang}.${sub_ext}"
        else
            sub_ext="${sub##*.}"
            new_sub_name="${title} (${year}) ${tags}.${sub_ext}"
        fi

        # Trim trailing spaces
        new_sub_name=$(echo "$new_sub_name" | sed -E 's/ +$//')

        mv -n "$sub" "$folder_name/$new_sub_name"
    done

    echo "Processed '$video' -> '$folder_name/$new_file_name'"
done
