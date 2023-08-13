# homelab
My homelab setup



Planning to migrate everything to docker and have documentation here,

Software & Utilities:
----

## Hard Drive: Samba

```Shell
sudo apt-get install samba samba-common-bin
sudo nano /etc/samba/smb.conf
sudo smbpasswd -a pi
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
