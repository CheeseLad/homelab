rclone move "DCU-GCrypt-2024:/DCUMPS" "/mnt/usb1/Jake/Device Automated Backups/DCU MPS VPS" -v \
  --bwlimit 1.8M \
  --config /home/jake/scripts/rclone/rclone.conf \
  --log-file "/home/jake/scripts/rclone/copy-mps-vps.log"
