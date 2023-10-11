# homelab
My homelab setup



Planning to migrate everything to docker and have documentation here,

Software & Utilities:
----

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

Load saved shares from file

```Shell
sudo smbpasswd -a pi
sudo systemctl restart smbd
```

## VPN: PiVPN

Currently I am using PiVPN to connect my laptop and mobile devices to my homelab. Can be easily installed with the following command:

```Shell
git clone https://github.com/pivpn/pivpn.git
bash pivpn/auto_install/install.sh
```

Config:
- **VPN Protocol**: WireGuard
- **DNS**: Google DNS

## DNS Filter: Pihole


```Shell
git clone --depth 1 https://github.com/pi-hole/pi-hole.git Pi-hole
cd "Pi-hole/automated install/"
sudo bash basic-install.sh
```

## Media Library: Plex

```Shell
sudo apt-get install apt-transport-https

curl https://downloads.plex.tv/plex-keys/PlexSign.key | gpg --dearmor | sudo tee /usr/share/keyrings/plex-archive-keyring.gpg >/dev/null

echo deb [signed-by=/usr/share/keyrings/plex-archive-keyring.gpg] https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list

sudo apt-get update

sudo apt install plexmediaserver
```

Initialise Repository Script:
```Shell
https://github.com/CheeseLad/homelab/blob/main/scripts/plex-add-repo.sh
``` 
## Sonarr
## NAS
## Android: FolderSync
[Google Play Link](https://play.google.com/store/apps/details?id=dk.tacit.android.foldersync.lite&hl=en_IE&gl=US)
## iOS: PhotoSync
[App Store Link](https://apps.apple.com/us/app/photosync-transfer-photos/id415850124)
