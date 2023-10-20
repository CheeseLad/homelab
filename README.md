# homelab
CheeseLad's Homelab Setup

Currently running everything on a Raspberry Pi 2 Model B

Planned Services:
- Personal Website Hosting
- HedgeDoc (CodiMD)
- PhotoPrism (With new hardware)
- [zipline](https://github.com/diced/zipline)


# Software & Utilities:

## Starting Off: Update System

```Shell
sudo apt-get update
sudo apt-get upgrade
```

## Hard Drive: Samba

```Shell
sudo apt-get install samba samba-common-bin
sudo nano /etc/samba/smb.conf
```

Mounting Drive
```Shell
sudo apt install ntfs-3g
sudo mkdir -p /mnt/usb1
sudo chown -R pi:pi /mnt/usb1
sudo nano /etc/fstab
```

Add in stored drive information

```Shell
sudo umount /dev/sda1
sudo mount -a
```

Load saved shares from file

```Shell
sudo smbpasswd -a pi
sudo systemctl restart smbd
```

## VPN: PiVPN

Currently I am using PiVPN to connect my laptop and mobile devices to my homelab. Can be easily installed with the following command:

```Shell
curl -L https://install.pivpn.io | bash
```

Config:
- **VPN Protocol**: WireGuard
- **DNS**: Google DNS

## DNS Filter: Pihole

```Shell
curl -sSL https://install.pi-hole.net | bash
```
Config:
- **DNS**: Google DNS

Access:
- Pi-hole can be accessed here (locally): [http://raspberrypi.local/admin/login.php](http://raspberrypi.local/admin/login.php)

## Media Library: Plex

```Shell
sudo apt-get install apt-transport-https

curl https://downloads.plex.tv/plex-keys/PlexSign.key | gpg --dearmor | sudo tee /usr/share/keyrings/plex-archive-keyring.gpg >/dev/null

echo deb [signed-by=/usr/share/keyrings/plex-archive-keyring.gpg] https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list

sudo apt-get update

sudo apt install plexmediaserver
```

Access :
- Plex can be accessed here (locally): [http://raspberrypi.local:32400/web/index.html](http://raspberrypi.local:32400/web/index.html)

## Photo Backup
- Android: [FolderSync](https://play.google.com/store/apps/details?id=dk.tacit.android.foldersync.lite&hl=en_IE&gl=US)
- iOS: [PhotoSync](https://apps.apple.com/us/app/photosync-transfer-photos/id415850124)
