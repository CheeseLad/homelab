# homelab
My homelab setup



Planning to migrate everything to docker and have documentation here,

Software & Utilities:
----

## VPN: PiVPN

Currently I am using PiVPN to connect my laptop and mobile devices to my homelab. Can be easily installed with the following command:

```Shell
git clone https://github.com/pivpn/pivpn.git
bash pivpn/auto_install/install.sh
```

Config:
VPN Protocol: WireGuard
DNS: Google DNS

## DNS Filter: Pihole


```Shell
git clone --depth 1 https://github.com/pi-hole/pi-hole.git Pi-hole
cd "Pi-hole/automated install/"
sudo bash basic-install.sh
```

Plex
Sonarr
NAS
