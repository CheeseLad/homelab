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

extract_tags() {
    local name="$1"
    local year="$2"
    local rest=$(echo "$name" | sed -E "s/.*(\(?${year}\)?)[ _.-]?//I")
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

    title=$(echo "$filename" | sed -E "s/[\(\[]?${year}[\)\]]?//g" )
    title=$(echo "$title" | sed -E 's/[._-]+$//')
    title=$(normalize_title "$title")

    tags=$(extract_tags "$filename" "$year")

    folder_name="${title} (${year})"
    if [[ -n "$tags" ]]; then
        new_file_name="${title} (${year}) ${tags}.${ext}"
    else
        new_file_name="${title} (${year}).${ext}"
    fi

    echo "[DRY RUN] Would create folder: '$folder_name'"
    echo "[DRY RUN] Would move file: '$video' -> '$folder_name/$new_file_name'"

    basefile="${filename}"
    for sub in "${basefile}".*.srt "${basefile}".*.sub; do
        [ -e "$sub" ] || continue

        lang=$(echo "$sub" | sed -E "s/^${basefile}\.([a-zA-Z0-9]+)\.(srt|sub)$/\1/")
        sub_ext="${sub##*.}"

        if [[ -n "$lang" ]]; then
            new_sub_name="${title} (${year}) ${tags}.${lang}.${sub_ext}"
        else
            new_sub_name="${title} (${year}) ${tags}.${sub_ext}"
        fi

        new_sub_name=$(echo "$new_sub_name" | sed -E 's/ +$//')

        echo "[DRY RUN] Would move subtitle: '$sub' -> '$folder_name/$new_sub_name'"
    done

done
