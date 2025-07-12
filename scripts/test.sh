MEDIA_DIR="/mnt/usb2/Plex"
EXTENSIONS=("mp4" "mkv" "avi" "mov" "flv")

for show_dir in "$MEDIA_DIR/Series"/*/; do
    show_name=$(basename "$show_dir")
    echo "Show: $show_name"

    for season_dir in "$show_dir"*/; do
        season_name=$(basename "$season_dir")
        echo "  Season: $season_name"

        find "$season_dir" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.flv" \) -print | while read -r file; do
            echo "    File: $(basename "$file")"
        done
    done
done
