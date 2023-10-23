# Cat-Bot

## Cat-Bot is a discord bot hosted on my Raspberry Pi. The following is the configuration data to get it up and running as well as making it run at start-up.

### Setup Commands

```Shell
sudo apt install python3-pip
python3 -m pip install -U discord.py
sudo nano /lib/systemd/system/catbot.service
sudo chmod +x /home/pi/cat-bot/main.py
sudo systemctl start catbot.service
sudo systemctl stop catbot.service
```

### catbot.service

```Shell
[Unit]
Description=CatBot Service

[Service]
ExecStart=/usr/bin/python3 -u main.py
WorkingDirectory=/home/pi/cat-bot
StandardOutput=inherit
StandardError=inherit
Restart=always
RestartSec=15
User=pi

[Install]
WantedBy=multi-user.target
Alias=catbot.service
```